# FeedRe - Quick Reference Guide

## Project Overview
- **App:** Feedback & Review Platform
- **Tech:** Flutter + Firebase + Riverpod
- **Status:** 7/13 phases complete
- **Architecture:** Clean Architecture

## Quick Start Commands

```bash
# Run development
flutter run --debug

# Format code
dart format lib/

# Analyze
flutter analyze

# Run tests
flutter test

# Start Firebase emulator
firebase emulators:start

# Deploy to staging
firebase use feed-re-staging
firebase deploy --only firestore:rules,functions
```

## Project Structure Quick Links

| Folder | Purpose |
|--------|---------|
| `lib/core/` | Firebase service, theme, routing |
| `lib/features/auth/` | Sign in/up screens & auth logic |
| `lib/features/contributor/` | Contributor feedback workflow |
| `lib/features/admin/` | Admin context & inbox management |
| `lib/features/shared/` | Shared entities, repos, widgets |
| `test/` | Unit & widget tests |
| `functions/` | Cloud Functions |

## Key Files You'll Edit

**Adding Routes:**
```dart
File: lib/core/routing/app_router.dart
Add new GoRoute to routes list
```

**Creating Screens:**
```dart
File: lib/features/{feature}/presentation/screens/{name}_screen.dart
Follow existing screen patterns
Extend ConsumerWidget or ConsumerStatefulWidget
```

**Managing State:**
```dart
File: lib/features/{feature}/providers/{feature}_providers.dart
Use StateNotifierProvider, FutureProvider, StreamProvider
Follow naming: {action}Provider, {entity}Provider
```

**Accessing Data:**
```dart
File: lib/features/shared/data/repositories/
Use Firestore repository methods
Watch provider in screens: ref.watch(provider)
Read provider for mutations: ref.read(provider.future)
```

## Common Patterns

### Create a Provider
```dart
final myProvider = FutureProvider.family<DataType, ParamType>(
  (ref, param) async {
    // fetch data
    return data;
  },
);
```

### Use in Screen
```dart
ref.watch(myProvider(param)).when(
  data: (data) => Text(data),
  loading: () => const LoadingState(),
  error: (e, st) => ErrorState(),
);
```

### Call Mutation
```dart
try {
  await ref.read(updateProvider(params).future);
  // Success
} catch (e) {
  // Handle error
}
```

### Form State Management
```dart
final myFormProvider = StateNotifierProvider<MyFormNotifier, MyFormState>(
  (ref) => MyFormNotifier(),
);

class MyFormNotifier extends StateNotifier<MyFormState> {
  MyFormNotifier() : super(const MyFormState());
  
  void updateField(String value) {
    state = state.copyWith(field: value);
  }
}
```

## Database Entities

### User
```dart
UserEntity {
  id, email, name, role, organization_ids
}
```

### Organization
```dart
Organization {
  id, name, owner_id, member_ids
}
```

### Context
```dart
Context {
  id, org_id, owner_id, title, type, description,
  status (draft|active|paused|closed),
  created_at, updated_at
}
```

### Response
```dart
Response {
  id, context_id, org_id, contributor_id,
  rating (1-5), review, suggestion,
  status (submitted|reviewing|reviewed),
  submitted_at
}
```

## User Roles

| Role | Permissions |
|------|------------|
| **Owner** | Everything (org level) |
| **Admin** | Manage contexts, inbox, assignments |
| **Reviewer** | View assigned responses |
| **Contributor** | Submit feedback |

## Status Flows

**Context Lifecycle:**
```
Draft → Active → Paused → Closed
       → Closed (from Draft)
```

**Response Lifecycle:**
```
Submitted → Reviewing → Reviewed
        → Actionable → Resolved
        → Archived
```

## Widget Components Available

| Component | File | Usage |
|-----------|------|-------|
| RatingInput | input_widgets.dart | 1-5 star selector |
| StatusChip | input_widgets.dart | Status badges |
| ContextTypeBadge | input_widgets.dart | Context type badge |
| ResponseStatusBadge | input_widgets.dart | Response status |
| RoleBadge | input_widgets.dart | User role badge |
| LoadingState | state_widgets.dart | Loading indicator |
| EmptyState | state_widgets.dart | Empty list state |
| ErrorState | state_widgets.dart | Error message |
| OfflineState | state_widgets.dart | Offline mode |
| PermissionDeniedState | state_widgets.dart | Access denied |

## Common Tasks

### Add New Screen
1. Create file: `lib/features/{feature}/presentation/screens/{name}_screen.dart`
2. Extend ConsumerWidget or ConsumerStatefulWidget
3. Use providers via `ref.watch()` and `ref.read()`
4. Add route to `app_router.dart`

### Create Provider
1. Create file: `lib/features/{feature}/providers/{feature}_providers.dart`
2. Define state class if needed
3. Create StateNotifier if mutable state
4. Create FutureProvider, StreamProvider, or StateNotifierProvider

### Add Repository Method
1. Edit: `lib/features/shared/data/repositories/{entity}_repository.dart`
2. Add Firestore query
3. Add converter if needed
4. Expose in provider

### Style Component
1. Use theme colors from `app_theme.dart`:
   - primaryBlue: #1F4D9A
   - teal: #2BB3A9
   - gold: #E8B84B
   - red: #E25A5A
2. Apply Material 3 components
3. Ensure accessibility

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/features/auth/auth_test.dart
```

### Firestore Rules Tests
```bash
firebase emulators:start
# In another terminal
firebase emulators:exec "npm test"
```

## Debugging

### View Logs
```bash
# Flutter logs
flutter logs

# Firebase logs
firebase functions:log

# Firestore queries
# In Firebase Console → Firestore → Logs tab
```

### Inspect State
```dart
// In screen
ref.listen(myProvider, (previous, next) {
  print('State changed: $next');
});
```

### Test Permissions
1. Use different test accounts
2. Check Firestore Security Rules
3. Verify role assignments

## Deployment Checklist

- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Format code: `dart format lib/`
- [ ] Test on physical device
- [ ] Build signed APK: `flutter build apk --release`
- [ ] Deploy Firestore Rules: `firebase deploy --only firestore:rules`
- [ ] Deploy Functions: `firebase deploy --only functions`
- [ ] Test on staging environment
- [ ] Get stakeholder approval
- [ ] Deploy to production

## Firebase Projects

**Development (Local):**
```
firebase use feed-re-dev
// Connects to emulators on localhost:8080
```

**Staging:**
```
firebase use feed-re-staging
// Real Firebase project for testing
```

**Production:**
```
firebase use feed-re-production
// Live Firebase project
```

## Color Palette

```dart
// Primary
primaryBlue: Color(0xFF1F4D9A)

// Accents
teal: Color(0xFF2BB3A9)
gold: Color(0xFFE8B84B)
red: Color(0xFFE25A5A)

// Neutrals
dark: Color(0xFF102A43)
gray: Color(0xFF475569)
lightGray: Color(0xFF94A3B8)
bgGray: Color(0xFFF3F4F6)
```

## Need Help?

1. **Architecture Questions:** Read `COMPLETE_IMPLEMENTATION_GUIDE.md`
2. **Phase Details:** Read `PHASES_7_TO_13.md`
3. **Status Overview:** Read `IMPLEMENTATION_STATUS.md`
4. **Code Examples:** Look at existing screens in each feature
5. **Firebase:** Consult firestore.rules and firestore.indexes.json

## Next Phase (Phase 8)

Current: Phase 7 (Admin Inbox & Triage) ✅  
Next: Phase 8 (Reviewer Experience)

**Phase 8 Tasks:**
- [ ] Create reviewer_providers.dart
- [ ] Create reviewer screens (assigned list, detail)
- [ ] Add reviewer routes
- [ ] Implement permission checks
- [ ] Add read-only UI for reviewers

---

**Last Updated:** Phase 7 Complete  
**Estimated Remaining:** 5-6 weeks (Phases 8-13)  
**Contact:** See project documentation for support info
