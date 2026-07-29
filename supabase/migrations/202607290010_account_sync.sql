-- Cardfolio Feature 010 reference backend.
-- REST /v1 gateway code must call these functions with the authenticated JWT.

create extension if not exists pgcrypto;

create table if not exists public.cardfolio_sync_entities (
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null check (entity_type = any (array[
    'cardDefinitions', 'cardItems', 'cardImages', 'cardSets',
    'cardSetMembers', 'tags', 'cardTags', 'seriesRecords', 'seriesCards',
    'seriesSets', 'customFieldDefinitions', 'customFieldValues', 'purchases',
    'purchaseItems', 'exchangeRates', 'recycleBinSettings'
  ])),
  entity_id text not null,
  payload jsonb,
  deleted boolean not null default false,
  server_version bigint not null check (server_version > 0),
  changed_fields text[] not null default '{}',
  updated_at timestamptz not null default now(),
  primary key (user_id, entity_type, entity_id),
  check ((deleted and payload is null) or (not deleted and payload is not null))
);

create table if not exists public.cardfolio_sync_changes (
  change_id bigint generated always as identity primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  entity_type text not null,
  entity_id text not null,
  operation text not null check (operation in ('upsert', 'delete')),
  payload jsonb,
  server_version bigint not null,
  changed_fields text[] not null default '{}',
  occurred_at timestamptz not null default now()
);

create index if not exists cardfolio_sync_changes_user_cursor
  on public.cardfolio_sync_changes(user_id, change_id);

create table if not exists public.cardfolio_sync_operations (
  user_id uuid not null references auth.users(id) on delete cascade,
  operation_id uuid not null,
  request_hash text not null,
  result jsonb not null,
  created_at timestamptz not null default now(),
  primary key (user_id, operation_id)
);

alter table public.cardfolio_sync_entities enable row level security;
alter table public.cardfolio_sync_changes enable row level security;
alter table public.cardfolio_sync_operations enable row level security;

create policy "cardfolio entities are tenant private"
  on public.cardfolio_sync_entities
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

create policy "cardfolio changes are tenant private"
  on public.cardfolio_sync_changes
  for select to authenticated
  using (user_id = auth.uid());

create policy "cardfolio operations are tenant private"
  on public.cardfolio_sync_operations
  for select to authenticated
  using (user_id = auth.uid());

create or replace function public.cardfolio_apply_mutation(p_mutation jsonb)
returns jsonb
language plpgsql
security invoker
set search_path = public
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
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;

  v_operation_id := (p_mutation->>'operationId')::uuid;
  v_entity_type := p_mutation->>'entityType';
  v_entity_id := p_mutation->>'entityId';
  v_operation := p_mutation->>'operation';
  v_base_version := (p_mutation->>'baseServerVersion')::bigint;
  v_payload := p_mutation->'payload';
  select coalesce(array_agg(value), '{}')
    into v_changed_fields
    from jsonb_array_elements_text(
      coalesce(p_mutation->'changedFields', '[]'::jsonb)
    );
  v_request_hash := encode(digest(p_mutation::text, 'sha256'), 'hex');

  if v_entity_type is null
     or not (v_entity_type = any (array[
       'cardDefinitions', 'cardItems', 'cardImages', 'cardSets',
       'cardSetMembers', 'tags', 'cardTags', 'seriesRecords', 'seriesCards',
       'seriesSets', 'customFieldDefinitions', 'customFieldValues', 'purchases',
       'purchaseItems', 'exchangeRates', 'recycleBinSettings'
     ]))
     or v_entity_id is null
     or v_operation not in ('upsert', 'delete')
     or v_base_version < 0
     or (v_operation = 'upsert' and v_payload is null)
     or (v_operation = 'delete' and v_payload is not null) then
    raise exception 'invalid_mutation' using errcode = '22023';
  end if;

  select * into v_existing
    from public.cardfolio_sync_operations
    where user_id = v_user_id and operation_id = v_operation_id;
  if found then
    if v_existing.request_hash <> v_request_hash then
      raise exception 'idempotency_mismatch' using errcode = '23505';
    end if;
    return v_existing.result;
  end if;

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

grant execute on function public.cardfolio_apply_mutation(jsonb)
  to authenticated;

insert into storage.buckets (id, name, public)
values ('cardfolio-private', 'cardfolio-private', false)
on conflict (id) do update set public = false;

create policy "cardfolio attachment read own prefix"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "cardfolio attachment insert own prefix"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "cardfolio attachment update own prefix"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = auth.uid()::text
  )
  with check (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create policy "cardfolio attachment delete own prefix"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'cardfolio-private'
    and split_part(name, '/', 1) = auth.uid()::text
  );

create or replace function public.cardfolio_delete_my_cloud_data()
returns void
language plpgsql
security invoker
set search_path = public, storage
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then
    raise exception 'authentication_required' using errcode = '28000';
  end if;
  delete from storage.objects
    where bucket_id = 'cardfolio-private'
      and split_part(name, '/', 1) = v_user_id::text;
  delete from public.cardfolio_sync_operations where user_id = v_user_id;
  delete from public.cardfolio_sync_changes where user_id = v_user_id;
  delete from public.cardfolio_sync_entities where user_id = v_user_id;
end;
$$;

grant execute on function public.cardfolio_delete_my_cloud_data()
  to authenticated;
