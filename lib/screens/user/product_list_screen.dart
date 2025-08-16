import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grocery_app/models/product_model.dart';
import 'package:grocery_app/screens/user/product_detail_screen.dart';
import 'package:grocery_app/widgets/product_tile.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Grocery App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .snapshots(), // 🔹 Live updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No products found"));
          }

          // Group products by category
          Map<String, List<ProductModel>> categoryMap = {};
          for (var doc in snapshot.data!.docs) {
            ProductModel product = ProductModel.fromFirestore(doc);
            String category =
                (product.category.isNotEmpty ? product.category : "Others")
                    .trim();
            categoryMap.putIfAbsent(category, () => []);
            categoryMap[category]!.add(product);
          }

          return ListView.builder(
            itemCount: categoryMap.keys.length,
            itemBuilder: (context, index) {
              final category = categoryMap.keys.elementAt(index);
              final products = categoryMap[category]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...products.map(
                    (product) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProductDetailScreen(product: product),
                          ),
                        );
                      },
                      child: ProductTile(product: product),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
