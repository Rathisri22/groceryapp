import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String unit; // e.g., kg, piece, litre
  final String category; // Fruits, Vegetables, Dairy, Bakery, ...
  final double discount; // percentage (0 = no discount)
  final bool isPopular;
  final bool isRecommended;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.unit,
    required this.category,
    this.discount = 0,
    this.isPopular = false,
    this.isRecommended = false,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data, String id) {
    return ProductModel(
      id: id,
      name: (data['name'] ?? data['Name'] ?? '').toString(),
      description: (data['description'] ?? data['Description'] ?? '')
          .toString(),
      price: (data['price'] ?? data['Price'] ?? 0).toDouble(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      unit: (data['unit'] ?? 'unit').toString(),
      category: (data['category'] ?? 'Others').toString().trim(),
      discount: (data['discount'] ?? 0).toDouble(),
      isPopular: (data['isPopular'] ?? false) as bool,
      isRecommended: (data['isRecommended'] ?? false) as bool,
    );
  }

  get popularity => null;

  get isAvailable => null;

  get brand => null;

  get available => null;

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'price': price,
    'imageUrl': imageUrl,
    'unit': unit,
    'category': category,
    'discount': discount,
    'isPopular': isPopular,
    'isRecommended': isRecommended,
  };

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? unit,
    String? category,
    double? discount,
    bool? isPopular,
    bool? isRecommended,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      discount: discount ?? this.discount,
      isPopular: isPopular ?? this.isPopular,
      isRecommended: isRecommended ?? this.isRecommended,
    );
  }

  static ProductModel fromFirestore(QueryDocumentSnapshot<Object?> doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ProductModel(
      id: doc.id,
      name: (data['name'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      unit: (data['unit'] ?? 'unit').toString(),
      category: (data['category'] ?? 'Others')
          .toString()
          .trim(), // trims spaces
      discount: (data['discount'] ?? 0).toDouble(),
      isPopular: (data['isPopular'] ?? false) as bool,
      isRecommended: (data['isRecommended'] ?? false) as bool,
    );
  }
}
