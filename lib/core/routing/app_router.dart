import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/firebase_providers.dart';
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/admin/presentation/screens/admin_inbox_screen.dart';
import '../../features/admin/presentation/screens/admin_response_detail_screen.dart';
import '../../features/admin/presentation/screens/context_list_screen.dart';
import '../../features/admin/presentation/screens/create_context_screen.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/contributor/presentation/screens/feedback_form_screen.dart';
import '../../features/contributor/presentation/screens/my_feedback_screen.dart';
import '../../features/reviewer/presentation/screens/reviewer_assigned_screen.dart';
import '../../features/reviewer/presentation/screens/reviewer_response_detail_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isDemo = state.uri.queryParameters['demo'] == 'true';

      return isAuthenticated.when(
        data: (authenticated) {
          if (isDemo && state.matchedLocation == '/home') {
            return null;
          }

          // Redirect unauthenticated users to sign-in
          if (!authenticated) {
            return '/sign-in';
          }

          // Redirect authenticated users away from auth pages
          if (state.matchedLocation == '/sign-in' ||
              state.matchedLocation == '/sign-up') {
            return '/home';
          }

          return null;
        },
        loading: () {
          // Keep user on splash while loading
          if (state.matchedLocation != '/splash') {
            return '/splash';
          }
          return null;
        },
        error: (error, stackTrace) {
          return '/sign-in';
        },
      );
    },
    routes: <RouteBase>[
      // Auth routes
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),

      // Main app routes
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      // Contributor routes
      GoRoute(
        path: '/contributor/feedback',
        builder: (context, state) => FeedbackFormScreen(
          contextId:
              state.uri.queryParameters['contextId'] ?? 'test-context-001',
        ),
      ),
      GoRoute(
        path: '/contributor/my-feedback',
        builder: (context, state) => const MyFeedbackScreen(),
      ),

      // Admin routes
      GoRoute(
        path: '/admin/contexts',
        builder: (context, state) => const AdminContextListScreen(),
      ),
      GoRoute(
        path: '/admin/contexts/create',
        builder: (context, state) => const CreateContextScreen(),
      ),
      GoRoute(
        path: '/admin/contexts/:contextId',
        builder: (context, state) => const AdminContextListScreen(),
      ),
      GoRoute(
        path: '/admin/inbox',
        builder: (context, state) => const AdminInboxScreen(),
      ),
      GoRoute(
        path: '/admin/responses/:responseId',
        builder: (context, state) => AdminResponseDetailScreen(
          responseId: state.pathParameters['responseId']!,
        ),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // Reviewer routes
      GoRoute(
        path: '/reviewer/assigned',
        builder: (context, state) => const ReviewerAssignedScreen(),
      ),
      GoRoute(
        path: '/reviewer/responses/:responseId',
        builder: (context, state) => ReviewerResponseDetailScreen(
          responseId: state.pathParameters['responseId']!,
        ),
      ),

      // Settings routes
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const SizedBox(),
      ),
      GoRoute(
        path: '/settings/organization',
        builder: (context, state) => const SizedBox(),
      ),
    ],
  );
});
