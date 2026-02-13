import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class WarehouseAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final bool showBackButton;

  const WarehouseAppBar({
    super.key,
    required this.title,
    this.onMenuPressed,
    this.showBackButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: AppColors.primary),
              onPressed:
                  onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
            ),
      title: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: AppColors.textMain,
        ),
      ),
      centerTitle: true,
      actions: const [SyncIndicator(), SizedBox(width: 12)],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
      ),
    );
  }
}

class SyncIndicator extends StatelessWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'SYNCED',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}
