import 'package:flutter/material.dart';

class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onChanged;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: categories.map((c) {
        final isSelected = c == selected;
        return ChoiceChip(
          label: Text(c),
          selected: isSelected,
          onSelected: (_) => onChanged(c),
          selectedColor: Colors.green,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}
