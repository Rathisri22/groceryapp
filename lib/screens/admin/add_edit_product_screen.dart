import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app/models/product_model.dart';

class AddEditProductScreen extends StatefulWidget {
  final ProductModel? product; // null => Add

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _image;
  late final TextEditingController _desc;
  late final TextEditingController _unit;
  late final TextEditingController _discount;
  late final TextEditingController _customCategory;

  final List<String> _fixedCategories = const [
    'Fruits',
    'Vegetables',
    'Dairy',
    'Bakery',
  ];
  String _selectedCategory = 'Fruits';
  bool _isPopular = false;
  bool _isRecommended = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;

    _name = TextEditingController(text: p?.name ?? '');
    _price = TextEditingController(text: p?.price.toString() ?? '');
    _image = TextEditingController(text: p?.imageUrl ?? '');
    _desc = TextEditingController(text: p?.description ?? '');
    _unit = TextEditingController(text: p?.unit ?? 'per piece');
    _discount =
        TextEditingController(text: (p?.discount ?? 0).toStringAsFixed(0));
    _customCategory = TextEditingController();

    _selectedCategory = p?.category ?? 'Fruits';
    _isPopular = p?.isPopular ?? false;
    _isRecommended = p?.isRecommended ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _image.dispose();
    _desc.dispose();
    _unit.dispose();
    _discount.dispose();
    _customCategory.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final category = (_selectedCategory == 'Custom' &&
            _customCategory.text.trim().isNotEmpty)
        ? _customCategory.text.trim()
        : _selectedCategory;

    final data = {
      'Name': _name.text.trim(),
      'Description': _desc.text.trim(),
      'Price': double.tryParse(_price.text.trim()) ?? 0.0,
      'imageUrl': _image.text.trim(),
      'unit': _unit.text.trim().isEmpty ? 'unit' : _unit.text.trim(),
      'category': category,
      'discount': double.tryParse(_discount.text.trim()) ?? 0.0,
      'isPopular': _isPopular,
      'isRecommended': _isRecommended,
    };

    try {
      final col = FirebaseFirestore.instance.collection('products');
      if (widget.product == null) {
        await col.add(data);
      } else {
        await col.doc(widget.product!.id).update(data);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving product: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _price,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _unit,
                decoration:
                    const InputDecoration(labelText: 'Unit (e.g., per kg)'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _image,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _desc,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 12),

              // ===== Categories via ChoiceChips =====
              const Text('Category',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ..._fixedCategories.map((c) => ChoiceChip(
                        label: Text(c),
                        selected: _selectedCategory == c,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = c),
                        selectedColor: Colors.green,
                        labelStyle: TextStyle(
                          color: _selectedCategory == c
                              ? Colors.white
                              : Colors.black,
                        ),
                      )),
                  ChoiceChip(
                    label: const Text('Custom'),
                    selected: _selectedCategory == 'Custom',
                    onSelected: (_) =>
                        setState(() => _selectedCategory = 'Custom'),
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: _selectedCategory == 'Custom'
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ],
              ),
              if (_selectedCategory == 'Custom') ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _customCategory,
                  decoration:
                      const InputDecoration(labelText: 'Custom category'),
                  validator: (v) {
                    if (_selectedCategory == 'Custom' &&
                        (v == null || v.trim().isEmpty)) {
                      return 'Enter a category';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),

              TextFormField(
                controller: _discount,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                    labelText: 'Discount % (optional)'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Is Popular'),
                value: _isPopular,
                onChanged: (v) => setState(() => _isPopular = v),
              ),
              SwitchListTile(
                title: const Text('Is Recommended'),
                value: _isRecommended,
                onChanged: (v) => setState(() => _isRecommended = v),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Update Product' : 'Add Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
