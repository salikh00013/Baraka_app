import 'package:flutter/foundation.dart';

import '../data/initial_catalog.dart';
import '../models/product.dart';

class CartLine {
  const CartLine({required this.product, required this.quantity});

  final CatalogProduct product;
  final int quantity;

  CartLine copyWith({int? quantity}) =>
      CartLine(product: product, quantity: quantity ?? this.quantity);
}

class CartStore extends ChangeNotifier {
  CartStore._();
  static final CartStore instance = CartStore._();

  final Map<String, CartLine> _items = {};

  List<CartLine> get items => List.unmodifiable(_items.values);
  int get itemCount => _items.values.fold(0, (sum, line) => sum + line.quantity);
  bool get isEmpty => _items.isEmpty;

  void add(CatalogProduct product) {
    final current = _items[product.id];
    _items[product.id] = current == null
        ? CartLine(product: product, quantity: 1)
        : current.copyWith(quantity: current.quantity + 1);
    notifyListeners();
  }

  void decrease(CatalogProduct product) {
    final current = _items[product.id];
    if (current == null) return;
    if (current.quantity <= 1) {
      _items.remove(product.id);
    } else {
      _items[product.id] = current.copyWith(quantity: current.quantity - 1);
    }
    notifyListeners();
  }

  void remove(CatalogProduct product) {
    _items.remove(product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
