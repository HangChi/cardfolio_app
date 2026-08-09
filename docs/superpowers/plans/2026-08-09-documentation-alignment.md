# Documentation Alignment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Align all P0/P1 project documentation with schema v9, the current product behavior, the implemented CI gate, and the known-unavailable OCR capability without changing P2 release materials.

**Architecture:** Treat README, product rules, architecture, current Feature READMEs, quality gates, and operations documents as the current source of truth. Preserve ADRs, dated development-log entries, and historical plans/test evidence as immutable history; add explicit historical banners instead of rewriting old evidence. Add one current known-issues page for unresolved engineering limitations.

**Tech Stack:** Markdown, Flutter 3.44.0, Dart 3.12.0, Drift schema v9, GitHub Actions, PowerShell validation.

## Global Constraints

- Do not modify P2 privacy, device-matrix, performance-baseline, signing, monitoring, or store-release deliverables.
- Do not claim OCR works; record that the platform bridges and review UI exist but current runtime availability is unverified and reported unavailable.
- Do not replace dated historical test counts with 410; label them as historical evidence and link to the current baseline.
- Do not rewrite accepted ADRs or dated historical plans/specifications to simulate current implementation history.
- Current verified baseline is migration tests 42/42, full tests 410/410 in serial and default concurrency, strict analysis with zero issues, and a successful Android debug APK build on 2026-08-09.

---

### Task 1: Establish current documentation entry points

**Files:**
- Modify: `README.md`
- Modify: `docs/README.md`
- Modify: `docs/engineering-baseline.md`
- Create: `docs/known-issues.md`
- Modify: `docs/engineering/development-log.md`

**Interfaces:**
- Consumes: verified engineering baseline from commit `dce53c1`.
- Produces: current documentation navigation, known limitations, and dated verification evidence.

- [x] Update README requirements and quality commands to match the pinned CI gate.
- [x] Mark OCR as implemented scaffolding but currently unavailable pending diagnosis and device verification.
- [x] Update the documentation center date, schema version, and links to the engineering baseline and known issues.
- [x] Expand the engineering baseline with exact local commands and verified 2026-08-09 results.
- [x] Add a known-issues page covering OCR availability and the non-blocking future Built-in Kotlin plugin warning.
- [x] Append a 2026-08-09 engineering-baseline entry to the development log without editing older entries.

### Task 2: Align schema v9, standalone covers, and backup documentation

**Files:**
- Modify: `docs/architecture/overview.md`
- Modify: `docs/architecture/database-schema.md`
- Modify: `docs/architecture/domain-model.md`
- Modify: `docs/architecture/image-storage.md`
- Modify: `docs/product/business-rules.md`
- Modify: `docs/features/003-card-set-progress/README.md`
- Modify: `docs/features/003-card-set-progress/spec.md`
- Modify: `docs/features/003-card-set-progress/acceptance.md`
- Modify: `docs/features/003-card-set-progress/contracts.md`
- Modify: `docs/features/003-card-set-progress/data-model.md`
- Modify: `docs/features/003-card-set-progress/error-cases.md`
- Modify: `docs/features/003-card-set-progress/test-matrix.md`
- Modify: `docs/features/008-import-export-and-migration/README.md`
- Modify: `docs/features/008-import-export-and-migration/acceptance.md`
- Modify: `docs/features/008-import-export-and-migration/data-model.md`
- Modify: `docs/operations/backup-and-recovery.md`

**Interfaces:**
- Consumes: `CardSets.coverRelativePath`, schema v9 migration snapshots, and backup image-reference collection.
- Produces: one consistent explanation of legacy member-image covers, standalone managed covers, migration history, lifecycle, and backup inclusion.

- [x] Change current architecture references from schema v8 to schema v9 and add the v9 history row.
- [x] Document `card_sets.cover_relative_path` beside legacy `cover_image_id` and define standalone-cover precedence.
- [x] Update deletion, orphan cleanup, and backup rules for standalone card-set covers.
- [x] Update Feature 003 contracts, data model, acceptance, errors, and tests for both cover sources.
- [x] Update Feature 008 and operations backup documents to require standalone card-set cover bytes and validation.

### Task 3: Align OCR, roadmap, and traceability status

**Files:**
- Modify: `docs/features/README.md`
- Modify: `docs/product/roadmap.md`
- Modify: `docs/product/卡迹App_PRD_v1.0.md`
- Modify: `docs/quality/requirements-traceability.md`
- Modify: `docs/features/009-camera-and-image-processing/README.md`
- Modify: `docs/features/009-camera-and-image-processing/test-matrix.md`

**Interfaces:**
- Consumes: existing ML Kit/Vision MethodChannel code and the current user-reported unavailable runtime state.
- Produces: a non-contradictory distinction between image processing (Feature 009, implemented) and OCR/autofill (cross-feature enhancement, unavailable pending diagnosis).

- [x] Remove OCR from lists of currently usable delivered capabilities.
- [x] Keep the platform bridge implementation as engineering history, while marking runtime availability and device verification incomplete.
- [x] Change roadmap M4 and next priorities to show OCR diagnosis as open and CI establishment as complete.
- [x] Add current OCR limitation evidence to requirements traceability.

### Task 4: Align CI, development, and quality gates

**Files:**
- Modify: `docs/operations/ci-cd.md`
- Modify: `docs/engineering/development-guide.md`
- Modify: `docs/quality/test-strategy.md`

**Interfaces:**
- Consumes: `.github/workflows/ci.yml`.
- Produces: exact current PR/main gate documentation, separated from future release-pipeline targets.

- [x] Document only the currently implemented workflow as active.
- [x] Move generated-code diff checks, artifact reports, signed release pipelines, and immutable action pinning under planned enhancements.
- [x] Synchronize local gate commands with format, fatal analyzer, migration tests, serial full tests, and Android debug build.

### Task 5: Mark historical feature evidence and correct current behavior conflicts

**Files:**
- Modify: `docs/design/figma-handoff.md`
- Modify: `docs/features/001-local-card-creation/spec.md`
- Modify: `docs/features/001-local-card-creation/tasks.md`
- Modify: `docs/features/004-tags-series-and-filters/spec.md`
- Modify: `docs/features/004-tags-series-and-filters/test-matrix.md`
- Modify: `docs/features/005-purchases-and-costs/spec.md`
- Modify: `docs/features/005-purchases-and-costs/acceptance.md`
- Modify: `docs/features/005-purchases-and-costs/ux-mapping.md`
- Modify: `docs/features/005-purchases-and-costs/test-matrix.md`
- Modify: `docs/features/006-dashboard-and-statistics/spec.md`
- Modify: `docs/features/006-dashboard-and-statistics/data-model.md`
- Modify: `docs/features/006-dashboard-and-statistics/test-matrix.md`
- Modify: `docs/features/007-recycle-bin/test-matrix.md`
- Modify: `docs/features/008-import-export-and-migration/test-matrix.md`
- Modify: `docs/features/010-account-and-local-first-sync/README.md`
- Modify: `docs/features/010-account-and-local-first-sync/test-matrix.md`
- Modify: `docs/operations/observability.md`

**Interfaces:**
- Consumes: current Feature READMEs and product business rules.
- Produces: clear historical/current labeling without erasing dated delivery evidence.

- [x] Mark M0 Figma and superseded Feature specifications as historical snapshots with current-document links.
- [x] Reconcile Feature 001 implementation task state while leaving device/Figma validation open.
- [x] Correct Feature 005 deletion semantics: audit snapshot remains, active totals exclude deleted targets.
- [x] Label legacy purchasing UI and old dashboard/multi-currency behavior as historical compatibility evidence.
- [x] Add dated-evidence banners to old full-suite counts rather than replacing them.
- [x] Correct observability section ordering.

### Task 6: Validate documentation consistency

**Files:**
- Review: all Markdown under `README.md` and `docs/`

**Interfaces:**
- Consumes: Tasks 1–5.
- Produces: a documentation-only diff with no current schema/OCR/CI contradictions or broken local links.

- [x] Search current documents for stale `schema v8`, usable-OCR claims, obsolete CI TODOs, and unqualified historical test counts.
- [x] Validate all relative Markdown links resolve, ignoring link-like text inside fenced code blocks.
- [x] Run `git diff --check` and inspect `git diff --stat` plus the complete documentation diff.
- [x] Record the documentation alignment in project memory.
