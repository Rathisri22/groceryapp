import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/models/cart_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Fetch all products from Firestore
  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _db.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// ✅ Add new product (used by Admin)
  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add(product.toMap());
  }

  /// ✅ Update existing product (used by Admin)
  Future<void> updateProduct(String productId, ProductModel product) async {
    await _db.collection('products').doc(productId).update(product.toMap());
  }

  /// ✅ Delete a product (used by Admin)
  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  /// ✅ Place an order and save it to 'orders' collection
  Future<void> placeOrder({
    required String uid,
    required String address,
    required List<CartItem> items,
    required double total,
  }) async {
    final orderData = {
      'userId': uid,
      'address': address,
      'items': items
          .map((item) => {
                'productId': item.id,
                'name': item.name,
                'price': item.price,
                'quantity': item.quantity,
              })
          .toList(),
      'total': total,
      'status': 'Pending',
      'timestamp': Timestamp.now(),
    };

    await _db.collection('orders').add(orderData);
  }

  /// ✅ Fetch all orders placed by a specific user
  Future<List<Map<String, dynamic>>> getUserOrders(String uid) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// ✅ Fetch all orders (Admin)
  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final snapshot =
        await _db.collection('orders').orderBy('timestamp', descending: true).get();

    return snapshot.docs.map
    ((doc) => doc.data()).toList();
  }

  Future<List<ProductModel>> fetchProducts() async {
  final snapshot = await _db.collection('products').get();
  return snapshot.docs
      .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
      .toList();
}
Future<Map<String, List<ProductModel>>> getProductsByCategory() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('products').get();

  Map<String, List<ProductModel>> categoryMap = {};
  
  for (var doc in snapshot.docs) {
    ProductModel product = ProductModel.fromFirestore(doc);
    String category = product.category;

    if (!categoryMap.containsKey(category)) {
      categoryMap[category] = [];
    }
    categoryMap[category]!.add(product);
  }

  return categoryMap;
}

}
