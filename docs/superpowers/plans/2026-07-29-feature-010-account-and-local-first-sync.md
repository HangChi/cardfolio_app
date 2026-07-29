# Feature 010 Account and Local-first Sync Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. This task must run inline without subagents, without a new branch, and without launching a simulator.

**Goal:** Add optional accounts and a durable, idempotent local-first synchronization client while preserving offline-first reads and writes.

**Architecture:** Drift remains the only client read source. A persistent outbox and acknowledged entity baseline are derived from logical snapshots; an injected HTTPS REST boundary handles auth, mutation batches, cursors, and private attachments. Three-way merge rebases disjoint edits and records same-field or delete/edit collisions as conflict copies.

**Tech Stack:** Flutter, Riverpod, Drift/SQLite, `package:http`, `flutter_secure_storage`, Supabase SQL/RLS reference migration.

## Global Constraints

- Do not create or switch branches and do not use subagents.
- Do not start an emulator or simulator; automated work is limited to host interface, unit, migration, and Widget tests.
- Local database writes succeed independently of cloud availability.
- Retry reuses the same operation UUID and no token is stored in Drift, preferences, payloads, or logs.
- Production endpoints must use HTTPS and the API base URL comes from `CARD_FOLIO_API_BASE_URL`.

---

### Task 1: Freeze protocol, evidence, privacy, and acceptance

**Files:**
- Create: `docs/architecture/adr/ADR-009-account-sync-service-and-protocol.md`
- Create: `docs/features/010-account-and-local-first-sync/{acceptance,contracts,data-model,error-cases,plan,spec,tasks,test-matrix,ux-mapping}.md`
- Modify: `docs/security/{privacy-design,threat-model}.md`

**Interfaces:**
- Produces: REST v1 payloads, entity list, merge rules, permission model, test IDs and manual device steps.

- [x] Record official Supabase/Firebase comparison and the replaceable REST decision.
- [x] Define auth, push, pull, attachment, deletion and conflict contracts with no placeholders.
- [x] Define the v7 local schema and Supabase RLS baseline.
- [x] Map FR-ACC, FR-SYNC, BR-SYNC, NFR-SYNC, SEC and AC-V1 evidence.

### Task 2: Add domain contracts and verify RED

**Files:**
- Create: `lib/features/sync/domain/{sync_models,account_sync_repository}.dart`
- Create: `test/features/sync/domain/sync_models_test.dart`

**Interfaces:**
- Produces: `SyncMutation`, `RemoteSyncChange`, `SyncMergeResult`, `AccountSession`, `SyncOverview`, `AccountSyncRepository`.

- [x] Write tests proving operation/payload validation and three-way disjoint/same-field/delete merge behavior.
- [x] Run `flutter test test/features/sync/domain/sync_models_test.dart` and confirm missing symbols fail.
- [x] Implement the minimal immutable models and merge function.
- [x] Re-run the target test and confirm it passes.

### Task 3: Add v7 durable sync state and verify RED/GREEN

**Files:**
- Modify: `lib/features/cards/data/local/{card_database,card_database.steps}.dart`
- Create: `lib/features/sync/data/local/sync_local_store.dart`
- Create: `test/features/sync/data/sync_local_store_test.dart`
- Modify: `test/drift/app/migration_test.dart`
- Generate: Drift implementation, schema v7 and generated test schema.

**Interfaces:**
- Consumes: `BackupDatabase.exportLogicalBackup()`, `IdGenerator`, `Clock`.
- Produces: `captureLocalChanges`, `pendingMutations`, `acknowledge`, `applyRemoteChanges`, `watchOverview`, `resolveConflict`.

- [x] Write failing SQLite tests for 20 queued rows, stable operation IDs, acknowledgements, remote apply, disjoint rebase, conflict copies and migration preservation.
- [x] Run target tests and confirm schema/API absence is the failure.
- [x] Add sync settings, entity baseline, outbox and conflict tables plus v6→v7 migration.
- [x] Implement snapshot diff, retry state, transactional apply and conflict resolution.
- [x] Generate Drift/schema artifacts and run target tests to green.

### Task 4: Add secure auth and REST interface adapter

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/features/sync/data/{account_sync_remote,rest_account_sync_remote,secure_session_store}.dart`
- Create: `test/features/sync/data/rest_account_sync_remote_test.dart`
- Create: `test/features/sync/data/secure_session_store_test.dart`

**Interfaces:**
- Produces: `/v1/auth/*`, `/v1/sync/push`, `/v1/sync/pull`, `/v1/sync/attachments/*` typed adapter.

- [x] Add `http: ^1.6.0` and `flutter_secure_storage: ^10.3.1`.
- [x] Write failing request/response tests for HTTPS enforcement, bearer auth, idempotency, cursor, errors and secure token lifecycle.
- [x] Implement the adapter with injected `http.Client` and platform secure storage.
- [x] Run both target files to green.

### Task 5: Implement repository orchestration and acceptance prototypes

**Files:**
- Create: `lib/features/sync/data/account_sync_repository_impl.dart`
- Create: `test/features/sync/data/account_sync_repository_impl_test.dart`
- Create: `test/features/sync/support/fakes.dart`

**Interfaces:**
- Consumes: remote, secure session, local store, managed images, clock and ID generator.
- Produces: register/login/enable/sync/sign-out/delete/resolve behavior.

- [x] Write failing tests for 20 offline mutations, replay with identical IDs, push/pull, token refresh, retry backoff, same-field conflict, delete conflict and logout retaining local.
- [x] Implement minimal orchestration and safe failure mapping.
- [x] Run the repository acceptance tests to green.

### Task 6: Wire providers, bootstrap, and account/sync UI

**Files:**
- Create: `lib/features/sync/data/sync_providers.dart`
- Create: `lib/features/sync/presentation/{profile_screen,account_sync_panel}.dart`
- Modify: `lib/app/{app_router.dart,bootstrap/app_bootstrap.dart}`
- Create: `test/features/sync/presentation/profile_screen_test.dart`
- Modify: `test/app/cardfolio_app_test.dart`

**Interfaces:**
- Produces: profile account form, sync toggle/status/manual retry, conflict actions, logout and account-deletion confirmation.

- [x] Write failing Widget tests for local-only mode, login/register, sync status, conflict visibility and destructive confirmation.
- [x] Wire production dependencies and routes while retaining existing purchase/recycle/backup/organization entries.
- [x] Run Widget and app shell tests to green.

### Task 7: Add Supabase reference backend and operational evidence

**Files:**
- Create: `supabase/migrations/202607290010_account_sync.sql`
- Modify: `docs/operations/{observability,rollback-plan}.md`
- Modify: `docs/quality/requirements-traceability.md`
- Modify: `docs/engineering/development-log.md`

**Interfaces:**
- Produces: tenant-owned change log, operation dedupe, cursors, private attachment policy and account purge function.

- [x] Add schema/RLS/functions matching the frozen REST contract.
- [x] Record redacted metrics, failure injection, replay, clock-skew and rollback controls.
- [x] Update traceability with exact automated test files and manual-only device cases.

### Task 8: Verify, review, and commit

**Files:**
- Modify: `docs/features/010-account-and-local-first-sync/tasks.md`
- Modify: any files required by verified failures.

- [x] Run Dart formatting in check mode over all changed Dart files.
- [x] Run all Feature 010 target tests, `flutter test`, and `flutter analyze`; do not launch a simulator.
- [x] Review `git diff --check`, generated artifacts, secrets, placeholders, docs links and `git status`.
- [x] Mark the task/test matrix with actual evidence and commit with `Complete account and local-first sync`.
