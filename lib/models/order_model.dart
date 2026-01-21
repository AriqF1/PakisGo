import 'product_model.dart';

class Order {
  final String id;
  final List<Product> items;
  final double total;
  final DateTime date;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.date,
  });
}
