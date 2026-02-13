import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

/// Shows a confirmation dialog. Returns `true` if confirmed, `false` otherwise.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'CONFIRM',
  String cancelLabel = 'CANCEL',
  Color? confirmColor,
  bool isDestructive = false,
}) async {
  final color =
      confirmColor ?? (isDestructive ? Colors.red : AppColors.primary);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surface,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textMain,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            cancelLabel,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            confirmLabel,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

  return result ?? false;
}
