import 'package:flutter/material.dart';

/// Reusable empty state widget
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final Widget? action;
  final String? actionLabel;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 40, color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: const Color(0xFF102A43)),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null || actionLabel != null) ...[
              const SizedBox(height: 24),
              action ?? TextButton(onPressed: null, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Loading state widget
class LoadingState extends StatelessWidget {
  final String? message;

  const LoadingState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475569)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state widget
class ErrorState extends StatelessWidget {
  final String title;
  final String? description;
  final VoidCallback? onRetry;

  const ErrorState({
    super.key,
    required this.title,
    this.description,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE8E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Color(0xFFE25A5A),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: const Color(0xFF102A43)),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Offline state widget
class OfflineState extends StatelessWidget {
  final Widget? child;

  const OfflineState({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ?child,
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            color: const Color(0xFFE8B84B).withValues(alpha: 0.9),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.cloud_off, color: Colors.white, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You are offline. Some features may be limited.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Permission denied state widget
class PermissionDeniedState extends StatelessWidget {
  final String? message;

  const PermissionDeniedState({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.lock_outline,
      title: 'Access Denied',
      description:
          message ?? 'You do not have permission to access this content.',
    );
  }
}
