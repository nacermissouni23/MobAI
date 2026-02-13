import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

/// Reusable location card showing a label, icon, and location value.
/// Used in Suggestion Details, Store Task, and other screens.
class LocationCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const LocationCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutralBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// A row showing FROM → TO location cards.
class LocationRow extends StatelessWidget {
  final String fromLabel;
  final String fromValue;
  final String toLabel;
  final String toValue;
  final bool showTo;

  const LocationRow({
    super.key,
    this.fromLabel = 'From Location',
    required this.fromValue,
    this.toLabel = 'To Destination',
    required this.toValue,
    this.showTo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LocationCard(
            label: fromLabel,
            value: fromValue,
            icon: Icons.upload_file,
          ),
        ),
        if (showTo) ...[
          const SizedBox(width: 12),
          const Icon(Icons.arrow_forward, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: LocationCard(
              label: toLabel,
              value: toValue,
              icon: Icons.download,
            ),
          ),
        ],
      ],
    );
  }
}
