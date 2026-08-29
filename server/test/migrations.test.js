import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const hardeningMigration = new URL(
  '../../supabase/migrations/202608290030_sync_security_hardening.sql',
  import.meta.url,
);

test('sync hardening migration keeps writes behind locked security-definer RPCs', async () => {
  const sql = await readFile(hardeningMigration, 'utf8');

  assert.match(sql, /revoke insert, update, delete on public\.cardfolio_sync_entities/);
  assert.match(sql, /drop policy if exists "cardfolio changes append own rows"/);
  assert.match(sql, /drop policy if exists "cardfolio operations append own rows"/);
  assert.match(
    sql,
    /function public\.cardfolio_apply_mutation\(p_mutation jsonb\)[\s\S]*?security definer[\s\S]*?set search_path = ''/,
  );
  assert.match(sql, /private\.cardfolio_lock_account\(v_user_id\)/);
  assert.match(sql, /cardfolio-operation:/);
  assert.match(sql, /cardfolio-entity:/);
  assert.match(sql, /nullif\(p_mutation->'payload', 'null'::jsonb\)/);
});

test('account deletion gate is required before cloud cleanup', async () => {
  const sql = await readFile(hardeningMigration, 'utf8');

  assert.match(sql, /function public\.cardfolio_begin_account_deletion\(\)/);
  assert.match(sql, /function public\.cardfolio_delete_my_cloud_data\(\)/);
  assert.match(sql, /raise exception 'deletion_not_started'/);
  assert.match(sql, /cardfolio attachment insert own active prefix/);
  assert.match(sql, /private\.cardfolio_account_is_active\(\)/);
  assert.doesNotMatch(sql, /delete from storage\.objects/i);
});
