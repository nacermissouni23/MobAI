import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/cubits/cubits.dart';
import 'package:frontend/data/models/models.dart';
import 'package:frontend/widgets/widgets.dart';

class SkusScreen extends StatefulWidget {
  const SkusScreen({super.key});

  @override
  State<SkusScreen> createState() => _SkusScreenState();
}

class _SkusScreenState extends State<SkusScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<SkusCubit>().loadSkus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      drawer: const AppDrawer(),
      appBar: const WarehouseAppBar(title: 'SKU Management'),
      body: BlocBuilder<SkusCubit, SkusState>(
        builder: (context, state) {
          if (state is SkusLoaded) {
            final filtered = _searchQuery.isEmpty
                ? state.skus
                : state.skus.where((s) {
                    final q = _searchQuery.toLowerCase();
                    return s.name.toLowerCase().contains(q) ||
                        s.skuCode.toLowerCase().contains(q) ||
                        (s.locationLabel?.toLowerCase().contains(q) ?? false) ||
                        (s.category?.toLowerCase().contains(q) ?? false);
                  }).toList();
            return Stack(
              children: [
                Column(
                  children: [
                    // Search Bar
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Search by name or ID...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppColors.primary,
                          ),
                          suffixIcon: const Icon(
                            Icons.filter_list,
                            color: AppColors.primary,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF0F4F4),
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
                    // SKU List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          return _SkuCard(sku: filtered[index]);
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
                            Navigator.of(context).pushNamed('/add-sku'),
                        icon: const Icon(Icons.add_box),
                        label: const Text('ADD NEW SKU'),
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

class _SkuCard extends StatelessWidget {
  final Sku sku;

  const _SkuCard({required this.sku});

  @override
  Widget build(BuildContext context) {
    Color statusBg;
    Color statusText;
    switch (sku.stockStatus) {
      case SkuStockStatus.inStock:
        statusBg = const Color(0xFFDCFCE7);
        statusText = const Color(0xFF15803D);
        break;
      case SkuStockStatus.lowStock:
        statusBg = const Color(0xFFFFF7ED);
        statusText = const Color(0xFFC2410C);
        break;
      case SkuStockStatus.outOfStock:
        statusBg = const Color(0xFFFEE2E2);
        statusText = const Color(0xFFB91C1C);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/edit-sku', arguments: sku);
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Product Image Placeholder
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Icon(
                  Icons.image,
                  color: AppColors.primary.withValues(alpha: 0.3),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sku.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMain,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sku.skuCode,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            sku.stockStatusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: statusText,
                            ),
                          ),
                        ),
                        if (sku.locationLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            sku.locationLabel!,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
