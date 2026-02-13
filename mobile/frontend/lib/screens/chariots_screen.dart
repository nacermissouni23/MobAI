import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class ChariotsScreen extends StatefulWidget {
  const ChariotsScreen({super.key});

  @override
  State<ChariotsScreen> createState() => _ChariotsScreenState();
}

class _ChariotsScreenState extends State<ChariotsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<ChariotsCubit>().loadChariots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'Chariots'),
      body: BlocBuilder<ChariotsCubit, ChariotsState>(
        builder: (context, state) {
          if (state is ChariotsLoaded) {
            final filtered = _searchQuery.isEmpty
                ? state.chariots
                : state.chariots.where((c) {
                    final q = _searchQuery.toLowerCase();
                    return c.id.toLowerCase().contains(q) ||
                        c.name.toLowerCase().contains(q) ||
                        c.statusLabel.toLowerCase().contains(q) ||
                        (c.location?.toLowerCase().contains(q) ?? false);
                  }).toList();
            return Stack(
              children: [
                Column(
                  children: [
                    // Search
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search ID, Status or Zone...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: AppColors.primary.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    // Fleet header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'ACTIVE FLEET (${filtered.length})',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary.withValues(alpha: 0.7),
                              letterSpacing: 2.0,
                            ),
                          ),
                          Icon(
                            Icons.filter_list,
                            color: AppColors.primary.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _ChariotCard(chariot: filtered[index]);
                        },
                      ),
                    ),
                  ],
                ),
                // Bottom Action
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.surface.withValues(alpha: 0.0),
                          AppColors.surface,
                        ],
                      ),
                    ),
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/add-chariot'),
                        icon: const Icon(Icons.add_circle),
                        label: const Text('ADD CHARIOT'),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        },
      ),
    );
  }
}

class _ChariotCard extends StatelessWidget {
  final Chariot chariot;

  const _ChariotCard({required this.chariot});

  @override
  Widget build(BuildContext context) {
    final isOffline = chariot.status == ChariotStatus.offline;
    final isInUse = chariot.status == ChariotStatus.inUse;

    Color statusBg;
    Color statusText;
    Color statusBorder;
    if (isOffline) {
      statusBg = Colors.grey.shade200;
      statusText = Colors.grey.shade600;
      statusBorder = Colors.grey.shade300;
    } else if (isInUse) {
      statusBg = AppColors.primary.withValues(alpha: 0.1);
      statusText = AppColors.primary;
      statusBorder = AppColors.primary.withValues(alpha: 0.2);
    } else {
      statusBg = const Color(0xFFDCFCE7);
      statusText = const Color(0xFF15803D);
      statusBorder = const Color(0xFFBBF7D0);
    }

    String details;
    if (isInUse) {
      details =
          'User: ${chariot.currentUser} • ${chariot.location} • ${chariot.details}';
    } else if (isOffline) {
      details = chariot.details ?? '';
    } else {
      details = 'Location: ${chariot.location} • ${chariot.details}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/edit-chariot', arguments: chariot);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isOffline ? Colors.grey.shade50 : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOffline
                  ? Colors.grey.shade200
                  : AppColors.primary.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: isOffline
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Opacity(
            opacity: isOffline ? 0.7 : 1.0,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isOffline
                        ? Colors.grey.shade200
                        : isInUse
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isOffline
                        ? Icons.build
                        : isInUse
                        ? Icons.person_pin_circle
                        : Icons.shopping_cart,
                    color: isOffline
                        ? Colors.grey.shade500
                        : isInUse
                        ? Colors.white
                        : AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            chariot.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: isOffline
                                  ? Colors.grey.shade500
                                  : AppColors.textMain,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusBorder),
                            ),
                            child: Text(
                              chariot.statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: statusText,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        details,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isOffline
                              ? Colors.grey.shade400
                              : AppColors.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
