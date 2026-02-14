import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/confirm_dialog.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final userRole = authState is AuthAuthenticated
        ? authState.user.role
        : UserRole.employee;

    return Drawer(
      backgroundColor: AppColors.backgroundLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Menu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(),
                ],
              ),
            ),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _MenuItem(
                    icon: Icons.home,
                    label: 'Home',
                    onTap: () => _navigate(context, AppPage.home),
                  ),
                  if (userRole == UserRole.admin)
                    _MenuItem(
                      icon: Icons.group,
                      label: 'Users',
                      onTap: () => _navigate(context, AppPage.users),
                    ),
                  if (userRole == UserRole.admin)
                    _MenuItem(
                      icon: Icons.warehouse,
                      label: 'Warehouse',
                      onTap: () => _navigate(context, AppPage.warehouse),
                    ),
                  if (userRole != UserRole.employee)
                    _MenuItem(
                      icon: Icons.inventory_2,
                      label: 'SKU',
                      onTap: () => _navigate(context, AppPage.skus),
                    ),
                  if (userRole != UserRole.employee)
                    _MenuItem(
                      icon: Icons.shopping_cart,
                      label: 'Chariots',
                      onTap: () => _navigate(context, AppPage.chariots),
                    ),
                  if (userRole != UserRole.employee)
                    _MenuItem(
                      icon: Icons.lightbulb_outline,
                      label: 'Suggestions',
                      onTap: () => _navigate(context, AppPage.suggestions),
                    ),
                  if (userRole == UserRole.employee)
                    _MenuItem(
                      icon: Icons.assignment,
                      label: 'Tasks',
                      onTap: () => _navigate(context, AppPage.tasks),
                    ),
                  _MenuItem(
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    onTap: () => _navigate(context, AppPage.reports),
                  ),
                  _MenuItem(
                    icon: Icons.history_edu,
                    label: 'Logs',
                    onTap: () => _navigate(context, AppPage.logs),
                  ),
                ],
              ),
            ),
            // Logout button
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await showConfirmDialog(
                    context,
                    title: 'Logout',
                    message: 'Are you sure you want to logout?',
                    confirmLabel: 'LOGOUT',
                    isDestructive: true,
                  );
                  if (confirmed && context.mounted) {
                    context.read<AuthCubit>().logout();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('LOGOUT'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, AppPage page) {
    Navigator.of(context).pop(); // close drawer
    context.read<NavigationCubit>().navigateTo(page);
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textMain,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
