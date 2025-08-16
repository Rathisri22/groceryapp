import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grocery_app/services/auth_service.dart';
import 'package:grocery_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  User? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 🔁 Keep state up-to-date
  void updateUser(User? user) {
    _user = user;
    notifyListeners();
  }

  // ✅ Check current user on app start
  void checkLoginStatus() {
    _user = _authService.currentUser;
    notifyListeners();
  }

  // 🔐 Register
  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await _authService.registerUser(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      _user = user;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔑 Login
  Future<String?> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await _authService.loginUser(email, password);
      _user = user;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔓 Logout (with full app data reset)
  Future<void> logout(BuildContext context) async {
    await _authService.logout();
    _user = null;

    // Also clear cart and reset payment method
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    cartProvider.clearCart();
    cartProvider.setPaymentMethod('COD');

    notifyListeners();
  }

  // 📩 Forgot Password
  Future<String?> sendResetLink(String email) async {
    try {
      await _authService.sendPasswordReset(email);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔐 Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await _authService.signInWithGoogle();
      _user = user;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
