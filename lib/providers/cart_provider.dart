import 'package:flutter/material.dart';
import 'package:grocery_app/models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _cartItems = [];
  String _paymentMethod = 'COD'; // Default payment method

  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

  String get paymentMethod => _paymentMethod;

  get itemsCount => null;

  get items => null;

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  /// Add an item to the cart
  void addToCart(CartItem item, int quantity) {
    // Check if same product *and* same payment method already exists
    final index = _cartItems.indexWhere(
      (i) =>
          i.productId == (item.productId) &&
          i.paymentMethod == _paymentMethod,
    );

    if (index >= 0) {
      // Increase quantity for same product & payment method
      _cartItems[index].quantity += quantity;
    } else {
      // Add as a new product entry
      _cartItems.add(
        CartItem(
          productId: item.productId,
          name: item.name,
          price: item.price,
          quantity: quantity,
          imageUrl: item.imageUrl,
          product: item.product,
          id: item.id ?? '',
          paymentMethod: _paymentMethod,
        ),
      );
    }

    notifyListeners();
  }

  /// Remove item completely from the cart
  void removeFromCart(String productId, String paymentMethod) {
    _cartItems.removeWhere(
      (item) => item.productId == productId && item.paymentMethod == paymentMethod,
    );
    notifyListeners();
  }

  /// Clear all items from the cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Increase quantity of a specific product
  void increaseQuantity(String productId, String paymentMethod) {
    final index = _cartItems.indexWhere(
      (i) => i.productId == productId && i.paymentMethod == paymentMethod,
    );
    if (index >= 0) {
      _cartItems[index].quantity++;
      notifyListeners();
    }
  }

  /// Decrease quantity of a specific product
  void decreaseQuantity(String productId, String paymentMethod) {
    final index = _cartItems.indexWhere(
      (i) => i.productId == productId && i.paymentMethod == paymentMethod,
    );
    if (index >= 0) {
      if (_cartItems[index].quantity > 1) {
        _cartItems[index].quantity--;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(id) {}
}
