import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

/// Reusable sticky bottom action bar with 1 or 2 buttons.
class BottomActionBar extends StatelessWidget {
  final Widget child;

  const BottomActionBar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.neutralBorder)),
      ),
      child: SafeArea(top: false, child: child),
    );
  }

  /// Single full-width primary action button.
  factory BottomActionBar.single({
    required String label,
    required VoidCallback onPressed,
    IconData? icon,
    Color? backgroundColor,
  }) {
    return BottomActionBar(
      child: SizedBox(
        height: 56,
        width: double.infinity,
        child: icon != null
            ? ElevatedButton.icon(
                onPressed: onPressed,
                icon: Icon(icon),
                label: Text(label),
                style: backgroundColor != null
                    ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
                    : null,
              )
            : ElevatedButton(
                onPressed: onPressed,
                style: backgroundColor != null
                    ? ElevatedButton.styleFrom(backgroundColor: backgroundColor)
                    : null,
                child: Text(label),
              ),
      ),
    );
  }

  /// Two buttons side by side (secondary + primary).
  factory BottomActionBar.dual({
    required String secondaryLabel,
    required VoidCallback onSecondary,
    required String primaryLabel,
    required VoidCallback onPrimary,
    Color? primaryColor,
  }) {
    return BottomActionBar(
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: onSecondary,
                child: Text(secondaryLabel),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: onPrimary,
                style: primaryColor != null
                    ? ElevatedButton.styleFrom(backgroundColor: primaryColor)
                    : null,
                child: Text(primaryLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
