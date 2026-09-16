# Feedback & Review App

## Step-by-Step Implementation Plan

**Status:** Draft  
**Target:** MVP Android and iOS release  
**Stack:** Flutter, Dart, Firebase Authentication, Cloud Firestore, Cloud Functions  
**Source documents:** [PRD](docs/PRD.md), [TRD](docs/TRD.md), [App flow](docs/appflow.md), [Backend schema](docs/backend.md) ,[UI UX](docs/UI_UX.md) 
**Last updated:** 2026-08-31

## 1. Delivery Strategy

Build the product in vertical slices while establishing security and data contracts early. Every phase ends with a reviewable deliverable and an exit check. Do not build production screens against an untested or permissive backend.

### Working rules

- Keep the MVP form fixed: rating, review, and suggestion.
- Use one organization in the initial application workflow, while keeping all data organization-scoped.
- Treat Firestore Security Rules as production code and test them before feature completion.
- Keep client UI, domain models, repositories, and Firebase adapters separate.
- Use seeded data and Firebase emulators for repeatable development.
- Do not add deferred features such as AI analysis, public reviews, payments, or broad integrations during MVP.

## 2. Phase 0: Planning and Product Baseline

**Goal:** Confirm decisions that affect schema, privacy, and release scope before implementation accelerates.

### Tasks

1. Confirm the pilot customer type and organization workflow.
2. Decide whether MVP uses invitation-only membership or allows organization creation.
3. Confirm identifiable versus organization-only response visibility.
4. Set review and suggestion maximum lengths.
5. Define minimum Android/iOS versions and Firebase region.
6. Confirm retention, account deletion, anonymization, and support policies.
7. Convert open PRD questions into tracked decisions.
8. Create product backlog from the app flow and acceptance scenarios.

### Deliverables

- Approved MVP scope and decision log.
- Prioritized backlog with acceptance criteria.
- Privacy and data-handling assumptions.
- Initial release risks, owners, and target milestones.

### Exit criteria

- No unresolved decision blocks the Auth, schema, or response-submission design.
- Product owner approves roles, response visibility, and status lifecycle.

## 3. Phase 1: Project and Development Setup

**Goal:** Turn the Flutter starter into a reproducible, multi-environment application foundation.

### Tasks

1. Verify Flutter/Dart versions and configure `flutter_lints`.
2. Add approved packages: FlutterFire, Riverpod, `go_router`, and test dependencies.
3. Create the feature-oriented `lib/` structure from the TRD.
4. Configure Material 3 theme, typography, spacing, colors, and responsive breakpoints from `UI_UX.md`.
5. Create local, staging, and production Firebase project aliases.
6. Configure FlutterFire options without committing secrets or service-account files.
7. Add environment-aware app bootstrap and Firebase initialization.
8. Configure Git hooks or CI checks for formatting, analysis, and tests.
9. Add a global error boundary, typed failure model, and non-sensitive logger.
10. Add a basic app shell with router and placeholder role-aware navigation.

### Deliverables

- Compiling Flutter app with the agreed package set.
- Environment configuration for local/staging/production.
- App shell, theme, router, error model, and folder structure.
- Initial CI pipeline running format, analysis, and unit tests.
- Firebase Emulator Suite configuration.

### Exit criteria

- `dart format`, `flutter analyze`, and the starter test suite pass.
- App launches on at least one Android and one iOS target.
- Local Firebase emulators start with no production credentials.

## 4. Phase 2: Authentication and Session Management

**Goal:** Establish secure identity, onboarding, and route protection.

### Tasks

1. Enable Firebase email/password authentication.
2. Implement Auth repository and typed Auth failure mapping.
3. Build splash/bootstrap session restoration.
4. Build sign-in, sign-up, forgot-password, and sign-out flows.
5. Create the user profile after account creation with retry-safe behavior.
6. Implement auth state provider and router redirects.
7. Implement privacy/product onboarding completion.
8. Implement invitation acceptance or organization creation according to Phase 0 decisions.
9. Load active organization membership and role after authentication.
10. Handle token refresh, session expiration, suspended membership, and missing profile states.
11. Add rate-limit-safe error copy without account-existence disclosure.

### Deliverables

- Auth repository, providers/controllers, and route guards.
- Sign-in, sign-up, reset-password, privacy, and organization onboarding screens.
- User profile and membership loading behavior.
- Auth emulator fixtures and authentication tests.

### Exit criteria

- Signed-out users cannot access authenticated routes, including deep links.
- A new user can create an account, complete onboarding, and reach Home.
- Sign-in failures, offline behavior, reset flow, and session expiry are handled.
- Suspended or unauthorized users cannot continue into protected data.

## 5. Phase 3: Database, Security Rules, and Backend Foundation

**Goal:** Implement the authoritative data model and tenant-safe access layer before feature screens.

### Tasks

1. Create Firestore collections, converters, domain models, and repository interfaces.
2. Add organization, user, membership, context, question, assignment, response, activity, aggregate, and invitation models.
3. Write Security Rules with default deny behavior.
4. Implement helper rules for authentication, active membership, role checks, organization matching, and immutable fields.
5. Add composite indexes for confirmed query patterns.
6. Seed organizations and users for all four roles in the emulator.
7. Implement callable Functions for organization creation, invitations, role changes, and invitation acceptance.
8. Implement response uniqueness and idempotency strategy.
9. Implement server timestamp and immutable-field validation.
10. Add audit activity writes for status, assignment, note, context, and membership changes.
11. Add aggregate document shape and a rebuildable aggregate Function.
12. Add emulator tests for cross-tenant and field-tampering cases.

### Deliverables

- Version-controlled Firestore rules and indexes.
- Typed Firestore converters and repositories.
- Seed data for contributor, reviewer, administrator, owner, and separate organization fixtures.
- Cloud Functions with stable error codes.
- Security Rules, transaction, and Function tests.
- Documented schema migration and seed commands.

### Exit criteria

- Unauthorized reads and writes fail for every protected collection.
- Contributors cannot read other users' responses or internal notes.
- Reviewers cannot access unassigned contexts.
- Response creation is duplicate-safe and context status/assignment is revalidated server-side.
- No client can modify ownership, audit fields, aggregates, or role data directly.

## 6. Phase 4: Core UI Shell and Shared Components

**Goal:** Build the reusable presentation layer required by all workflows.

### Tasks

1. Implement app shell, role-aware bottom navigation, app bars, and route transitions.
2. Create shared loading skeletons, empty states, offline banners, retry states, and permission-denied views.
3. Create accessible buttons, inputs, rating control, status chips, cards, list rows, dialogs, bottom sheets, and date selectors.
4. Apply the UI/UX design brief consistently across phone sizes and text scaling.
5. Implement keyboard-safe scrolling and focus/error behavior for forms.
6. Add semantic labels and accessibility identifiers for automated tests.
7. Create responsive layouts for narrow phones and larger devices without changing workflow rules.
8. Add global sign-out and session-loss handling.

### Deliverables

- Reusable component library in `shared/`.
- Navigation shell for all supported roles.
- State components covering loading, loaded, empty, offline, error, and permission denied.
- Accessibility and responsive layout baseline.

### Exit criteria

- Every asynchronous screen can render each required state.
- No route exposes inaccessible actions based only on hidden UI.
- Components pass basic widget tests and text scaling checks.

## 7. Phase 5: Contributor Core Workflow

**Goal:** Deliver the shortest and most important user journey: open a request, submit feedback, and confirm receipt.

### Tasks

1. Build contributor Home with assigned active contexts and recent responses.
2. Build fixed feedback form with context information, privacy statement, rating, review, and suggestion.
3. Add field validation and character limits.
4. Add local draft preservation where supported and discard confirmation.
5. Implement idempotent response creation with disabled duplicate-submit behavior.
6. Implement success confirmation and own response detail.
7. Build My Feedback history with status filters.
8. Handle already submitted, paused, closed, deleted, offline, and permission-denied scenarios.
9. Emit form-started, validation-failed, submitted, and failed analytics events without content.

### Deliverables

- Contributor Home.
- Feedback submission screen.
- Submission confirmation and own response detail.
- My Feedback list and filters.
- End-to-end contributor workflow tests.

### Exit criteria

- A contributor can complete a valid response in the expected mobile flow.
- A retry after a lost network response cannot create a duplicate.
- Response content is visible only according to ownership and visibility rules.
- All form and network states preserve user input appropriately.

## 8. Phase 6: Administrator Context Management

**Goal:** Allow administrators to create and control the experiences that receive feedback.

### Tasks

1. Build context list with status filtering and response counts.
2. Build create-context form with title, type, description, owner, visibility, dates, and assignments.
3. Implement Save Draft and Activate behavior with separate validation requirements.
4. Build edit-context flow and lifecycle transitions: Draft, Active, Paused, Closed.
5. Add assignment management for contributors and permitted reviewers.
6. Prevent invalid dates, invalid owners, and activation without required setup.
7. Add confirmation for close and other irreversible lifecycle changes.
8. Add audit activity for context and assignment mutations.
9. Add context list empty, filtered-empty, stale-update, and permission states.

### Deliverables

- Context management list.
- Create and edit context screens.
- Assignment management.
- Lifecycle mutation Functions/repositories.
- Context and assignment tests.

### Exit criteria

- An administrator can create a draft, activate it, pause it, and close it.
- Only active contexts appear as submit-ready contributor requests.
- Reviewers and contributors cannot mutate context configuration.
- Lifecycle and assignment changes are authorized, validated, and audited.

## 9. Phase 7: Administrator Inbox and Triage

**Goal:** Make feedback actionable through search, filters, ownership, and status workflow.

### Tasks

1. Build paginated administrator inbox with real-time updates where useful.
2. Add filters for context, rating, status, date range, and assignee.
3. Add explicit keyword search with bounded query behavior or document its MVP limitation.
4. Build administrative response detail with visibility-aware contributor identity.
5. Implement status transitions and transition timestamps.
6. Implement assignment and unassignment.
7. Implement internal notes as separate append-only activity documents.
8. Preserve filters and scroll position when returning from detail.
9. Add stale-data handling when another administrator changes a response.
10. Add audit and analytics events for status and assignment changes.

### Deliverables

- Admin inbox with pagination, filters, search, and empty states.
- Admin response detail.
- Status, assignment, and internal-note workflows.
- Audit activity timeline.
- Triage integration tests and Rules tests.

### Exit criteria

- An administrator can find, open, assign, annotate, and transition feedback.
- Invalid transitions are rejected by the backend.
- Internal notes never appear in contributor or unauthorized reviewer views.
- Inbox queries are bounded and use approved indexes.

## 10. Phase 8: Reviewer Experience

**Goal:** Provide read-only access to explicitly scoped review data.

### Tasks

1. Build reviewer Home and assigned-response list.
2. Reuse response detail with reviewer-specific field visibility.
3. Apply context scope and organization visibility rules.
4. Hide status, assignment, internal-note, and context-management mutations.
5. Add no-assignment, no-response, filtered-empty, and permission states.
6. Add reviewer route and direct-access tests.

### Deliverables

- Reviewer assigned feedback screen.
- Read-only response detail.
- Scoped query repositories and Rules tests.

### Exit criteria

- Reviewer access is limited to assigned contexts and permitted fields.
- Reviewer cannot mutate responses or access administrative notes.
- Direct Firestore access cannot bypass the read-only boundary.

## 11. Phase 9: Dashboard and Insights

**Goal:** Provide explainable summary metrics for administrators.

### Tasks

1. Implement aggregate maintenance on response create/status changes or use bounded queries for the pilot.
2. Build dashboard filters for date range and context.
3. Display response count, average rating, distribution, response rate, status counts, and recent attention items.
4. Include sample size, population, date range, and last-updated metadata.
5. Implement metric drill-down to correctly filtered Inbox views.
6. Add no-data, filtered-empty, stale-aggregate, and retry states.
7. Reconcile displayed metrics against seeded response fixtures.

### Deliverables

- Administrator dashboard.
- Aggregate maintenance/rebuild Function.
- Metric calculation tests and seeded-data reconciliation report.
- Dashboard query indexes and performance notes.

### Exit criteria

- Metrics update consistently when filters change.
- Rating distribution totals equal response count.
- No average is shown for zero responses.
- A metric drill-down preserves the selected scope in Inbox.

## 12. Phase 10: Integrations and Operational Services

**Goal:** Add only the backend integrations needed for a reliable MVP release.

### Tasks

1. Configure Firebase Analytics events from the approved event list.
2. Configure Crashlytics and verify that response text, suggestions, tokens, and passwords are excluded.
3. Configure App Check in monitoring mode, then enforce after validation.
4. Add optional in-app new/unresolved indicators.
5. Defer push notifications until permission, preference, payload, and opt-out behavior are approved.
6. Add Cloud Function structured logs, correlation IDs, and stable error= codes.
7. Add cost monitoring for Firestore reads/writes, listeners, and Function invocations.

### Deliverables

- Analytics event map and privacy review.
- Crashlytics/App Check configuration.
- Monitoring dashboards and alerts.
- Documented notification decision and deferred integration list.

### Exit criteria

- Analytics contains no feedback content or unnecessary personal data.
- Crash reports are actionable but privacy-safe.
- App Check does not block legitimate staging clients.
- Operational alerts identify auth, submission, authorization, and cost regressions.

## 13. Phase 11: Testing and Hardening

**Goal:** Verify behavior, security, accessibility, performance, and resilience before release.

### Tasks

1. Add unit tests for validation, status transitions, metrics, serialization, error mapping, and idempotency.
2. Add widget tests for all screens and shared states.
3. Add integration tests for contributor, reviewer, administrator, and owner journeys.
4. Run Firestore Rules tests against every collection and role boundary.
5. Test offline reads, queued submission, retry, duplicate prevention, and session expiration.
6. Test small screens, large screens, keyboard behavior, text scaling, and screen readers.
7. Test query pagination, listener cleanup, and dashboard latency with representative seed data.
8. Run dependency and secret scans.
9. Perform a manual privacy and data-exposure review.
10. Run a staging pilot with representative users and capture feedback.

### Deliverables

- Automated unit, widget, integration, Function, and Rules test suites.
- Accessibility and device test report.
- Security review and threat-model checklist.
- Performance/cost baseline.
- Staging pilot findings and prioritized fixes.

### Exit criteria

- All critical workflows and Rules tests pass on Android and iOS targets.
- No critical or high-severity authorization issue remains.
- Crash-free and submission reliability targets are acceptable for pilot release.
- All release acceptance scenarios from the PRD and app flow pass.

## 14. Phase 12: Deployment and Release

**Goal:** Promote a tested build and backend configuration safely.

### Tasks

1. Create separate staging and production Firebase projects/configurations.
2. Run CI format, analysis, unit/widget tests, emulator tests, and builds.
3. Deploy Firestore Rules and indexes after review.
4. Deploy Cloud Functions with backward-compatible field handling.
5. Build signed Android and iOS release artifacts.
6. Distribute staging build through internal testing channels.
7. Run production smoke tests with non-sensitive test accounts.
8. Release through staged mobile rollout.
9. Monitor Crashlytics, Auth, Firestore errors, submission completion, and cost for 24-48 hours.
10. Keep rollback procedures for app, Functions, and Rules separate and documented.

### Deliverables

- Production Firebase configuration and approved rules/index deployment.
- Signed Android and iOS artifacts.
- Release notes and versioned change log.
- Deployment record, smoke-test results, and rollback runbook.
- Monitoring and on-call ownership for the pilot.

### Exit criteria

- Production smoke tests pass for contributor and administrator workflows.
- Security Rules are deployed and verified against production configuration.
- App store/internal distribution requirements are complete.
- Product owner approves staged rollout.

## 15. Phase 13: Final Polish and Post-Launch Review

**Goal:** Remove friction revealed by real usage without expanding MVP scope.

### Tasks

1. Review funnel metrics against initial targets.
2. Fix the highest-impact submission abandonment and admin triage issues.
3. Review empty/error/offline copy using support and pilot feedback.
4. Confirm accessibility findings and remediate high-impact issues.
5. Tune Firestore listeners, indexes, pagination, and aggregate strategy based on measured usage.
6. Review privacy, retention, and deletion requests from the pilot.
7. Document known limitations and deferred features.
8. Create the next-release backlog from validated evidence.

### Deliverables

- Post-launch metrics report.
- Prioritized polish and defect backlog.
- Updated support/runbook documentation.
- Confirmed version-two candidates based on observed demand.

### Exit criteria

- No unresolved release-blocking defects.
- Pilot metrics and qualitative findings are reviewed with product and engineering.
- Follow-up work is prioritized without silently expanding the MVP.

## 16. Cross-Phase Definition of Done

A feature is complete only when:

- Its acceptance criteria and app-flow states are implemented.
- Domain, repository, UI, and Firebase boundaries are respected.
- Loading, empty, offline, validation, permission, success, and error states exist where relevant.
- Authorization is tested directly against Firebase emulators.
- Analytics and logs exclude sensitive content.
- Accessibility labels, focus order, and text scaling are checked.
- Unit/widget/integration coverage matches the risk of the change.
- Documentation and environment configuration are updated.
- `dart format`, `flutter analyze`, and relevant tests pass.

## 17. Suggested Milestone Sequence

| Milestone | Completed phases | Demonstrable outcome |
|---|---|---|
| Foundation | 0-3 | Secure app shell with Auth, schema, Rules, and emulator fixtures. |
| Contributor pilot | 4-5 | A contributor can sign in, see a request, submit once, and track it. |
| Operations pilot | 6-8 | Admins manage contexts and triage; reviewers have scoped read-only access. |
| Insight pilot | 9-10 | Administrators can trust dashboard metrics and operational monitoring. |
| Release candidate | 11-12 | Tested, signed, staged, and rollback-ready MVP. |
| Pilot improvement | 13 | Evidence-based polish and next-release backlog. |

## 18. Primary Risks to Track

| Risk | Trigger | Mitigation |
|---|---|---|
| Privacy model remains undecided | Visibility changes after response data exists | Decide before Phase 2 and version any future policy change. |
| Rules are added late | UI works but direct access is unsafe | Build emulator Rules tests in Phase 3 before feature completion. |
| Duplicate submissions | Network retry creates multiple records | Deterministic response ID and transaction-backed create. |
| Firestore costs grow unexpectedly | Large listeners or unbounded dashboard reads | Paginate, index, aggregate, and monitor reads from the first pilot. |
| Scope expands into a form platform | Requests for branching/custom question builder | Keep fixed MVP question set and defer advanced builder. |
| Admins cannot act on insights | Dashboard lacks drill-down or status workflow | Build Inbox, triage, and dashboard as one operational slice. |
