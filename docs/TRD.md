# Feedback & Review App

## Technical Requirements Document

**Status:** Draft  
**Related product document:** [PRD](PRD.md)  
**Target release:** MVP  
**Last updated:** 2026-08-31

## 1. Technical Overview

Feedback & Review App is a multi-tenant Flutter mobile application backed by Firebase. Contributors submit ratings, reviews, and suggestions for assigned feedback contexts. Administrators manage contexts, triage responses, and inspect aggregate metrics.

The MVP is mobile-only. Firebase is the managed backend boundary: Firebase Authentication handles identity, Cloud Firestore stores product data and synchronizes permitted changes, and Cloud Functions for Firebase provides trusted server-side operations where client-only writes would be unsafe or too complex.

### Technical goals

- Deliver one Android and iOS codebase with a consistent mobile experience.
- Enforce organization and role boundaries at the backend, not only in the UI.
- Make the submission path reliable under transient connectivity failures.
- Keep reporting queries bounded, indexed, and explainable.
- Minimize operational infrastructure for the first pilot.

### Out of scope for this document

- Detailed visual design specifications.
- Production legal policy wording.
- Implementation of deferred features such as AI analysis, public reviews, exports, and third-party integrations.

## 2. Frontend Stack

| Area | Requirement | Decision and reason |
|---|---|---|
| Framework | Flutter with Dart | Existing project foundation; one codebase for Android and iOS and predictable rendering. |
| UI | Flutter Material 3 | Accessible, responsive primitives with a mature mobile component system. |
| State management | Riverpod | Testable dependency injection and reactive state without coupling widgets to Firebase APIs. |
| Navigation | `go_router` | Declarative routes, auth redirects, deep-link support, and role-aware route guards. |
| Firebase client | Official FlutterFire packages | Supported integration for Auth, Firestore, Analytics, Crashlytics, and optional Messaging. |
| Form validation | `Form` and typed domain validators | Keeps the fixed MVP form simple and avoids introducing a form-builder abstraction prematurely. |
| Local persistence | Firestore offline persistence plus a small local draft store if needed | Firestore handles cached reads and queued writes; drafts should not be mixed with submitted response data. |
| Testing | `flutter_test`, integration tests, and Firebase Emulator Suite | Covers widget behavior, workflow behavior, and backend authorization locally. |
| Quality | `flutter_lints`, `dart format`, static analysis | Consistent code quality and low review friction. |

### Frontend module boundaries

```text
lib/
  app/                 App bootstrap, theme, router, dependency wiring
  core/                Errors, result types, constants, utilities
  auth/                Auth state, sign-in, sign-up, password reset
  organizations/       Membership and role models
  contexts/            Feedback context list and administration
  feedback/            Submission, history, inbox, detail, triage
  dashboard/           Aggregations and metric presentation
  shared/              Reusable widgets and loading/error states
```

UI code must call repositories or use cases, not instantiate Firestore queries directly. Domain models should be serializable and should not expose Firebase-specific document snapshots to widgets.

## 3. Backend Stack

| Area | Technology | Purpose |
|---|---|---|
| Identity | Firebase Authentication | Email/password sign-in, password reset, session persistence, and token claims. |
| Primary database | Cloud Firestore | Multi-tenant document storage, indexed queries, and real-time listeners. |
| Trusted backend | Cloud Functions for Firebase, TypeScript | Custom claims, invitation acceptance, aggregate maintenance, audit writes, and guarded administrative operations. |
| Analytics | Google Analytics for Firebase | Product funnel and usage events without feedback text. |
| Crash monitoring | Firebase Crashlytics | Mobile crash and non-sensitive failure monitoring. |
| Notifications | Firebase Cloud Messaging, post-MVP or opt-in MVP | New request and unresolved feedback notifications after preference and permission behavior are defined. |
| Local development | Firebase Local Emulator Suite | Reproducible Auth, Firestore, and Functions testing without production data. |

### Backend responsibilities

- Firestore Security Rules are the primary authorization control for every client read and write.
- Cloud Functions perform operations requiring trusted aggregation, privileged role changes, or multi-document consistency.
- Functions must validate input again even when the client validates it.
- Administrative actions create immutable activity records with actor and timestamp metadata.
- Aggregates must be treated as derived data and rebuildable from response documents.

## 4. Database Requirements

### Database choice

Use Cloud Firestore in Native mode. The product needs document-oriented records, organization-scoped access, real-time inbox updates, mobile offline support, and low infrastructure overhead. A relational database would be reasonable for complex cross-organization reporting, but it would add an API and operations layer before the MVP validates the workflow.

### Tenant strategy

Every organization-owned document contains `organizationId`. Client queries must include the organization scope and security rules must verify it. A user's organization memberships are stored separately from organization documents so membership checks can be performed in rules without trusting client-provided role fields.

### Collections

```text
users/{uid}
organizations/{organizationId}
organizations/{organizationId}/members/{uid}
organizations/{organizationId}/contexts/{contextId}
organizations/{organizationId}/contexts/{contextId}/questions/{questionId}
organizations/{organizationId}/responses/{responseId}
organizations/{organizationId}/assignments/{assignmentId}
organizations/{organizationId}/activity/{activityId}
```

### Core document shapes

**`users/{uid}`**

```text
displayName: string
email: string
createdAt: timestamp
updatedAt: timestamp
```

**`organizations/{organizationId}/members/{uid}`**

```text
uid: string
role: contributor | reviewer | administrator | owner
status: active | suspended | invited
displayName: string
createdAt: timestamp
updatedAt: timestamp
```

**`contexts/{contextId}`**

```text
organizationId: string
title: string
description: string
type: task | course | service | event | other
status: draft | active | paused | closed
ownerUid: string
visibility: identifiable | organization_only
startAt: timestamp | null
endAt: timestamp | null
createdAt: timestamp
updatedAt: timestamp
```

**`responses/{responseId}`**

```text
organizationId: string
contextId: string
contributorUid: string
rating: integer, 1..5
review: string, bounded length
suggestion: string, bounded length
status: new | in_review | actioned | archived
assignedToUid: string | null
createdAt: timestamp
updatedAt: timestamp
firstReviewedAt: timestamp | null
actionedAt: timestamp | null
```

**`activity/{activityId}`**

```text
organizationId: string
responseId: string | null
contextId: string | null
actorUid: string
type: status_changed | assigned | internal_note | context_changed
payload: map, validated and bounded
createdAt: timestamp
```

Internal notes should be stored as separate activity documents and excluded from contributor queries. Review text must not be copied into activity payloads or analytics events.

### Data integrity rules

- Generate response IDs client-side before submission and use a transaction or conditional create to make retries idempotent.
- Enforce one response per `contextId + contributorUid` using a deterministic submission key or a transaction-controlled submission marker.
- Use server timestamps for authoritative audit fields.
- Do not allow clients to set `organizationId`, `contributorUid`, status history, or actor identity to arbitrary values.
- Store timestamps in UTC and convert them to the organization timezone only for display and reporting.
- Add Firestore indexes only for confirmed query patterns, including context/status/date and context/rating/date combinations.

### Reporting approach

For small pilot organizations, the dashboard can query bounded response pages and calculate presentation values. Before scale-up, use a Cloud Function to maintain organization/context aggregate documents such as response count, rating sum, and rating distribution. Aggregates must include an update timestamp and a rebuild path for correction.

## 5. Authentication and Authorization

### Authentication requirements

- Use Firebase email/password authentication for MVP.
- Persist sessions using platform-appropriate secure Firebase behavior.
- Provide sign-up, sign-in, password reset, email verification policy, and sign-out.
- Treat Firebase ID tokens as the identity source; never accept a UID supplied by the client as proof of identity.
- Refresh tokens through the Firebase SDK and react to auth state changes centrally.

### Authorization model

Role access is organization-scoped:

| Role | Allowed capabilities |
|---|---|
| Contributor | Read assigned active contexts; create and read own responses; read own statuses. |
| Reviewer | Read explicitly assigned contexts and permitted response fields; no context or membership administration. |
| Administrator | Manage permitted contexts; read and triage responses in permitted organization scope; assign owners; add internal notes. |
| Owner | All administrator capabilities; manage membership, roles, retention settings, and organization configuration. |

Security Rules must verify:

1. The request is authenticated.
2. The user's membership exists and is active.
3. The membership belongs to the same organization as the target document.
4. The requested operation is allowed for the user's role.
5. Contributor reads and writes are limited to their own response records.
6. Immutable fields and server-managed fields are not changed by clients.

Custom claims may mirror a small set of global or primary role information for routing, but Firestore membership documents remain the source of truth for organization access. Role changes must be performed by a trusted Function and should force token refresh behavior.

## 6. API and Service Contracts

The Flutter app uses Firestore SDK repositories for ordinary CRUD and real-time reads. Callable Cloud Functions are used when a trusted server boundary is required. These are logical contracts; exact function names and schemas should be implemented with generated or shared typed models where practical.

### Firestore repository operations

```text
AuthRepository.signIn(email, password)
AuthRepository.signUp(email, password, displayName)
AuthRepository.sendPasswordReset(email)
ContextRepository.watchAssignedContexts()
ContextRepository.watchManagedContexts(filters)
ResponseRepository.createResponse(responseDraft)
ResponseRepository.watchOwnResponses()
ResponseRepository.watchInbox(filters, page)
ResponseRepository.updateStatus(responseId, status)
ResponseRepository.assign(responseId, assigneeUid)
DashboardRepository.watchMetrics(filters)
```

Repositories expose domain results and typed failures such as `unauthorized`, `validation`, `offline`, `notFound`, and `unknown`; Firebase exceptions should not leak into presentation code.

### Callable Functions

**`createOrganization`**

- Caller: authenticated user during approved onboarding flow.
- Input: organization name.
- Output: organization ID and owner membership.
- Rules: validate name, create organization and owner membership atomically.

**`inviteMember`**

- Caller: owner or administrator according to policy.
- Input: organization ID, email, role.
- Output: invitation ID and expiry timestamp.
- Rules: validate role assignment, prevent cross-tenant access, do not reveal unnecessary account existence data.

**`setMemberRole`**

- Caller: owner only.
- Input: organization ID, member UID, new role.
- Output: updated membership metadata.
- Rules: prevent removing the last owner; write an activity record; validate token refresh path.

**`rebuildOrganizationAggregates`**

- Caller: owner or internal operations only.
- Input: organization ID and optional context ID.
- Output: rebuild job result.
- Rules: rate limit and audit invocation; never expose arbitrary organization data.

### Error contract

All callable functions return a stable error code and safe user-facing message. Detailed stack traces belong in server logs only. Suggested codes: `unauthenticated`, `permission-denied`, `invalid-argument`, `already-exists`, `not-found`, `failed-precondition`, and `internal`.

## 7. Application Architecture

Use a feature-oriented clean architecture with one-way data flow:

```text
Flutter widgets
    -> controllers/providers
        -> use cases
            -> repositories
                -> Firebase SDK / callable Functions
                    -> Auth, Firestore, Functions, Analytics, Crashlytics
```

### Layer responsibilities

- **Presentation:** Screens, widgets, form state, accessibility labels, loading/error/empty states.
- **Application:** Use cases, workflow orchestration, authorization-aware view models, retry behavior.
- **Domain:** Immutable entities, enums, validation rules, and repository interfaces.
- **Data:** Firestore DTOs, converters, query builders, Firebase exception mapping, and callable clients.
- **Infrastructure:** Firebase initialization, environment configuration, logging, analytics, and crash reporting.

### State and synchronization

- Auth state is a top-level stream that controls the router.
- Firestore streams are used for active inbox and status views where real-time updates have clear value.
- One-shot reads are preferred for stable configuration and detail views without collaboration needs.
- The UI must represent `loading`, `loaded`, `empty`, `offline`, `permissionDenied`, and `error` states.
- Submission controls become disabled after the first accepted attempt and use idempotent creation on retry.

### Navigation

```text
/auth/sign-in
/auth/sign-up
/home
/contexts/:contextId/submit
/responses
/responses/:responseId
/admin/contexts
/admin/inbox
/admin/dashboard
/settings
```

The router redirects unauthenticated users to auth and prevents contributor access to administrator routes. Backend rules remain authoritative.

## 8. Security Requirements

### Application security

- Configure Firebase Security Rules with default deny behavior.
- Test every collection for unauthenticated, cross-organization, wrong-role, and field-tampering cases.
- Validate string lengths, rating range, enum values, timestamps, and document size at both client and server boundaries.
- Use App Check where supported and monitor invalid requests; do not treat App Check as a replacement for authorization.
- Do not log review text, suggestions, passwords, tokens, or raw personal data.
- Restrict internal notes to permitted administrator and owner queries.
- Use HTTPS/TLS for all service communication through Firebase SDKs and Functions.
- Keep Firebase configuration values separate from secrets; never commit service-account credentials.

### Privacy and data governance

- Document whether each context is identifiable or organization-only before submission.
- Collect only display name, email, membership, response content, and audit data required for the product.
- Define retention, deletion, correction, and account deletion behavior before production launch.
- Make deletion and export requests auditable and authorization-protected.
- Avoid sending response content to third-party analytics or crash tools.
- Review data residency, age-related requirements, and organizational privacy obligations for the pilot market.

### Abuse and resilience

- Rate limit invitation and callable administrative operations.
- Enforce context status and assignment checks on response creation.
- Monitor unusual submission volume and repeated failed authentication attempts.
- Apply Firestore quotas, query limits, pagination, and bounded text fields to reduce cost and denial-of-service risk.

## 9. Deployment and Environment Plan

### Environments

| Environment | Firebase project | Purpose |
|---|---|---|
| Local | Emulator Suite | Development and security-rule tests; no production data. |
| Staging | Dedicated Firebase project | QA, internal pilot, release-candidate verification. |
| Production | Dedicated production project | Real organizations and monitored releases. |

Each environment must have separate Auth users, Firestore data, Functions configuration, Analytics destination, and app identifiers where feasible. Environment selection belongs in build configuration, not ad hoc source edits.

### CI/CD pipeline

1. Run `dart format --output=none --set-exit-if-changed .`.
2. Run `flutter analyze`.
3. Run unit and widget tests.
4. Start Firebase emulators and run Firestore rules and integration tests.
5. Build Android and iOS artifacts using environment-specific configuration.
6. Deploy Functions, Firestore rules, and indexes after review.
7. Distribute staging builds through internal testing channels.
8. Promote the approved build to production with a versioned release note and rollback plan.

### Release strategy

- Use staged rollout for mobile binaries.
- Deploy security rules before features that depend on them, with backward-compatible field handling.
- Keep database migrations additive where possible.
- Monitor Crashlytics, auth failures, Firestore errors, submission completion, and read/write costs for at least 24 hours after release.
- Roll back the app binary or Functions deployment independently when possible; never roll back rules blindly without checking existing clients.

### Required project configuration

- FlutterFire-generated options per environment.
- Firebase project aliases in `.firebaserc`.
- Firestore rules and indexes under version control.
- Functions source and lockfile under version control.
- CI secrets stored in the CI provider, not in the repository.
- Android signing and iOS certificates managed through the team’s secure release system.

## 10. Observability and Operations

Monitor:

- Crash-free users and crash-free sessions.
- Authentication failure rate and password reset completion.
- Feedback submission success, duplicate prevention, and retry failures.
- Firestore read/write volume and Function invocation errors.
- Dashboard query latency and empty/error rates.
- Unauthorized request attempts and denied rule evaluations where available.

Use correlation IDs for callable operations and audit IDs for administrative mutations. Alerts should be actionable and should not include feedback content in notification payloads.

## 11. Testing Requirements

### Unit tests

- Rating and text validation.
- Status transition rules.
- Date-range metric calculations.
- DTO serialization and Firebase error mapping.
- Idempotent response key generation.

### Widget and integration tests

- Auth redirect and role-based navigation.
- Contributor submission success, validation, offline retry, and duplicate prevention.
- Administrator context creation, inbox filtering, assignment, status change, and dashboard filters.
- Loading, empty, permission-denied, and recoverable error states.

### Backend tests

- Firestore Rules Emulator tests for every role and organization boundary.
- Callable Function authentication, validation, authorization, and error contract tests.
- Aggregate maintenance and rebuild tests.
- Seeded-data reconciliation tests for dashboard metrics.

### Release gates

- No static analysis errors.
- All critical workflow tests pass on Android and iOS targets.
- No known critical or high-severity authorization defect.
- Security Rules tests pass against the staged ruleset.
- Crash reporting and analytics privacy checks pass.

## 12. Technical Decisions and Alternatives

| Decision | Reason | Rejected or deferred alternative |
|---|---|---|
| Flutter for client | Existing codebase and shared Android/iOS implementation. | Separate native apps would double feature and QA cost. |
| Firebase Auth | Fast MVP identity lifecycle with a supported Flutter integration. | Custom auth would create unnecessary security and operations risk. |
| Cloud Firestore | Real-time streams, offline support, and document-shaped tenant data. | A custom REST API plus SQL adds infrastructure before scale needs are known. |
| Repository boundary | Keeps Firebase SDK details out of widgets and makes testing practical. | Direct Firestore calls from screens create coupling and inconsistent error handling. |
| Firestore Rules plus Functions | Rules protect every client path; Functions handle trusted multi-step operations. | UI-only role checks are insufficient; a custom backend is too large for MVP. |
| Fixed feedback form | Proves the submission-to-insight loop with minimal schema and UI complexity. | A full form builder delays validation of the core product. |
| Client-generated idempotency key | Prevents duplicate submissions during retries without requiring a separate queue service. | Blind `add()` writes can duplicate when a network response is lost. |
| Derived aggregates | Makes dashboard reads cheaper and predictable as data grows. | Recomputing all responses on every dashboard load will not scale. |
| Separate staging and production Firebase projects | Prevents test data and rules experiments from affecting real users. | A shared project creates avoidable privacy and release risk. |
| In-app indicators before push | Avoids notification fatigue and permission complexity while measuring demand. | Push-first design adds operational and UX requirements before validation. |

## 13. Implementation Sequence

1. Add FlutterFire configuration and environment bootstrap.
2. Implement domain models, repository interfaces, and Firebase converters.
3. Implement Auth and organization membership loading.
4. Write and test Firestore Rules before exposing production-like screens.
5. Build contributor context list, submission form, idempotent create flow, and history.
6. Build administrator context management, inbox, detail, and triage actions.
7. Add dashboard queries and seeded-data metric tests.
8. Add analytics, Crashlytics, offline/error states, and accessibility checks.
9. Configure staging CI/CD and complete release acceptance gates.

## 14. Open Technical Questions

1. Will the pilot require invitation links, email invitations, or both?
2. Should one user be allowed to belong to multiple organizations in MVP?
3. Is organization-only visibility sufficient, or is true anonymity a launch requirement?
4. What maximum lengths should apply to reviews and suggestions for the pilot?
5. Which dashboard metrics require precomputed aggregates at expected pilot volume?
6. What minimum Android and iOS versions must be supported?
7. Which Firebase region and data residency constraints apply to the initial customers?