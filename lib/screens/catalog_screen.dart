import 'package:flutter/material.dart';

import '../data/initial_catalog.dart';
import '../models/product.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key, this.category});

  final String? category;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final products = initialCatalog.where((product) {
      final categoryMatches =
          widget.category == null || product.category == widget.category;
      final queryMatches =
          product.name.toLowerCase().contains(_query.trim().toLowerCase());
      return categoryMatches && queryMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category ?? 'Mahsulotlar katalogi'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Mahsulot qidirish',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('Mahsulot topilmadi'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE7F3EB),
                          child: Icon(
                            _iconFor(product.category),
                            color: const Color(0xFF16834A),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(product.category),
                        trailing: Text(
                          product.unit.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Sabzavotlar':
        return Icons.eco_outlined;
      case 'Mevalar':
        return Icons.local_grocery_store_outlined;
      case 'Go‘sht va sut':
        return Icons.egg_alt_outlined;
      case 'Ichimliklar':
        return Icons.local_drink_outlined;
      case 'Maishiy kimyo':
        return Icons.cleaning_services_outlined;
      case 'Uy-ro‘zg‘or':
        return Icons.home_outlined;
      default:
        return Icons.shopping_basket_outlined;
    }
  }
}
