import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grocery_app/providers/product_provider.dart';

class SortOptions extends StatelessWidget {
  const SortOptions({super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: 'None',
      items: [
        'None',
        'Price: Low to High',
        'Price: High to Low',
        'Alphabetical',
        'Popularity',
      ].map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
      onChanged: (val) {
        Provider.of<ProductProvider>(context, listen: false).updateSort(val!);
      },
    );
  }
}
