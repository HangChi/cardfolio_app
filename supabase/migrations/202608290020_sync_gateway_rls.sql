-- The REST gateway calls cardfolio_apply_mutation with the user's JWT.
-- The invoker therefore needs insert policies for the append-only tables.

drop policy if exists "cardfolio changes append own rows"
  on public.cardfolio_sync_changes;
create policy "cardfolio changes append own rows"
  on public.cardfolio_sync_changes
  for insert to authenticated
  with check (user_id = auth.uid());

drop policy if exists "cardfolio operations append own rows"
  on public.cardfolio_sync_operations;
create policy "cardfolio operations append own rows"
  on public.cardfolio_sync_operations
  for insert to authenticated
  with check (user_id = auth.uid());

-- Only the RPC needs these writes; clients still cannot update or delete rows.
grant select, insert, update on public.cardfolio_sync_entities
  to authenticated;
grant select on public.cardfolio_sync_changes to authenticated;
grant select on public.cardfolio_sync_operations to authenticated;
grant insert on public.cardfolio_sync_changes to authenticated;
grant insert on public.cardfolio_sync_operations to authenticated;
grant usage, select on sequence public.cardfolio_sync_changes_change_id_seq
  to authenticated;
