# Feedback & Review App

**Product Requirements Document**  
**Status:** Draft  
**Platform:** Flutter mobile application  
**Backend:** Firebase Authentication, Cloud Firestore, and Firebase Cloud Messaging (optional for MVP)

## 1. App Overview

Feedback & Review App is a cross-platform mobile application for collecting, organizing, and acting on feedback about tasks, courses, services, and other experiences. It gives contributors a fast way to submit ratings, written reviews, and suggestions, while giving administrators a centralized view of response volume, sentiment signals, recurring themes, and unresolved issues.

The product is intended for organizations that currently collect feedback through disconnected forms, chat messages, spreadsheets, or paper. Firebase provides identity management, secure storage, and real-time updates so that feedback can be reviewed soon after it is submitted.

### Product vision

Make useful feedback easy to give, easy to understand, and difficult to lose.

### Product principles

- **Low effort for contributors:** A meaningful review should take about two minutes or less.
- **Actionable for administrators:** Every response should be filterable, attributable to a context, and ready for follow-up.
- **Trustworthy by design:** Privacy, permission boundaries, and transparent status changes are first-class requirements.
- **Mobile first:** The core submission and review workflows must work well on small screens and variable connectivity.

## 2. Target Users

### Primary users

**Feedback contributors**

Users, interns, employees, students, customers, or service recipients who have been invited to review a task, course, service, or experience.

Needs:

- A clear reason for the request and what will happen to the response.
- A quick rating and comment flow that works on mobile.
- The ability to submit honestly without unnecessary exposure of personal information.
- Confirmation that the feedback was received.

**Administrators and program owners**

Managers, instructors, HR or operations teams, customer success teams, and service owners who create feedback contexts and act on responses.

Needs:

- A reliable list of feedback in one place.
- Filters and summaries that reveal patterns without requiring spreadsheet work.
- A workflow for triaging, assigning, and closing follow-up work.
- Appropriate access controls for sensitive responses.

### Secondary users

**Reviewers or analysts** who need read-only access to aggregate results and trends.

**Organization owners** who manage administrators, categories, and retention settings.

## 3. Problem Statement

Organizations need feedback to improve performance and user experience, but feedback is often fragmented across forms, email, messaging apps, and spreadsheets. Contributors receive inconsistent or repetitive requests, while administrators lack a shared source of truth for identifying patterns, prioritizing issues, and communicating actions.

This causes low response rates, delayed follow-up, duplicated effort, and decisions based on anecdotes rather than current evidence. The product should reduce the time from feedback request to understood insight while preserving contributor trust.

### Job to be done

When I have completed or experienced something, I want to quickly share an honest rating and useful context, so the organization can improve the experience and I can see that my input was received.

When I manage an experience, I want to collect and organize responses in one place, so I can identify what needs attention and track whether action was taken.

## 4. Goals and Non-Goals

### Goals for the first release

- Enable authenticated contributors to submit one feedback response for a defined context.
- Enable administrators to create and manage feedback contexts such as courses, tasks, or services.
- Provide a searchable and filterable feedback inbox.
- Show basic aggregate metrics and rating distribution.
- Give administrators a lightweight triage workflow: new, in review, actioned, and archived.
- Enforce role-based access through Firebase security rules.

### Non-goals for version 1

- Replacing a full customer relationship management, learning management, or project management system.
- Fully automated sentiment analysis or generative summaries.
- Public review discovery or anonymous internet-wide ratings.
- Complex workflow automation across external tools.

### Features to avoid in version 1

These features add meaningful scope or risk before the core feedback loop is proven:

- Public profiles, public review feeds, likes, comments, or social sharing.
- Anonymous feedback without a defined abuse-prevention and privacy model.
- AI-generated sentiment, summaries, recommendations, or automatic prioritization.
- A large form builder with branching logic, custom widgets, or dozens of question types.
- Native web, desktop, or smartwatch clients alongside the first mobile release.
- Complex organization hierarchies, cross-tenant reporting, or enterprise single sign-on.
- Payments, subscriptions, marketplace functionality, or loyalty programs.
- Automatic integrations with Slack, email marketing, CRM, LMS, or project-management tools.
- Scheduled exports, branded reports, and advanced predictive analytics.
- Real-time chat or a full support-ticket replacement.

## 5. Core Features

### 5.1 Authentication and onboarding

- Sign up and sign in with email and password.
- Password reset and sign out.
- Optional invitation-based onboarding for joining an organization.
- Role assigned by the organization: contributor, reviewer, administrator, or owner.
- First-run explanation of how feedback is used and who can view it.

### 5.2 Feedback contexts

Administrators can create a context that feedback belongs to:

- Title and type: task, course, service, event, or other.
- Description and owner.
- Active, paused, or closed status.
- Start and end dates, when applicable.
- Intended audience or invited participants.
- Questions configured for the context, limited to supported MVP question types.

The default MVP form includes a 1-to-5 rating, an optional written review, and an optional suggestion or improvement request.

### 5.3 Feedback submission

- Contributors see active feedback requests assigned to them.
- The form clearly identifies the context and expected completion time.
- Contributors submit a rating, review, and suggestion.
- Required fields are validated before submission.
- A contributor can save a draft locally or return to an incomplete form where technically feasible.
- Duplicate submissions for the same contributor and context are prevented by default.
- Confirmation is shown after successful submission.
- The contributor can view their own submission and its current status, subject to organization policy.

### 5.4 Feedback inbox

Administrators and permitted reviewers can:

- View feedback in reverse chronological order.
- Filter by context, rating, status, date range, and assigned owner.
- Search written feedback by keyword.
- Open a detail view containing the response, context, submitter visibility rules, and activity status.
- Mark a response as in review, actioned, or archived.
- Add an internal note and assign an owner.

### 5.5 Dashboard and insights

The administrator dashboard displays:

- Total responses for a selected period.
- Average rating and rating distribution.
- Response rate for contexts where invitations are tracked.
- New, in-review, and actioned response counts.
- Contexts with the lowest average rating or highest response volume.
- Recent feedback requiring attention.

Metrics must state their date range and population. Empty states should explain whether there is no data or filters are too restrictive.

### 5.6 Notifications

For MVP, in-app indicators may show new requests and unresolved feedback. Push notifications are optional and should be enabled only after notification permission, delivery behavior, and preferences are defined.

### 5.7 Account and privacy controls

- View account details and organization membership.
- Change password and sign out.
- Display whether a response is identifiable to administrators.
- Allow an administrator to configure whether contributor names are visible for a context, subject to owner policy and audit requirements.

## 6. User Stories and Acceptance Criteria

### Contributor stories

**US-01: Submit a review**  
As a contributor, I want to rate and comment on an experience so that the organization receives useful feedback.

Acceptance criteria:

- I can open an active assigned context from my home screen.
- I can select exactly one rating from 1 to 5.
- I can add an optional comment and suggestion within displayed limits.
- I cannot submit until required fields are valid.
- A successful submission is stored once and produces a confirmation state.

**US-02: Understand privacy**  
As a contributor, I want to know who can see my response so that I can provide honest feedback.

Acceptance criteria:

- The form displays the response visibility policy before submission.
- The policy is also available from the response detail view.
- The app does not promise anonymity when the stored data can identify the contributor.

**US-03: Track submitted feedback**  
As a contributor, I want to see my previous responses and statuses so that I know my feedback was received.

Acceptance criteria:

- I can view my submitted responses.
- Each response shows its context, rating, date, and status.
- I cannot view another contributor's response.

### Administrator stories

**US-04: Create a feedback context**  
As an administrator, I want to create an active feedback request so that the right audience can respond.

Acceptance criteria:

- I can provide the required title, type, and description.
- I can activate, pause, and close the context.
- Only active contexts can accept new submissions.

**US-05: Triage feedback**  
As an administrator, I want to filter and update responses so that important issues do not get lost.

Acceptance criteria:

- I can filter by status, rating, context, and date.
- I can update the status and assign an owner.
- The response detail shows the latest status and update time.

**US-06: Identify patterns**  
As an administrator, I want summary metrics by context and date range so that I can prioritize improvements.

Acceptance criteria:

- I can select a date range and context.
- The dashboard calculates average rating from responses in that selection.
- Counts and averages update when filters change.
- The dashboard distinguishes no responses from a zero-valued metric.

**US-07: Respect permissions**  
As an organization owner, I want role-based access so that feedback is available only to appropriate people.

Acceptance criteria:

- Contributors can create and read only their permitted responses.
- Reviewers can read only the contexts granted to them.
- Administrators can manage permitted contexts and their feedback.
- Security rules reject unauthorized reads and writes, including direct Firestore requests.

## 7. MVP Scope

### Included

- Flutter Android and iOS application with responsive layouts suitable for phones.
- Firebase email/password authentication.
- Organization membership and four roles: contributor, reviewer, administrator, owner.
- Cloud Firestore collections for users, organizations, contexts, questions, responses, assignments, and activity records.
- Fixed MVP feedback form: 1-to-5 rating, written review, suggestion.
- Context creation and lifecycle management.
- Contributor home, submission, confirmation, and submission history screens.
- Administrator inbox, detail view, filters, status updates, assignment, and internal notes.
- Dashboard with basic counts, averages, rating distribution, and date/context filters.
- Firestore security rules, validation, loading states, empty states, error states, and offline-friendly retry behavior.
- Basic analytics events for submission started, submission completed, context created, and feedback status changed.

### Deferred until after MVP

- Configurable branching forms and advanced question types.
- CSV/PDF export and scheduled reports.
- Push notification campaigns and reminders.
- Sentiment, topic, or duplicate detection.
- Web administration console.
- Anonymous feedback mode, once privacy and abuse controls are validated.
- Multi-language support and accessibility localization beyond platform basics.

### MVP assumptions

- An organization has at least one owner or administrator who creates contexts.
- Contributors authenticate before submitting.
- A response is associated with one context and one contributor.
- A context uses a single organization-wide timezone for date-based reporting.
- Firebase project configuration, production billing, retention policy, and legal privacy review are available before release.

## 8. Functional Requirements

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | Users can authenticate, reset a password, and sign out. | Must |
| FR-02 | The system stores a user's organization membership and role. | Must |
| FR-03 | Administrators can create, edit, pause, and close contexts. | Must |
| FR-04 | Contributors can submit one valid response per context unless an administrator explicitly reopens it. | Must |
| FR-05 | The system validates response ownership and role permissions on the server through Firestore rules. | Must |
| FR-06 | Administrators can search, filter, assign, and update feedback status. | Must |
| FR-07 | The dashboard shows reproducible counts and rating calculations for the selected filters. | Must |
| FR-08 | The app provides loading, offline, empty, validation, and recoverable error states. | Must |
| FR-09 | Status changes and administrative notes include actor and timestamp metadata. | Should |
| FR-10 | Product analytics capture funnel events without storing unnecessary feedback content. | Should |

## 9. Non-Functional Requirements

- **Security:** Use least-privilege Firestore rules; never rely on hidden UI controls for authorization. Validate organization boundaries, response ownership, and role permissions server-side.
- **Privacy:** Collect only data required for feedback operations. Document retention, deletion, export, and identifiable versus anonymous behavior before launch.
- **Performance:** Primary screens should render useful content within 2 seconds on a typical mobile connection after cached assets load. Common filtered inbox queries should avoid unbounded reads.
- **Reliability:** A successful submission must not be duplicated when a user retries after a network interruption. Show clear sync state when offline.
- **Accessibility:** Support scalable text, semantic labels, sufficient contrast, keyboard navigation where applicable, and screen-reader-friendly rating controls.
- **Observability:** Log recoverable failures with enough context to diagnose them, excluding review text and other sensitive content.
- **Scalability:** Use paginated queries and indexed Firestore fields for inbox and reporting paths. Avoid client-side reads of an entire organization.

## 10. Success Metrics

### North-star outcome

**Actionable feedback rate:** Percentage of submitted responses that are reviewed and moved to `actioned` within 14 days.

### MVP metrics and initial targets

| Metric | Definition | Initial target |
|---|---|---|
| Submission completion rate | Contributors who start a form and successfully submit it | >= 70% |
| Median completion time | Time from opening a form to submission | <= 2 minutes |
| Response rate | Submitted responses divided by invited contributors for active contexts | >= 45% in pilot contexts |
| Admin weekly activation | Pilot administrators who review feedback at least once per week | >= 60% |
| Time to first review | Median time from submission to first administrator status update | <= 48 hours |
| Actionable feedback rate | Responses moved to actioned within 14 days | >= 40% in pilot contexts |
| Reliability | Successful submissions not duplicated or lost | >= 99.5% |
| Permission defect rate | Confirmed unauthorized feedback reads or writes | 0 |

Metrics should be segmented by organization, context type, platform, and role where sample size allows. Targets are starting hypotheses and should be recalibrated after a pilot baseline.

## 11. Analytics Events

Track the following events with user ID, organization ID, context ID where appropriate, platform, and timestamp:

- `sign_up_completed`
- `feedback_request_opened`
- `feedback_form_started`
- `feedback_form_validation_failed`
- `feedback_submitted`
- `feedback_submission_failed`
- `feedback_detail_viewed`
- `feedback_status_changed`
- `feedback_assigned`
- `context_created`
- `dashboard_filter_applied`

Do not send written review content, suggestions, passwords, or unnecessary personal data to analytics services.

## 12. Risks and Mitigations

- **Low-quality or performative responses:** Keep forms short, explain how feedback is used, and allow context-specific prompts later.
- **Fear of identification:** Make visibility explicit, restrict access by role, and complete a privacy review before offering anonymity.
- **Dashboard misinterpretation:** Always show sample size, date range, filters, and an empty-state explanation alongside averages.
- **Notification fatigue:** Start with in-app indicators and add opt-in reminders only after measuring response behavior.
- **Firebase cost growth:** Paginate inbox queries, add indexes intentionally, limit real-time listeners, and monitor reads per active organization.
- **Sensitive feedback exposure:** Restrict internal notes, audit administrative changes, and define retention and deletion behavior before production.

## 13. Release Acceptance Checklist

- A contributor can sign in, submit valid feedback, retry safely after a transient failure, and see confirmation.
- An administrator can create a context, view responses, filter the inbox, and move a response through its lifecycle.
- A reviewer cannot access contexts or responses outside assigned permissions.
- Firestore rules are covered by automated authorization tests for every role and organization boundary.
- Dashboard values can be reconciled against seeded response data.
- Empty, loading, offline, validation, and permission-denied states are tested on Android and iOS.
- Privacy copy, retention policy, support contact, and account deletion behavior are approved.
- Crash reporting and basic product analytics are verified without leaking feedback content.

## 14. Open Questions

1. Should contributors be able to submit anonymous feedback, and under what anti-abuse controls?
2. Can a contributor edit a response after submission, and when does the edit window close?
3. Are responses visible to the contributor after submission, or only the receipt and status?
4. Is the initial customer a school, an employer, a service business, or a general-purpose organization?
5. Does the product need invitations by email or shareable links in the first pilot?
6. What retention period and deletion rights apply to feedback and administrative activity?
7. Which roles may see contributor identity and internal notes?