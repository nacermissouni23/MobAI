import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

/// Reusable uppercase section label used across all detail screens.
/// e.g. "PRODUCT ID", "QUANTITY", "PATH VISUALIZATION"
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  const SectionLabel(this.text, {super.key, this.padding = EdgeInsets.zero});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
