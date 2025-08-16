import 'package:flutter/material.dart';

class FilterWidget extends StatelessWidget {
  final Function(String?) onCategoryChanged;
  final Function(double?, double?) onPriceChanged;

  const FilterWidget({
    super.key,
    required this.onCategoryChanged,
    required this.onPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownButton<String>(
          hint: Text("Category"),
          items: ['Fruits', 'Vegetables', 'Dairy', 'Bakery']
              .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
              .toList(),
          onChanged: onCategoryChanged,
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            onPriceChanged(0, 50); // Example: set price range filter
          },
          child: Text("Price < ₹50"),
        ),
      ],
    );
  }
}
