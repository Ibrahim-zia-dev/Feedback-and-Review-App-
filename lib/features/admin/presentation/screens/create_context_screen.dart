import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/admin_context_providers.dart';

/// Screen for creating a new feedback context
class CreateContextScreen extends ConsumerStatefulWidget {
  const CreateContextScreen({super.key});

  @override
  ConsumerState<CreateContextScreen> createState() =>
      _CreateContextScreenState();
}

class _CreateContextScreenState extends ConsumerState<CreateContextScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  final List<String> _contextTypes = [
    'feature',
    'product',
    'design',
    'service',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleCreate() async {
    final formNotifier = ref.read(contextFormProvider.notifier);

    // Validate form
    if (!ref.read(contextFormProvider).isFormValid) {
      _showErrorDialog('Please fill in all required fields');
      return;
    }

    try {
      // TODO: Get organizationId and userId from auth state
      const organizationId = 'test-org';
      const userId = 'test-user';

      await ref.read(
        createContextProvider((
          organizationId: organizationId,
          userId: userId,
        )).future,
      );

      formNotifier.reset();
      _titleController.clear();
      _descriptionController.clear();

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Creation Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Context Created'),
        content: const Text(
          'Your feedback context has been created as a draft. You can activate it whenever you\'re ready.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/admin/contexts');
            },
            child: const Text('View Contexts'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(contextFormProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Feedback Context'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Up New Feedback Request',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new feedback context to gather input from your team',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF475569)),
            ),
            const SizedBox(height: 32),

            // Title field
            Text(
              'Context Title',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (value) {
                ref.read(contextFormProvider.notifier).setTitle(value);
              },
              decoration: const InputDecoration(
                hintText: 'e.g., Q1 2024 Product Review',
              ),
            ),
            const SizedBox(height: 24),

            // Type selection
            Text(
              'Context Type',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _contextTypes.map((type) {
                final isSelected = formState.type == type;
                return FilterChip(
                  label: Text(type.capitalize()),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      ref.read(contextFormProvider.notifier).setType(type);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Description field
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Required • Max 500 characters',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 500,
              onChanged: (value) {
                ref.read(contextFormProvider.notifier).setDescription(value);
              },
              decoration: const InputDecoration(
                hintText: 'Explain what feedback you\'re looking for...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // Start date
            Text(
              'Start Date (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                formState.startDate != null
                    ? _formatDate(formState.startDate!)
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate: formState.startDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selected != null) {
                  ref.read(contextFormProvider.notifier).setStartDate(selected);
                }
              },
            ),
            const SizedBox(height: 24),

            // End date
            Text(
              'End Date (Optional)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(
                formState.endDate != null
                    ? _formatDate(formState.endDate!)
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final selected = await showDatePicker(
                  context: context,
                  initialDate:
                      formState.endDate ??
                      DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (selected != null) {
                  ref.read(contextFormProvider.notifier).setEndDate(selected);
                }
              },
            ),
            const SizedBox(height: 32),

            // Create button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: formState.isSubmitting ? null : _handleCreate,
                child: formState.isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create as Draft'),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ),

            const SizedBox(height: 24),

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF1F4D9A),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Contexts are created as drafts. You can edit them and assign reviewers before activating.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF1F4D9A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

extension on String {
  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }
}
