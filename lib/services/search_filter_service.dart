import '../models/product_model.dart';

class SearchFilterService {
  static List<ProductModel> searchProducts(
      List<ProductModel> products, String query) {
    return products
        .where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase()) ||
            p.description.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  static List<ProductModel> filterProducts(
    List<ProductModel> products, {
    String? category,
    double? minPrice,
    double? maxPrice,
    String? brand,
    bool? available,
  }) {
    return products.where((p) {
      bool matches = true;
      if (category != null && p.category != category) matches = false;
      if (minPrice != null && p.price < minPrice) matches = false;
      if (maxPrice != null && p.price > maxPrice) matches = false;
      if (brand != null && p.brand != brand) matches = false;
      if (available != null && p.available != available) matches = false;
      return matches;
    }).toList();
  }

  static List<ProductModel> sortProducts(
      List<ProductModel> products, String sortBy) {
    List<ProductModel> sortedList = [...products];
    if (sortBy == 'price_low_high') {
      sortedList.sort((a, b) => a.price.compareTo(b.price));
    } else if (sortBy == 'price_high_low') {
      sortedList.sort((a, b) => b.price.compareTo(a.price));
    } else if (sortBy == 'popularity') {
      sortedList.sort((a, b) => b.popularity.compareTo(a.popularity));
    } else if (sortBy == 'alphabetical') {
      sortedList.sort((a, b) => a.name.compareTo(b.name));
    }
    return sortedList;
  }
}
