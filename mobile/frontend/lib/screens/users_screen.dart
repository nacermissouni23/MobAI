import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'USERS'),
      body: BlocBuilder<UsersCubit, UsersState>(
        builder: (context, state) {
          if (state is UsersLoaded) {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      final user = state.users[index];
                      return _UserCard(user: user);
                    },
                  ),
                ),
                // Footer Action
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.backgroundLight,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/add-user'),
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('ADD USER'),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.roleLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Edit button
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.edit,
                color: AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
