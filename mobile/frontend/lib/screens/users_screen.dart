import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../models/user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  String _roleFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().loadUsers());
  }

  Future<void> _refresh() => context.read<DataProvider>().loadUsers();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final auth = context.watch<AuthProvider>();

    final filtered = _roleFilter == 'all'
        ? data.users
        : data.users.where((u) => u.role == _roleFilter).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _chip('All', 'all'),
              const SizedBox(width: 8),
              _chip('Admin', 'admin'),
              const SizedBox(width: 8),
              _chip('Supervisor', 'supervisor'),
              const SizedBox(width: 8),
              _chip('Employee', 'employee'),
              const Spacer(),
              if (auth.isAdmin)
                FilledButton.icon(
                  onPressed: () => _showRegisterDialog(context),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Add'),
                ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: data.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: filtered.isEmpty
                      ? ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('No users found'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: filtered.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (ctx, i) => _UserCard(
                            user: filtered[i],
                            isAdmin: auth.isAdmin,
                          ),
                        ),
                ),
        ),
      ],
    );
  }

  Widget _chip(String label, String value) {
    final selected = _roleFilter == value;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => setState(() => _roleFilter = value),
    );
  }

  void _showRegisterDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String role = 'employee';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Register User'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'employee',
                      child: Text('Employee'),
                    ),
                    DropdownMenuItem(
                      value: 'supervisor',
                      child: Text('Supervisor'),
                    ),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => role = v ?? 'employee'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final auth = context.read<AuthProvider>();
                final ok = await auth.register(
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  role: role,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                if (ok && context.mounted) {
                  context.read<DataProvider>().loadUsers();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User registered')),
                  );
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(auth.error ?? 'Registration failed'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final bool isAdmin;

  const _UserCard({required this.user, required this.isAdmin});

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'supervisor':
        return Colors.blue;
      case 'employee':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _roleColor(user.role).withValues(alpha: 0.15),
          child: Icon(
            user.isAdmin
                ? Icons.admin_panel_settings
                : user.isSupervisor
                ? Icons.supervisor_account
                : Icons.person,
            color: _roleColor(user.role),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(user.email),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                user.role.toUpperCase(),
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: _roleColor(user.role),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            if (isAdmin) ...[
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) async {
                  if (value == 'toggle') {
                    final data = context.read<DataProvider>();
                    await data.updateUser(user.id, {
                      'is_active': !user.isActive,
                    });
                  } else if (value == 'delete') {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete User'),
                        content: Text('Delete ${user.name}?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true && context.mounted) {
                      await context.read<DataProvider>().deleteUser(user.id);
                    }
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(user.isActive ? 'Deactivate' : 'Activate'),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
