import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];

  List<Order> get orders => _orders;

  void addOrder(List<Product> items, double total) {
    _orders.insert(
      0,
      Order(
        id: DateTime.now().toString(),
        items: items,
        total: total,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
