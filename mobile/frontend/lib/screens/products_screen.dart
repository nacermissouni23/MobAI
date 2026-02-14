import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DataProvider>().loadProducts());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() => context.read<DataProvider>().loadProducts();

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final products = _query.isEmpty
        ? data.products
        : data.products.where((p) {
            final q = _query.toLowerCase();
            return p.nomProduit.toLowerCase().contains(q) ||
                p.sku.toLowerCase().contains(q) ||
                (p.categorie?.toLowerCase().contains(q) ?? false);
          }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name, SKU or category...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: data.loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: products.isEmpty
                      ? ListView(
                          children: const [
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(40),
                                child: Text('No products found'),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: products.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (ctx, i) =>
                              _ProductCard(product: products[i]),
                        ),
                ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: product.actif
              ? Colors.green.shade50
              : Colors.grey.shade200,
          child: Icon(
            Icons.inventory_2,
            color: product.actif ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          product.nomProduit,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('SKU: ${product.sku}'),
        trailing: product.actif
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : const Icon(Icons.cancel, color: Colors.grey, size: 20),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                _row('Category', product.categorie ?? 'N/A'),
                _row('Unit', product.uniteMesure),
                _row('Bundle/Pack', '${product.colisageFardeau ?? "-"}'),
                _row('Bundle/Palette', '${product.colisagePalette ?? "-"}'),
                _row('Volume/pcs', '${product.volumePcs ?? "-"}'),
                _row('Weight', '${product.poids ?? "-"}'),
                _row('Stackable', product.isGerbable ? 'Yes' : 'No'),
                const Divider(),
                _row('Demand Freq', '${product.demandFreq}'),
                _row('Reception Freq', '${product.receptionFreq}'),
                _row('Delivery Freq', '${product.deliveryFreq}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
