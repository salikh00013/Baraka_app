import 'package:flutter/material.dart';

import '../data/initial_catalog.dart';
import '../models/product.dart';

/// Admin UI prototype. Values are held in memory only until the Supabase
/// schema and admin permissions are verified and persistence is implemented.
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String _category = 'Barchasi';
  String _search = '';
  final Map<String, _ProductDraft> _drafts = {};

  static const _categories = [
    'Barchasi',
    'Oziq-ovqat',
    'Sabzavotlar',
    'Mevalar',
    'Go‘sht va sut',
    'Ichimliklar',
    'Maishiy kimyo',
    'Uy-ro‘zg‘or',
  ];

  _ProductDraft _draftFor(CatalogProduct product) =>
      _drafts.putIfAbsent(product.id, () => _ProductDraft());

  @override
  Widget build(BuildContext context) {
    final visible = initialCatalog.where((product) {
      final categoryMatches =
          _category == 'Barchasi' || product.category == _category;
      final searchMatches =
          product.name.toLowerCase().contains(_search.trim().toLowerCase());
      return categoryMatches && searchMatches;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('BARAKA — Admin')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF3D6),
            padding: const EdgeInsets.all(12),
            child: const Text(
              'Namoyish rejimi: kiritilgan qiymatlar hozircha saqlanmaydi. '
              'Supabase ulanishi va admin ruxsatlari tekshirilgach saqlash yoqiladi.',
              style: TextStyle(fontSize: 12, color: Color(0xFF704B00)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (value) => setState(() => _search = value),
              decoration: InputDecoration(
                hintText: 'Mahsulot qidirish',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: _categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _category == category,
                    onSelected: (_) => setState(() => _category = category),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: visible.length,
              itemBuilder: (context, index) {
                final product = visible[index];
                final draft = _draftFor(product);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(product.category + ' • ' + product.unit.label),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _MoneyField(
                                label: 'Xarid tannarxi',
                                controller: draft.cost,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MoneyField(
                                label: 'BARAKA narxi',
                                controller: draft.sale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: draft.stock,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Mavjud miqdor (' + product.unit.label + ')',
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  const _MoneyField({
    required this.label,
    required this.controller,
  });

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'so‘m',
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}

class _ProductDraft {
  final cost = TextEditingController();
  final sale = TextEditingController();
  final stock = TextEditingController();
}
