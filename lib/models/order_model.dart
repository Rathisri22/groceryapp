import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item.dart';

class OrderModel {
  final String id;
  final String userId;
  final String address;
  final List<CartItem> items;
  final double total;
  final String status;
  final DateTime timestamp;

  OrderModel({
    required this.id,
    required this.userId,
    required this.address,
    required this.items,
    required this.total,
    required this.status,
    required this.timestamp,
  });

  // 🔁 Convert Firestore document to OrderModel
  factory OrderModel.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderModel(
      id: documentId,
      userId: data['userId'] ?? '',
      address: data['address'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'Pending',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      items: (data['items'] as List<dynamic>).map((item) {
        return CartItem(
          product: CartItem.extractProductFromMap(item),
          quantity: item['quantity'] ?? 1, id: '', name: '', price: (item['price'] ?? 0).toDouble(),
 imageUrl: '', productId: '', paymentMethod: '',
        );
      }).toList(),
    );
  }

  // 🔁 Convert OrderModel to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'address': address,
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
