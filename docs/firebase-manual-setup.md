# FeedRe Firebase Setup

This guide is for the current Flutter implementation. The app already contains Firebase initialization, Auth providers, Firestore repositories, admin inbox routes, reviewer routes, and dashboard metrics. Firebase Console setup is still required before real accounts and production data will work.

## 1. Create or select the Firebase project

Use one project for development first. The current development configuration points to `feedback-1b5a2`.

In Firebase Console:

1. Open the project.
2. Add an Android app using the package ID from `android/app/build.gradle.kts`.
3. Download `google-services.json` and place it at `android/app/google-services.json`.
For a local Android FlutterFire configuration, install the tools and run this
from the repository root after authenticating with Firebase:

```powershell
npm install --global firebase-tools
firebase login
dart pub global activate flutterfire_cli
flutterfire configure --project=feedback-1b5a2 --platforms=android
```

The Android app is already registered in this repository and its
`google-services.json` is stored at `android/app/google-services.json`. Do not
commit service-account keys or copy credentials into Dart source code.

For additional Android environments, create separate Firebase projects and
update `EnvironmentConfig` plus the generated Android configuration for each
environment.

## 2. Enable Authentication

In **Build > Authentication > Sign-in method**:

1. Enable **Email/Password**.
2. Keep email link and anonymous sign-in disabled unless the product decision changes.
3. In **Settings > Authorized domains**, add local and staging domains when web testing is enabled.

Create test users in **Authentication > Users** only after the Firestore membership documents are created.

## 3. Create Firestore

In **Build > Firestore Database**:

1. Create a database in Native mode.
2. Choose the region that matches the release decision in Phase 0.
3. Do not start in production with open rules.
4. Deploy the repository rules and indexes from the project root:

```powershell
firebase login
firebase use feedback-1b5a2
firebase deploy --only firestore:rules,firestore:indexes
```

The current repositories use these top-level collections:

```text
users/{uid}
organizations/{organizationId}
memberships/{membershipId}
contexts/{contextId}
responses/{responseId}
activity/{activityId}
aggregates/{contextId}
```

The long-term schema in `docs/backend.md` uses organization subcollections. Before production, migrate the repositories and rules together to that schema; do not mix the two layouts.

## 4. Seed development data

The app includes `FirestoreSeedService`, but it must run while authenticated with an account that is allowed to write the seed collections. Use the Firebase Emulator Suite for repeatable development:

```powershell
firebase emulators:start
flutter run --debug
```

The emulator UI is available at `http://127.0.0.1:4000`.

Create these development identities and matching membership documents:

| Role | Suggested email |
| --- | --- |
| Owner | owner@feedre.com |
| Administrator | admin@feedre.com |
| Reviewer | reviewer1@feedre.com |
| Contributor | contributor@feedre.com |

Use non-production passwords and never reuse them in staging or production.

## 5. App Check and Analytics

After Auth and Firestore work in staging:

1. Register Android Play Integrity under **App Check**.
2. Run in monitoring mode first.
3. Confirm valid app traffic in metrics.
4. Enable enforcement only after emulator and staging tests pass.
5. Enable Analytics and Crashlytics separately for staging and production.

Do not send response text, suggestions, email addresses, or other feedback content to Analytics or Crashlytics.

## 6. Production deployment checklist

Before production:

- Replace the development project configuration with the production Firebase app configuration.
- Review and deploy Firestore rules and indexes.
- Confirm the organization and membership model has been migrated consistently.
- Test contributor, reviewer, administrator, and owner access with separate accounts.
- Confirm duplicate response submission is rejected safely.
- Confirm contributors cannot read other contributors' responses or internal notes.
- Confirm reviewers only see assigned responses.
- Turn on App Check enforcement after staging verification.
- Configure budget alerts, Firestore quota alerts, Function error alerts, and Crashlytics alerts.

The current repository has no `functions/` directory yet, so Cloud Functions from Phases 7-10 are not deployable until that backend project is added.