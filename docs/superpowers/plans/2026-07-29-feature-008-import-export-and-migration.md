# Feature 008 Import, Export and Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans
> to implement this plan task-by-task. The user explicitly forbids subagents,
> branches, simulators and intermediate commits.

**Goal:** Build a versioned, verifiable full-library ZIP backup with safe empty-library restore and add-only merge.

**Architecture:** A stable logical snapshot sits between Drift and ZIP. Archive inspection is read-only and enforces path, size, ratio, manifest, checksum and relationship rules before import. Import stages images and commits all database rows transactionally, compensating files on failure.

**Tech Stack:** Flutter, Riverpod, go_router, Drift/SQLite, archive, file_picker.

## Global Constraints

- Format version is 1 and supported range is 1 through 1.
- ZIP limits are 50,000 entries, 2 GiB uncompressed total, 64 MiB per entry and 100:1 compression ratio.
- Do not open a simulator or device; list manual steps instead.
- Work inline on the current branch and create one commit only after full verification.

---

## Task 1: Format and security boundary

- [ ] Write tests that fail because backup models, version migration and archive path/limit checks are absent.
- [ ] Run `flutter test test/features/backup/domain test/features/backup/data/backup_archive_test.dart`.
- [ ] Implement the minimal models, typed failures, cancellation, progress, SHA-256 and archive checks.
- [ ] Re-run the target tests and refactor only while green.

## Task 2: Logical snapshot and database boundary

- [ ] Write a full 17-table fixture and failing stable-serialization, relationship, empty-library and merge tests.
- [ ] Run `flutter test test/features/backup/data/backup_database_test.dart`.
- [ ] Implement explicit logical JSON conversion, validation, stable ordering and transaction insertion.
- [ ] Re-run the target tests and mutation-check UUID, relation and money assertions.

## Task 3: Export and atomic import

- [ ] Write failing export, tamper, round-trip, cancellation and commit-compensation tests.
- [ ] Run `flutter test test/features/backup/data/backup_repository_impl_test.dart`.
- [ ] Implement archive creation, inspection, revalidation, staging, database transaction and compensation.
- [ ] Re-run all backup data tests.

## Task 4: Native picker and UI

- [ ] Write failing picker-cancel, privacy, preview, conflict, progress, report and route tests.
- [ ] Run `flutter test test/features/backup/presentation test/app/cardfolio_app_test.dart`.
- [ ] Implement the platform picker, providers, bootstrap override, screen, route and profile entry.
- [ ] Re-run Widget and app tests.

## Task 5: Completion gate

- [ ] Run `dart format --output=none --set-exit-if-changed lib test integration_test`.
- [ ] Run `flutter test`.
- [ ] Run `flutter analyze`.
- [ ] Re-read Feature 008 acceptance and update all evidence documents.
- [ ] Review `git diff`, stage the scoped files and create one commit.
