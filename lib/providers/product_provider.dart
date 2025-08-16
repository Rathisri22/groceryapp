import 'package:flutter/material.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/services/firestore_service.dart';

class ProductProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<ProductModel> _products = [];
  List<ProductModel> get products => _filteredProducts;

  List<ProductModel> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  RangeValues _priceRange = const RangeValues(0, 1000);
  String _selectedBrand = 'All';
  bool _onlyAvailable = false;
  String _sortOption = 'None';

  Future<void> fetchProducts() async {
    _products = await _firestoreService.fetchProducts();
    applyFilters();
  }

  void updateSearch(String query) {
    _searchQuery = query.toLowerCase();
    applyFilters();
  }

  void updateCategory(String category) {
    _selectedCategory = category;
    applyFilters();
  }

  void updatePriceRange(RangeValues range) {
    _priceRange = range;
    applyFilters();
  }

  void updateBrand(String brand) {
    _selectedBrand = brand;
    applyFilters();
  }

  void updateAvailability(bool onlyAvailable) {
    _onlyAvailable = onlyAvailable;
    applyFilters();
  }

  void updateSort(String sortOption) {
    _sortOption = sortOption;
    applyFilters();
  }

  void applyFilters() {
    _filteredProducts = _products.where((product) {
      final matchesSearch = product.name.toLowerCase().contains(_searchQuery);
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesPrice =
          product.price >= _priceRange.start &&
          product.price <= _priceRange.end;
      final matchesBrand =
          _selectedBrand == 'All' || product.brand == _selectedBrand;
      final matchesAvailability =
    !_onlyAvailable || (product.isAvailable ?? false);
      return matchesSearch &&
          matchesCategory &&
          matchesPrice &&
          matchesBrand &&
          matchesAvailability;
    }).toList();

    // Sorting logic
    if (_sortOption == 'Price: Low to High') {
      _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == 'Price: High to Low') {
      _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortOption == 'Alphabetical') {
      _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
    } else if (_sortOption == 'Popularity') {
      _filteredProducts.sort((a, b) => b.popularity.compareTo(a.popularity));
    }

    notifyListeners();
  }
}
