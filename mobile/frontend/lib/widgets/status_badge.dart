import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/data/enums.dart';

/// Reusable status badge for operation statuses.
class OperationStatusBadge extends StatelessWidget {
  final OperationStatus status;
  const OperationStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label, IconData icon) = switch (status) {
      OperationStatus.completed => (
        AppColors.successGreen,
        'COMPLETED',
        Icons.check_circle,
      ),
      OperationStatus.inProgress => (
        AppColors.primary,
        'IN PROGRESS',
        Icons.timer,
      ),
      OperationStatus.pending => (AppColors.warning, 'PENDING', Icons.schedule),
      OperationStatus.failed => (Colors.red, 'FAILED', Icons.error),
    };

    return _Badge(color: color, label: label, icon: icon);
  }
}

/// Legacy alias so existing screen code referencing TaskStatusBadge still works.
@Deprecated('Use OperationStatusBadge instead')
typedef TaskStatusBadge = OperationStatusBadge;

/// Reusable status badge for order statuses.
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;
  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label, IconData icon) = switch (status) {
      OrderStatus.validated => (
        AppColors.primary,
        'VALIDATED',
        Icons.check_circle,
      ),
      OrderStatus.aiGenerated => (
        AppColors.warning,
        'AI GENERATED',
        Icons.auto_awesome,
      ),
      OrderStatus.pending => (
        AppColors.textSecondary,
        'PENDING',
        Icons.schedule,
      ),
      OrderStatus.overridden => (Colors.orange, 'OVERRIDDEN', Icons.edit),
      OrderStatus.completed => (
        AppColors.successGreen,
        'COMPLETED',
        Icons.check_circle,
      ),
    };

    return _Badge(color: color, label: label, icon: icon);
  }
}

/// Legacy alias so existing screen code referencing SuggestionStatusBadge still works.
@Deprecated('Use OrderStatusBadge instead')
typedef SuggestionStatusBadge = OrderStatusBadge;

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
