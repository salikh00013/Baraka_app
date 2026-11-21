enum ProductUnit { kg, dona, litr, pachka, quti, boglam }

extension ProductUnitLabel on ProductUnit {
  String get label {
    switch (this) {
      case ProductUnit.kg:
        return 'kg';
      case ProductUnit.dona:
        return 'dona';
      case ProductUnit.litr:
        return 'litr';
      case ProductUnit.pachka:
        return 'pachka';
      case ProductUnit.quti:
        return 'quti';
      case ProductUnit.boglam:
        return 'bog‘lam';
    }
  }
}

class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
  });

  final String id;
  final String name;
  final String category;
  final ProductUnit unit;
}
