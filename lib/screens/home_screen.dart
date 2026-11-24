import 'package:flutter/material.dart';

import '../services/cart_store.dart';
import 'admin_screen.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const categories = <({String name, IconData icon})>[
    (name: 'Oziq-ovqat', icon: Icons.shopping_basket_outlined),
    (name: 'Sabzavotlar', icon: Icons.eco_outlined),
    (name: 'Mevalar', icon: Icons.local_grocery_store_outlined),
    (name: 'Go‘sht va sut', icon: Icons.egg_alt_outlined),
    (name: 'Ichimliklar', icon: Icons.local_drink_outlined),
    (name: 'Uy-ro‘zg‘or', icon: Icons.home_outlined),
    (name: 'Maishiy kimyo', icon: Icons.cleaning_services_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BARAKA',
          style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        actions: [
          IconButton(
            tooltip: 'Admin bo‘limi (test)',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminScreen())),
            icon: const Icon(Icons.admin_panel_settings_outlined)),
          AnimatedBuilder(
            animation: CartStore.instance,
            builder: (context, _) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Savatcha',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen())),
                  icon: const Icon(Icons.shopping_cart_outlined)),
                if (CartStore.instance.itemCount > 0)
                  Positioned(right: 5, top: 5, child: CircleAvatar(
                    radius: 9, backgroundColor: const Color(0xFF16834A),
                    child: Text(CartStore.instance.itemCount > 99 ? '99+' : CartStore.instance.itemCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 9)))),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFF16834A), borderRadius: BorderRadius.circular(20)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kerakli mahsulotlar — bir savatchada',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Turli do‘konlardan yig‘amiz, bitta kuryer yetkazadi.',
                  style: TextStyle(color: Colors.white, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Kategoriyalar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.4),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => CatalogScreen(category: category.name))),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(children: [
                      Icon(category.icon, color: const Color(0xFF16834A)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Center(child: Text('Kategoriyani tanlang — mahsulotlarni savatchaga qo‘shing',
            style: TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}
