import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_providers.dart';

/// Main app shell with bottom navigation for different roles
class AppShell extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onBottomNavTap;
  final Widget child;

  const AppShell({
    super.key,
    required this.currentIndex,
    required this.onBottomNavTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: authState.when(
        data: (state) {
          // TODO: Determine user role from membership and build appropriate nav
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onBottomNavTap,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.feedback),
                label: 'Feedback',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (error, stackTrace) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Contributor-specific bottom navigation
class ContributorBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ContributorBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit),
          label: 'Submit Feedback',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Feedback'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

/// Administrator-specific bottom navigation
class AdminBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AdminBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Contexts'),
        BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}

/// Reviewer-specific bottom navigation
class ReviewerBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const ReviewerBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Assigned',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }
}
