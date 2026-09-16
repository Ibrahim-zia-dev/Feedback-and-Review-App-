import 'package:flutter/material.dart';

/// Reusable rating input widget (1-5 stars)
class RatingInput extends StatelessWidget {
  final int? initialValue;
  final Function(int) onRatingChanged;
  final String? label;
  final bool readOnly;

  const RatingInput({
    super.key,
    this.initialValue,
    required this.onRatingChanged,
    this.label,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        int? hoveredRating;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (label != null) ...[
              Text(label!, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
            ],
            Row(
              children: List.generate(5, (index) {
                final rating = index + 1;
                final isSelected = (initialValue ?? 0) >= rating;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: MouseRegion(
                    onEnter: (_) {
                      if (!readOnly) {
                        setState(() => hoveredRating = rating);
                      }
                    },
                    onExit: (_) {
                      if (!readOnly) {
                        setState(() => hoveredRating = null);
                      }
                    },
                    child: GestureDetector(
                      onTap: readOnly ? null : () => onRatingChanged(rating),
                      child: Icon(
                        Icons.star,
                        size: 40,
                        color:
                            (hoveredRating != null &&
                                    hoveredRating! >= rating) ||
                                isSelected
                            ? const Color(0xFFE8B84B)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

/// Status chip widget
class StatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const StatusChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor ?? const Color(0xFF475569)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor ?? const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }
}

/// Context type badge
class ContextTypeBadge extends StatelessWidget {
  final String type;

  const ContextTypeBadge({super.key, required this.type});

  Map<String, dynamic> _getTypeStyle(String type) {
    switch (type.toLowerCase()) {
      case 'feature':
        return {
          'bg': const Color(0xFFEBF5FF),
          'text': const Color(0xFF1F4D9A),
          'icon': Icons.lightbulb_outline,
        };
      case 'product':
        return {
          'bg': const Color(0xFFEAFBF7),
          'text': const Color(0xFF2BB3A9),
          'icon': Icons.shopping_bag,
        };
      case 'design':
        return {
          'bg': const Color(0xFFFFF7E8),
          'text': const Color(0xFFE8B84B),
          'icon': Icons.palette,
        };
      case 'service':
        return {
          'bg': const Color(0xFFFFEBEB),
          'text': const Color(0xFFE25A5A),
          'icon': Icons.handshake_outlined,
        };
      default:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF475569),
          'icon': Icons.category_outlined,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getTypeStyle(type);
    return StatusChip(
      label: type,
      backgroundColor: style['bg'] as Color,
      textColor: style['text'] as Color,
      icon: style['icon'] as IconData,
    );
  }
}

/// Response status badge
class ResponseStatusBadge extends StatelessWidget {
  final String status;

  const ResponseStatusBadge({super.key, required this.status});

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return {
          'bg': const Color(0xFFEBF5FF),
          'text': const Color(0xFF1F4D9A),
          'icon': Icons.check_circle_outline,
        };
      case 'reviewing':
        return {
          'bg': const Color(0xFFFFF7E8),
          'text': const Color(0xFFE8B84B),
          'icon': Icons.search_outlined,
        };
      case 'reviewed':
        return {
          'bg': const Color(0xFFEAFBF7),
          'text': const Color(0xFF2BB3A9),
          'icon': Icons.done_all_outlined,
        };
      case 'actionable':
        return {
          'bg': const Color(0xFFFFEBEB),
          'text': const Color(0xFFE25A5A),
          'icon': Icons.priority_high_outlined,
        };
      case 'resolved':
        return {
          'bg': const Color(0xFFEAFBF7),
          'text': const Color(0xFF2BB3A9),
          'icon': Icons.check_circle_outlined,
        };
      case 'archived':
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF475569),
          'icon': Icons.archive_outlined,
        };
      default:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF475569),
          'icon': Icons.info_outline,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStatusStyle(status);
    return StatusChip(
      label: status,
      backgroundColor: style['bg'] as Color,
      textColor: style['text'] as Color,
      icon: style['icon'] as IconData,
    );
  }
}

/// Membership role badge
class RoleBadge extends StatelessWidget {
  final String role;

  const RoleBadge({super.key, required this.role});

  Map<String, dynamic> _getRoleStyle(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return {
          'bg': const Color(0xFFFFEBEB),
          'text': const Color(0xFFE25A5A),
          'icon': Icons.star_outlined,
        };
      case 'administrator':
        return {
          'bg': const Color(0xFFEBF5FF),
          'text': const Color(0xFF1F4D9A),
          'icon': Icons.admin_panel_settings_outlined,
        };
      case 'reviewer':
        return {
          'bg': const Color(0xFFFFF7E8),
          'text': const Color(0xFFE8B84B),
          'icon': Icons.visibility_outlined,
        };
      case 'contributor':
        return {
          'bg': const Color(0xFFEAFBF7),
          'text': const Color(0xFF2BB3A9),
          'icon': Icons.edit_outlined,
        };
      default:
        return {
          'bg': const Color(0xFFF3F4F6),
          'text': const Color(0xFF475569),
          'icon': Icons.person_outline,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _getRoleStyle(role);
    return StatusChip(
      label: role,
      backgroundColor: style['bg'] as Color,
      textColor: style['text'] as Color,
      icon: style['icon'] as IconData,
    );
  }
}
