import 'package:flutter/material.dart';

import '../models/product.dart';

import '../services/cart_store.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savatcha')),
      body: AnimatedBuilder(
        animation: CartStore.instance,
        builder: (context, _) {
          final cart = CartStore.instance;
          if (cart.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.black38),
                  SizedBox(height: 12),
                  Text('Savatchangiz hozircha bo‘sh',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  SizedBox(height: 6),
                  Text('Katalogdan mahsulot tanlang.'),
                ],
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ...cart.items.map((line) => Card(
                child: ListTile(
                  title: Text(line.product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(line.product.category + ' • ' + line.product.unit.label),
                  leading: CircleAvatar(child: Text(line.quantity.toString())),
                  trailing: SizedBox(
                    width: 112,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => cart.decrease(line.product),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(line.quantity.toString()),
                        IconButton(
                          onPressed: () => cart.add(line.product),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 12),
              Text('Jami mahsulot: ${cart.itemCount} dona/birlik',
                style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Mahsulot narxlari va buyurtmani rasmiylashtirish keyingi bosqichda ulanadi.',
                style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: cart.clear,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Savatchani tozalash'),
              ),
            ],
          );
        },
      ),
    );
  }
}
