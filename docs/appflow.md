# Feedback & Review App

## Application Flow Specification

**Status:** Draft  
**Source:** [PRD](PRD.md) and [TRD](TRD.md)  
**Target:** MVP mobile application  
**Last updated:** 2026-08-31

This document is the implementation contract for screens, navigation, user actions, button behavior, and UI states. When a behavior is not explicitly described here, use the technical requirements and the platform's standard Flutter behavior rather than inventing a new workflow.

## 1. Product Roles and Navigation Model

### Roles

- **Contributor:** submits and tracks personal feedback.
- **Reviewer:** reads assigned contexts and permitted response data; cannot administer contexts or membership.
- **Administrator:** manages permitted contexts, reads feedback, and triages responses.
- **Owner:** has administrator access plus organization and member management.

The active role is loaded from the authenticated user's organization membership. A user may belong to multiple organizations in a later release; MVP assumes one active organization. Never use a client-side role check as authorization. Firestore Security Rules remain authoritative.

### Global navigation

Authenticated users see a role-appropriate bottom navigation bar:

| Tab | Contributor | Reviewer | Administrator / Owner |
|---|---:|---:|---:|
| Home | Yes | Yes | Yes |
| Feedback / Inbox | My feedback | Assigned reviews | Feedback inbox |
| Dashboard | No | Optional read-only if permitted | Yes |
| Settings | Yes | Yes | Yes |

Use a menu or action button from Home for administrator context management. Do not show inaccessible tabs and then show an authorization error.

### Route table

| Route | Screen | Access |
|---|---|---|
| `/splash` | Bootstrap screen | All |
| `/auth/sign-in` | Sign in | Signed out |
| `/auth/sign-up` | Create account | Signed out |
| `/auth/forgot-password` | Reset password | Signed out |
| `/onboarding/privacy` | Privacy and product introduction | First authenticated launch |
| `/onboarding/organization` | Join or create organization | Authenticated users without membership |
| `/home` | Role-aware home | Authenticated members |
| `/contexts/:contextId/submit` | Feedback form | Assigned contributor, active context |
| `/responses` | My feedback or reviewer inbox | Contributor or reviewer |
| `/responses/:responseId` | Response detail | Owner or permitted reviewer/admin |
| `/admin/contexts` | Context management | Administrator or owner |
| `/admin/contexts/new` | Create context | Administrator or owner |
| `/admin/contexts/:contextId/edit` | Edit context | Administrator or owner with permission |
| `/admin/inbox` | Feedback inbox | Administrator, owner, permitted reviewer |
| `/admin/dashboard` | Insights dashboard | Administrator or owner; reviewer if granted |
| `/settings` | Account and privacy settings | Authenticated members |
| `/settings/members` | Organization members | Owner, or admin if policy permits |
| `/settings/member-invite` | Invite member | Owner/admin if policy permits |
| `/error/permission-denied` | Permission error | Any authenticated user |
| `/error/unavailable` | Service unavailable | Any user |

## 2. Global UI and State Contract

Every data-backed screen must implement these states:

### Loading

- Show a stable skeleton or progress indicator in the content area.
- Preserve the app bar, title, and navigation structure where possible.
- Disable destructive or submitting actions until required data is available.
- Never show an empty state while the first request is still loading.

### Loaded

- Render content from the latest authorized data.
- Show the last updated time for dashboard and inbox data where useful.
- Real-time listeners update visible data without resetting scroll position or active filters.

### Empty

- Explain what is empty in plain language.
- Provide one relevant next action if the user's role can take one.
- Distinguish `No feedback yet` from `No feedback matches these filters`.
- Do not display fake metrics such as an average rating of zero when there are no responses.

### Offline

- Show a non-blocking offline banner when cached content is available.
- Mark queued writes as `Waiting to sync`.
- Allow cached reading where safe.
- For actions that require server confirmation, show `This action needs a connection` and a `Retry` button.

### Recoverable error

- Explain that the request failed without exposing Firebase exception details.
- Provide `Retry`.
- Preserve entered form values and active filters.
- Log a non-sensitive diagnostic event.

### Permission denied

- Show `You don't have access to this content.`
- Provide `Go to Home`.
- Do not reveal whether another user's document exists.
- On a denied route, replace the route rather than leaving a broken detail screen in the back stack.

### Destructive or irreversible action

- Use a confirmation dialog with a specific consequence.
- Buttons: `Cancel` and a clearly labeled confirm action.
- Do not use a generic `OK` for a destructive confirmation.

### Buttons and interaction rules

- A primary button has one clear action and shows a progress indicator while in flight.
- Prevent double taps during submission or mutation.
- A back action must preserve unsaved input by showing a discard confirmation when a non-empty draft exists.
- Every icon-only button has a tooltip or semantic label.
- Forms scroll when the keyboard opens and keep the active field visible.
- Rating controls expose the selected value to screen readers, for example `4 out of 5`.

## 3. Startup, Authentication, and Onboarding

### 3.1 Splash / bootstrap screen

**Route:** `/splash`

**Purpose:** Initialize Firebase, restore the auth session, load membership, and choose the first route.

**Visible elements:** App mark, progress indicator, no interactive controls during normal startup.

**Decision flow:**

1. Firebase initialization succeeds and no user is signed in: navigate to `/auth/sign-in`.
2. A signed-in user has no completed privacy onboarding: navigate to `/onboarding/privacy`.
3. A signed-in user has no active organization membership: navigate to `/onboarding/organization`.
4. A signed-in member has a valid role: navigate to `/home`.

**Error state:** Show `We couldn't start the app.` with `Try again`. If retry fails, show `Continue offline` only when cached session data is safe and sufficient; otherwise offer `Contact support` or close/retry according to platform behavior.

### 3.2 Sign-in screen

**Route:** `/auth/sign-in`

**Fields:** Email, password.

**Actions:**

- `Sign in`: validate fields, dismiss keyboard, call Firebase Auth, then route based on membership and onboarding state.
- `Create account`: navigate to `/auth/sign-up`.
- `Forgot password?`: navigate to `/auth/forgot-password`.
- Password visibility icon: toggle obscured/plain text; retain value.

**Validation:** Email is required and valid. Password is required. Show field-level messages below the relevant field.

**Success:** Disable the button during authentication, show a progress indicator, then route to the correct authenticated destination. Do not briefly show Home before membership is loaded.

**Errors:**

- Invalid credentials: `Email or password is incorrect.` Keep fields populated.
- Too many attempts: `Too many attempts. Try again later.`
- Offline/server failure: `We couldn't sign you in.` with `Retry`.
- Unverified email, if verification is enabled: show verification guidance and `Resend email`.

### 3.3 Create account screen

**Route:** `/auth/sign-up`

**Fields:** Display name, email, password, confirm password.

**Actions:**

- `Create account`: validate, create Firebase account, create the user profile, and route to privacy onboarding.
- `Already have an account? Sign in`: return to `/auth/sign-in`.
- Password visibility controls: toggle each password field.

**Validation:** Display name is required and bounded. Email must be valid. Password must meet the configured minimum. Confirmation must match. Show errors without clearing valid fields.

**Success:** Show a short progress state, then `/onboarding/privacy`. If account creation succeeds but profile creation fails, keep the session and show a retryable profile setup state rather than creating a second account.

**Errors:** Existing email, weak password, invalid email, offline/server failure, or account creation interruption. Each has safe text and a retry path.

### 3.4 Forgot password screen

**Route:** `/auth/forgot-password`

**Fields:** Email.

**Actions:**

- `Send reset link`: validate and request Firebase password reset.
- `Back to sign in`: navigate to `/auth/sign-in`.

**Success:** Show `Check your email for a password reset link.` Keep the entered email visible but not editable unless the user chooses to return. `Back to sign in` is the primary next action.

**Errors:** Invalid email format and recoverable network failure. Avoid revealing whether an account exists; use the same safe confirmation pattern for a syntactically valid email.

### 3.5 Privacy and product introduction

**Route:** `/onboarding/privacy`

**Purpose:** Establish trust before the first response.

**Content:** What feedback is used for, who can view responses, whether the current organization uses identifiable responses, and a link/action for privacy details.

**Actions:**

- `Continue`: record onboarding completion and route to organization onboarding or Home.
- `Sign out`: sign out and return to sign-in.

**Success:** Completion is stored idempotently. Back navigation is disabled until completion or sign-out.

**Error:** If completion cannot be stored, show `Couldn't save your preference.` with `Retry`; do not silently route as though it was saved.

### 3.6 Join or create organization

**Route:** `/onboarding/organization`

**MVP behavior:** Show an invitation acceptance path. If organization creation is enabled for the pilot, also show a create path for the first owner.

**Actions:**

- `Join organization`: accept a valid invitation and load membership.
- `Create organization`: open a name form; call `createOrganization`.
- `Sign out`: return to sign-in.

**Success:** Show the organization name and role briefly, then route to Home.

**Empty state:** `You don't have an organization yet.` Explain that an owner must invite the user and provide `Refresh invitations`.

**Errors:** Expired invitation, invalid invitation, already accepted, permission denied, duplicate organization name, and unavailable service. Preserve the invitation code or typed organization name for retry where safe.

## 4. Home Screen

**Route:** `/home`

**Purpose:** Give each role a clear next action and a concise status overview.

### Shared content

- Greeting using display name.
- Organization name and a way to switch organization only if multi-organization support is enabled.
- Unread/new feedback indicator where applicable.
- Settings icon leading to `/settings`.
- Role-appropriate bottom navigation.

### Contributor view

**Content:** Active assigned feedback requests, due/end date when present, and recent submitted responses.

**Actions:**

- Tap a request card: open `/contexts/:contextId/submit`.
- `View all feedback`: open `/responses`.
- Pull to refresh: reload assigned contexts and own responses.
- Bottom `Feedback`: open `/responses`.

**Success state:** After submitting, the request card changes to `Submitted` and moves to recent feedback.

**Empty states:**

- No assigned requests: `You're all caught up.` with `Your organization will show new requests here.`
- No response history: omit the history section rather than showing a misleading zero.

### Reviewer view

**Content:** Assigned contexts, count of responses needing review if available, and shortcut to permitted feedback.

**Actions:** Tap context or `View assigned feedback` to open `/responses` with the relevant scope. Dashboard shortcut appears only if granted.

**Empty state:** `No reviews assigned yet.`

### Administrator / owner view

**Content:** New, in-review, and actioned counts; recent feedback requiring attention; active context count; shortcuts to Inbox, Dashboard, and Contexts.

**Actions:**

- `Review feedback`: `/admin/inbox`.
- `View dashboard`: `/admin/dashboard`.
- `Manage contexts`: `/admin/contexts`.
- `Create context`: `/admin/contexts/new`.
- Tap recent feedback: `/responses/:responseId`.

**Empty state:** `No feedback has been submitted yet.` with `Create a context` for permitted users.

## 5. Contributor Feedback Flow

### 5.1 Feedback form

**Route:** `/contexts/:contextId/submit`

**Entry conditions:** User is an authenticated contributor, has permission for the context, the context is active, and no submitted response exists. The backend rechecks all conditions.

**Content:** Context title, type, description, expected completion time, privacy/visibility statement, 1-to-5 rating, optional review, optional suggestion, and submit action.

**Fields:**

- Rating: required, exactly one value from 1 through 5.
- Review: optional, bounded length; show remaining character count.
- Suggestion: optional, bounded length; show remaining character count.

**Actions:**

- `1` to `5` rating control: set selected rating and accessible label; tapping a new value replaces the previous value.
- Review/suggestion fields: accept text, preserve draft locally where supported.
- `Submit feedback`: validate, dismiss keyboard, confirm if configured by product design, then create response idempotently.
- Back/close: if any field has content, show `Discard feedback?` with `Keep editing` and `Discard`; if empty, return immediately.
- Privacy information link: open a modal or dedicated detail view without losing form data.

**Validation errors:**

- No rating: `Select a rating to continue.` Focus or scroll to rating.
- Text over maximum: show the limit and prevent submission.
- Context no longer active: `This feedback request is no longer accepting responses.` Offer `Back to Home`.
- Already submitted: navigate to the existing response detail and show `You already submitted feedback for this request.`

**Submission in progress:** Disable submit and back-triggered duplicate actions, show `Submitting...`, and retain all data.

**Success:** Navigate to `/responses/:responseId` in confirmation mode. The detail screen must show a clear `Feedback submitted` confirmation, submitted timestamp, rating, response content, visibility policy, and status `New`.

**Network failure:** Keep the draft. Show `Couldn't submit your feedback.` with `Retry`. If Firestore has queued the write, show `Waiting to sync` and do not create another response on retry.

### 5.2 Submission confirmation and own response detail

**Route:** `/responses/:responseId`

**Contributor view:** Context title, submitted date, rating, review, suggestion, privacy statement, current status, and status updated date.

**Actions:**

- `Back to Home`: `/home`.
- `View all feedback`: `/responses`.
- Back navigation: returns to the previous contributor screen.

There is no edit action in MVP unless explicitly enabled by product configuration. Do not imply that status `Actioned` means the user's suggestion was accepted; label it as workflow status.

**Success state:** Show submitted confirmation only for the first route visit after creation; subsequent visits show normal details.

**Empty/error states:** Missing or deleted response shows `This feedback is no longer available.` with `Go to Home`. Permission denied uses the global permission state.

### 5.3 My feedback screen

**Route:** `/responses` for contributors

**Content:** Own submitted responses, newest first. Each item shows context title, rating, submitted date, and status chip.

**Actions:**

- Tap item: open own response detail.
- Pull to refresh: reload list.
- Optional status filter: select `All`, `New`, `In review`, `Actioned`, or `Archived`; `Clear filters` restores All.

**Empty state:** `You haven't submitted feedback yet.` with `Go to Home`.

**Filtered empty state:** `No feedback matches this filter.` with `Clear filters`.

## 6. Reviewer and Administrator Feedback Review Flow

### 6.1 Reviewer feedback list

**Route:** `/responses` for reviewers

**Content:** Responses from explicitly permitted contexts, newest first. Identity fields are shown only when policy allows. Internal notes are never shown.

**Actions:** Tap a response to open detail; pull to refresh; use permitted filters. Reviewers cannot change status, assignment, or notes unless a future permission explicitly grants it.

**Empty states:** No assigned contexts, no responses in assigned contexts, and no filter matches must have distinct messages.

### 6.2 Administrator inbox

**Route:** `/admin/inbox`

**Content:** Paginated or incrementally loaded response list. Each row shows rating, context title, truncated review preview if permitted, status, assigned owner, contributor identity according to visibility, and date.

**Filter controls:** Context, rating, status, date range, assigned owner. Filters are applied through bounded queries and are reflected in the screen title or filter summary.

**Search:** Search written feedback by keyword where supported. Search is explicit on submit/confirm, not on every keystroke if that would create excessive reads.

**Actions:**

- Tap response: open `/responses/:responseId` with admin controls.
- `Filter`: open a bottom sheet; `Apply` updates the list; `Clear all` resets filters; `Cancel` keeps current filters.
- Search field: enter query, `Search` applies, clear icon removes query.
- Pull to refresh: reload first page while preserving filters.
- Scroll near bottom: load next page; show an inline loader.
- Tap status chip: open status selector only if changing status is allowed.
- `Create context`: open `/admin/contexts/new`.

**Loaded empty states:**

- No organization feedback: `No feedback has been submitted yet.` with `Create a context`.
- Filtered empty: `No feedback matches these filters.` with `Clear all`.
- Search empty: `No feedback contains “{query}”.` with `Clear search`.

**Errors:** Failed initial load shows full-page retry. Failed next page shows inline `Couldn't load more` with `Retry`. Permission denial routes to the permission screen.

### 6.3 Response detail for administration

**Route:** `/responses/:responseId`

**Admin content:** Context metadata, response rating and text, contributor identity only if permitted, visibility policy, status, assigned owner, timestamps, and activity history. Internal notes are visually distinct from contributor content.

**Actions:**

- `Change status`: open selector with `New`, `In review`, `Actioned`, `Archived`; selecting a value requires confirmation if it is a forward workflow mutation. Save only after backend success.
- `Assign`: open permitted member selector; `Assign` saves; `Unassign` is available where policy permits.
- `Add internal note`: open text input; `Save note` validates bounded content and writes a separate activity record.
- `View context`: open context detail/edit based on permission.
- Back: return to Inbox with filters and scroll position preserved where possible.

**Status behavior:**

- New -> In review: set `firstReviewedAt` once and record activity.
- In review -> Actioned: set `actionedAt` and record activity.
- Any active status -> Archived: record activity; require confirmation.
- Archived -> In review: allowed only to administrator/owner and records activity.
- Invalid transitions are rejected by the backend and shown as `This feedback changed elsewhere. Refresh and try again.`

**Mutation success:** Update the detail screen immediately from the confirmed server response, show a brief non-blocking confirmation such as `Status updated`, and update the inbox on return.

**Mutation errors:** Keep the previous value visible, re-enable the control, show a retry action, and never claim success before the write is confirmed.

**Empty/error states:** Deleted response uses `This feedback is no longer available.` with `Back to Inbox`. Missing activity shows `No activity recorded yet.` rather than an error.

## 7. Administrator Context Management

### 7.1 Context list

**Route:** `/admin/contexts`

**Content:** Contexts grouped or filterable by status: Draft, Active, Paused, Closed. Each row shows title, type, status, dates, owner, and response count when available.

**Actions:**

- `Create context`: `/admin/contexts/new`.
- Tap context: open edit/detail route.
- Status filter: switch list query; `Clear` restores all.
- Pull to refresh.

**Empty states:** No contexts shows `Create your first feedback context.` with the primary create action. A filtered empty list shows `No contexts match this status.`

### 7.2 Create context screen

**Route:** `/admin/contexts/new`

**Fields:** Title, type, description, owner, status, visibility, optional start date, optional end date, and intended audience/assignment selection. MVP questions are fixed: rating, review, suggestion.

**Actions:**

- `Save draft`: validate required fields and create a Draft context.
- `Activate`: validate all activation requirements, create/activate context, and return to context detail/list.
- `Cancel`: discard empty form or confirm discard when populated.
- Date pickers: choose dates; end date cannot precede start date.
- Owner/member selector: choose only permitted active members.
- Visibility selector: choose `Identifiable` or `Organization only`; show explanatory text.

**Activation requirements:** Title, type, description, owner, valid audience/assignment, visibility, and valid date range where dates are provided.

**Success:** Show `Context created` or `Context activated`, then open context detail. The new context appears in the list and assigned contributors' Home when active.

**Errors:** Field validation stays local. Backend conflict, permission, offline, or duplicate request errors preserve all fields and show retry. If a context is created but the follow-up assignment fails, show the context as Draft/Needs setup according to backend state; never silently claim all contributors were assigned.

### 7.3 Edit context screen

**Route:** `/admin/contexts/:contextId/edit`

**Actions:**

- `Save changes`: validate and update editable fields.
- `Activate`, `Pause`, `Close`: invoke the lifecycle mutation; close requires confirmation.
- `Manage assignments`: select permitted contributors/reviewers if included in pilot.
- `View responses`: `/admin/inbox` filtered to this context.
- Back: return to context list; prompt if unsaved changes exist.

**Lifecycle behavior:** Paused and closed contexts remain readable to permitted administrators and contributors with existing responses but cannot accept new submissions. Re-activation is allowed only when dates and required setup are valid.

**Success:** Show updated status and return to detail/list while preserving the updated data.

**Errors:** Stale update, permission denied, invalid lifecycle transition, offline, or deleted context. Preserve form values and offer refresh/retry.

## 8. Dashboard Flow

**Route:** `/admin/dashboard`

**Access:** Administrator/owner, and reviewer only if explicitly granted read-only dashboard access.

**Content:** Filter bar, selected date range and context, total responses, average rating, rating distribution, response rate when invitations are tracked, status counts, lowest-rated/highest-volume contexts, and recent feedback requiring attention.

**Actions:**

- Date range selector: choose a supported range; `Apply` reloads metrics.
- Context selector: choose one context or `All contexts`; `Apply` reloads.
- `Reset filters`: restore the default date range and all contexts.
- Tap a metric/card: navigate to Inbox with the corresponding filter, if drill-down is meaningful.
- Pull to refresh: refresh metrics without changing filters.

**Metric rules:** Always show date range, context population, response count/sample size, and last updated time. Average rating is not displayed as zero when there are no responses. Rating distribution totals must reconcile with the selected response count.

**Empty states:**

- No data in selected range: `No responses in this period.` with `Reset filters`.
- Organization has no responses: `Insights will appear after the first response.` with `Manage contexts`.
- Aggregate data unavailable: show a recoverable error and `Retry`; do not display stale values without labeling them.

**Success:** Filters update all dependent metrics together. A metric tap opens a correctly scoped Inbox query.

## 9. Settings and Organization Administration

### 9.1 Settings screen

**Route:** `/settings`

**Content:** Display name, email, organization and role, privacy/visibility information, app version, and sign-out action.

**Actions:**

- `Edit profile`: edit display name and save.
- `Change password`: request current/new password flow according to Firebase Auth capability.
- `Privacy information`: show current organization visibility policy.
- `Manage members`: visible to owner and permitted administrator; `/settings/members`.
- `Sign out`: show confirmation, sign out, clear user-scoped providers/cache, route to sign-in.

**Success:** Show a non-blocking confirmation and updated profile values.

**Errors:** Profile update or password update failures preserve fields and show retry. Sign-out failure shows retry; do not leave a misleading signed-in UI if the auth state has already ended.

### 9.2 Members screen

**Route:** `/settings/members`

**Access:** Owner; administrator only if organization policy grants member administration.

**Content:** Active, invited, and suspended members with display name, email where allowed, role, and status.

**Actions:**

- `Invite member`: `/settings/member-invite`.
- Tap member: open role/status actions.
- `Change role`: choose an allowed role and confirm.
- `Suspend member`: confirm consequence; prevent suspending the last owner.
- Pull to refresh.

**Empty state:** `No members yet.` with `Invite member`.

**Errors:** Invitation failure, role mutation failure, last-owner constraint, permission denied, and stale member state. Refresh before retrying a stale mutation.

### 9.3 Invite member screen

**Route:** `/settings/member-invite`

**Fields:** Email, role, optional context scope if reviewer permissions require it.

**Actions:**

- `Send invitation`: validate and call `inviteMember`.
- `Cancel`: return to Members; confirm discard if populated.

**Success:** Show invitation expiry and `Invitation sent` without revealing whether a pre-existing account is registered. Return to Members after acknowledgment.

**Errors:** Invalid email, invalid role assignment, rate limit, permission denied, offline, and server failure. Preserve non-sensitive form values.

## 10. End-to-End Navigation Paths

### Contributor: first response

`Splash -> Sign in -> Privacy onboarding -> Join organization -> Home -> Tap active request -> Feedback form -> Submit feedback -> Own response confirmation -> Home`

### Contributor: returning user

`Splash -> Home -> Feedback tab -> My feedback -> Response detail`

### Contributor: interrupted submission

`Home -> Feedback form -> Enter fields -> Back -> Keep editing` or `Discard`; on network failure `Retry` retains the draft and uses the same idempotency key.

### Administrator: create and review

`Home -> Create context -> Save draft/Activate -> Context detail -> Home -> Inbox -> Filter/search -> Response detail -> Change status -> Assign -> Add internal note -> Back to Inbox`

### Administrator: investigate dashboard metric

`Home -> Dashboard -> Select date/context filters -> Tap status or low-rating metric -> Filtered Inbox -> Response detail -> Triage`

### Owner: invite administrator

`Home -> Settings -> Manage members -> Invite member -> Send invitation -> Members`

### Unauthorized route

`Any authenticated route -> Permission denied -> Go to Home`

### Session expiration

`Any authenticated screen -> Firebase auth state changes to signed out -> clear user-scoped state -> Sign in`; preserve no sensitive content in navigation arguments or local logs.

## 11. State and Copy Checklist for the Coding Agent

Implement explicit states for every asynchronous operation:

- Initial loading.
- Pull-to-refresh loading.
- Pagination loading.
- Form validation failure.
- Mutation in progress.
- Mutation success.
- Offline with cached data.
- Offline with no cached data.
- Permission denied.
- Not found/deleted.
- Recoverable server failure.

Use stable status labels: `New`, `In review`, `Actioned`, and `Archived`. Use stable context labels: `Draft`, `Active`, `Paused`, and `Closed`. Do not expose raw enum names, Firebase errors, document IDs, or stack traces in user-facing text.

## 12. Analytics and Accessibility Hooks

Emit the PRD events at the action boundary, not merely when a screen opens: form started, validation failed, submission succeeded/failed, context created, status changed, assignment changed, and dashboard filter applied. Never include review or suggestion text.

Every screen must provide:

- A meaningful semantic screen title.
- Labels for rating values, icon-only actions, loading indicators, and status chips.
- Focus order that follows the visual order.
- Error messages associated with their fields.
- Sufficient contrast and support for text scaling.
- Touch targets appropriate for mobile accessibility.

## 13. MVP Acceptance Scenarios

1. Signed-out users cannot access any authenticated route by deep link.
2. A contributor can sign up, join an organization, and submit one valid response.
3. A second submission for the same context is blocked without creating a duplicate.
4. A paused or closed context cannot accept a response.
5. A contributor cannot read another contributor's response or internal notes.
6. An administrator can create, activate, pause, and close a context.
7. An administrator can filter, search, assign, and transition a response through triage.
8. A reviewer sees only permitted contexts and responses and has no mutation controls.
9. Dashboard empty states distinguish no data from restrictive filters.
10. Network failures preserve form data and offer safe retry behavior.
11. Every permission denial gives a safe message without leaking document existence.
12. Back navigation preserves filters and prompts before discarding non-empty drafts.