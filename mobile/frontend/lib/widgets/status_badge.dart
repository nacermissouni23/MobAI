import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/data/models/models.dart';

/// Reusable status badge for task statuses.
class TaskStatusBadge extends StatelessWidget {
  final TaskStatus status;
  const TaskStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label, IconData icon) = switch (status) {
      TaskStatus.completed => (
        AppColors.successGreen,
        'COMPLETED',
        Icons.check_circle,
      ),
      TaskStatus.inProgress => (AppColors.primary, 'IN PROGRESS', Icons.timer),
      TaskStatus.pending => (AppColors.warning, 'PENDING', Icons.schedule),
    };

    return _Badge(color: color, label: label, icon: icon);
  }
}

/// Reusable status badge for suggestion statuses.
class SuggestionStatusBadge extends StatelessWidget {
  final SuggestionStatus status;
  const SuggestionStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label, IconData icon) = switch (status) {
      SuggestionStatus.ready => (
        AppColors.primary,
        'READY',
        Icons.check_circle,
      ),
      SuggestionStatus.urgent => (AppColors.warning, 'URGENT', Icons.warning),
      SuggestionStatus.pending => (
        AppColors.textSecondary,
        'PENDING',
        Icons.schedule,
      ),
    };

    return _Badge(color: color, label: label, icon: icon);
  }
}

class _Badge extends StatelessWidget {
  final Color color;
  final String label;
  final IconData icon;

  const _Badge({required this.color, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tag badge (e.g. "STORE", "PICKING") with the primary color scheme.
class TypeBadge extends StatelessWidget {
  final String label;

  const TypeBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
