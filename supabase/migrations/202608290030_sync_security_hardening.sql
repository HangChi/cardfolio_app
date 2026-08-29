-- Harden the sync protocol boundary.
-- Authenticated clients may read their own sync state, but every write must go
-- through the versioned RPC so direct PostgREST writes cannot bypass the
-- idempotency log, change feed, or account-deletion gate.

create schema if not exists private;

create table if not exists public.cardfolio_account_lifecycle (
  user_id uuid primary key references auth.users(id) on delete cascade,
  deleting boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.cardfolio_account_lifecycle enable row level security;

revoke all on public.cardfolio_account_lifecycle from anon, authenticated;
revoke insert, update, delete on public.cardfolio_sync_entities from authenticated;
revoke insert, update, delete on public.cardfolio_sync_changes from authenticated;
revoke insert, update, delete on public.cardfolio_sync_operations from authenticated;
revoke usage, select on sequence public.cardfolio_sync_changes_change_id_seq
  from authenticated;

drop policy if exists "cardfolio entities are tenant private"
  on public.cardfolio_sync_entities;
create policy "cardfolio entities are tenant readable"
  on public.cardfolio_sync_entities
  for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "cardfolio changes append own rows"
  on public.cardfolio_sync_changes;
drop policy if exists "cardfolio operations append own rows"
  on public.cardfolio_sync_operations;

create or replace function private.cardfolio_lock_account(p_user_id uuid)
returns void
language sql
security definer
set search_path = ''
as $$
  select pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended('cardfolio-account:' || p_user_id::text, 0)
  );
$$;

create or replace function private.cardfolio_account_is_active()
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_deleting boolean;
begin
  if v_user_id is null then
    return false;
  end if;
  perform private.cardfolio_lock_account(v_user_id);
  select lifecycle.deleting
    into v_deleting
    from public.cardfolio_account_lifecycle as lifecycle
    where lifecycle.user_id = v_user_id;
  return not coalesce(v_deleting, false);
end;
$$;

revoke execute on function private.cardfolio_lock_account(uuid) from public;
revoke execute on function private.cardfolio_lock_account(uuid) from anon, authenticated;
revoke execute on function private.cardfolio_account_is_active() from public;
revoke execute on function private.cardfolio_account_is_active() from anon;
grant usage on schema private to authenticated;
grant execute on function private.cardfolio_account_is_active() to authenticated;

drop policy if exists "cardfolio attachment insert own prefix"
  on storage.objects;
create policy "cardfolio attachment insert own active prefix"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = (select auth.uid())::text
    and private.cardfolio_account_is_active()
  );

drop policy if exists "cardfolio attachment update own prefix"
  on storage.objects;
create policy "cardfolio attachment update own active prefix"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = (select auth.uid())::text
    and private.cardfolio_account_is_active()
  )
  with check (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = (select auth.uid())::text
    and private.cardfolio_account_is_active()
  );

create or replace function public.cardfolio_apply_mutation(p_mutation jsonb)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_operation_id uuid;
  v_entity_type text;
  v_entity_id text;
  v_operation text;
  v_base_version bigint;
  v_payload jsonb;
  v_changed_fields text[];
  v_request_hash text;
  v_existing public.cardfolio_sync_operations%rowtype;
  v_entity public.cardfolio_sync_entities%rowtype;
  v_next_version bigint;
  v_result jsonb;
  v_deleting boolean;
  v_created_at timestamptz;
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;

  perform private.cardfolio_lock_account(v_user_id);
  select lifecycle.deleting
    into v_deleting
    from public.cardfolio_account_lifecycle as lifecycle
    where lifecycle.user_id = v_user_id;
  if coalesce(v_deleting, false) then
    raise exception 'account_deleting' using errcode = '55000';
  end if;

  if pg_catalog.jsonb_typeof(p_mutation) <> 'object' then
    raise exception 'invalid_mutation' using errcode = '22023';
  end if;

  begin
    v_operation_id := (p_mutation->>'operationId')::uuid;
    v_entity_type := p_mutation->>'entityType';
    v_entity_id := p_mutation->>'entityId';
    v_operation := p_mutation->>'operation';
    v_base_version := (p_mutation->>'baseServerVersion')::bigint;
    v_created_at := (p_mutation->>'createdAt')::timestamptz;
  exception when invalid_text_representation
      or numeric_value_out_of_range
      or datetime_field_overflow then
    raise exception 'invalid_mutation' using errcode = '22023';
  end;
  -- JSON `null` is a jsonb value, not SQL NULL. Normalize it so delete
  -- mutations satisfy the table constraint and the protocol check below.
  v_payload := nullif(p_mutation->'payload', 'null'::jsonb);
  if pg_catalog.jsonb_typeof(coalesce(p_mutation->'changedFields', 'null'::jsonb)) <> 'array' then
    raise exception 'invalid_mutation' using errcode = '22023';
  end if;
  select coalesce(array_agg(value), '{}')
    into v_changed_fields
    from jsonb_array_elements_text(
      coalesce(p_mutation->'changedFields', '[]'::jsonb)
    );
  v_request_hash := pg_catalog.encode(
    pg_catalog.sha256(pg_catalog.convert_to(p_mutation::text, 'UTF8')),
    'hex'
  );

  if v_entity_type is null
     or not (v_entity_type = any (array[
       'cardDefinitions', 'cardItems', 'cardImages', 'cardSets',
       'cardSetMembers', 'tags', 'cardTags', 'seriesRecords', 'seriesCards',
       'seriesSets', 'customFieldDefinitions', 'customFieldValues', 'purchases',
       'purchaseItems', 'exchangeRates', 'recycleBinSettings'
     ]))
     or v_entity_id is null
     or length(v_entity_id) = 0
     or length(v_entity_id) > 2048
     or v_created_at is null
     or v_operation not in ('upsert', 'delete')
     or v_base_version < 0
     or (v_operation = 'upsert' and pg_catalog.jsonb_typeof(v_payload) <> 'object')
     or (v_operation = 'delete' and v_payload is not null) then
    raise exception 'invalid_mutation' using errcode = '22023';
  end if;
  if exists (
    select 1 from unnest(v_changed_fields) as field
    where length(field) > 200
  ) then
    raise exception 'invalid_mutation' using errcode = '22023';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'cardfolio-operation:' || v_user_id::text || ':' || v_operation_id::text,
      0
    )
  );
  select * into v_existing
    from public.cardfolio_sync_operations
    where user_id = v_user_id and operation_id = v_operation_id;
  if found then
    if v_existing.request_hash <> v_request_hash then
      raise exception 'idempotency_mismatch' using errcode = '23505';
    end if;
    return v_existing.result;
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(
      'cardfolio-entity:' || v_user_id::text || ':' || v_entity_type || ':' || v_entity_id,
      0
    )
  );
  select * into v_entity
    from public.cardfolio_sync_entities
    where user_id = v_user_id
      and entity_type = v_entity_type
      and entity_id = v_entity_id
    for update;

  if v_base_version <> coalesce(v_entity.server_version, 0) then
    v_result := jsonb_build_object(
      'kind', 'conflict',
      'operationId', v_operation_id,
      'change', jsonb_build_object(
        'changeId', 'conflict:' || coalesce(v_entity.server_version, 0),
        'entityType', v_entity_type,
        'entityId', v_entity_id,
        'operation', case when v_entity.deleted then 'delete' else 'upsert' end,
        'serverVersion', coalesce(v_entity.server_version, 0),
        'payload', v_entity.payload,
        'changedFields', to_jsonb(coalesce(v_entity.changed_fields, '{}')),
        'occurredAt', coalesce(v_entity.updated_at, now())
      )
    );
  else
    v_next_version := coalesce(v_entity.server_version, 0) + 1;
    insert into public.cardfolio_sync_entities (
      user_id, entity_type, entity_id, payload, deleted, server_version,
      changed_fields, updated_at
    ) values (
      v_user_id, v_entity_type, v_entity_id, v_payload,
      v_operation = 'delete', v_next_version, v_changed_fields, now()
    )
    on conflict (user_id, entity_type, entity_id) do update set
      payload = excluded.payload,
      deleted = excluded.deleted,
      server_version = excluded.server_version,
      changed_fields = excluded.changed_fields,
      updated_at = excluded.updated_at;

    insert into public.cardfolio_sync_changes (
      user_id, entity_type, entity_id, operation, payload, server_version,
      changed_fields
    ) values (
      v_user_id, v_entity_type, v_entity_id, v_operation, v_payload,
      v_next_version, v_changed_fields
    );

    v_result := jsonb_build_object(
      'kind', 'ack',
      'operationId', v_operation_id,
      'entityType', v_entity_type,
      'entityId', v_entity_id,
      'serverVersion', v_next_version
    );
  end if;

  insert into public.cardfolio_sync_operations (
    user_id, operation_id, request_hash, result
  ) values (v_user_id, v_operation_id, v_request_hash, v_result);
  return v_result;
end;
$$;

revoke execute on function public.cardfolio_apply_mutation(jsonb) from public;
revoke execute on function public.cardfolio_apply_mutation(jsonb) from anon;
grant execute on function public.cardfolio_apply_mutation(jsonb) to authenticated;

create or replace function public.cardfolio_begin_account_deletion()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;
  perform private.cardfolio_lock_account(v_user_id);
  insert into public.cardfolio_account_lifecycle (user_id, deleting, updated_at)
  values (v_user_id, true, now())
  on conflict (user_id) do update set deleting = true, updated_at = now();
end;
$$;

revoke execute on function public.cardfolio_begin_account_deletion() from public;
revoke execute on function public.cardfolio_begin_account_deletion() from anon;
grant execute on function public.cardfolio_begin_account_deletion() to authenticated;

create or replace function public.cardfolio_delete_my_cloud_data()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_deleting boolean;
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;
  perform private.cardfolio_lock_account(v_user_id);
  select lifecycle.deleting
    into v_deleting
    from public.cardfolio_account_lifecycle as lifecycle
    where lifecycle.user_id = v_user_id;
  if not coalesce(v_deleting, false) then
    raise exception 'deletion_not_started' using errcode = '55000';
  end if;
  -- Storage object bytes are deleted by the gateway through the Storage API
  -- before this RPC runs. Direct SQL deletion would orphan the backing object.
  delete from public.cardfolio_sync_operations where user_id = v_user_id;
  delete from public.cardfolio_sync_changes where user_id = v_user_id;
  delete from public.cardfolio_sync_entities where user_id = v_user_id;
end;
$$;

revoke execute on function public.cardfolio_delete_my_cloud_data() from public;
revoke execute on function public.cardfolio_delete_my_cloud_data() from anon;
grant execute on function public.cardfolio_delete_my_cloud_data() to authenticated;
