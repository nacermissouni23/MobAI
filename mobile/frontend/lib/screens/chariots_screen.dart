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
                    return c.id.toLowerCase().contains(q);
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
                          hintText: 'Search Chariot ID...',
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/edit-chariot', arguments: chariot);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: chariot.isActive
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: chariot.isActive ? AppColors.primary : Colors.grey,
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
                          chariot.id,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMain,
                            fontFamily: 'monospace',
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: chariot.isActive
                                ? const Color(0xFFDCFCE7)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: chariot.isActive
                                  ? const Color(0xFFBBF7D0)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            chariot.isActive ? 'ACTIVE' : 'INACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: chariot.isActive
                                  ? const Color(0xFF15803D)
                                  : Colors.grey.shade600,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chariot.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
