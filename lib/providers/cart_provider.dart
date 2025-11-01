import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<Product> _items = [];

  List<Product> get items => _items;

  double get totalPrice {
    return _items.fold(0.0, (sum, item) => sum + item.price);
  }

  void addProduct(Product product) {
    _items.add(product);
    notifyListeners();
  }

  void resetCart() {
    _items.clear();
    notifyListeners();
  }
}
