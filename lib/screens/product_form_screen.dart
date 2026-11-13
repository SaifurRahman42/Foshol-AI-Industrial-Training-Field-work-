import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/market_provider.dart';
import '../services/api_client.dart';
import '../widgets/product_image.dart';

/// Add a new item (product == null) or edit an existing one.
class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _title;
  late final TextEditingController _category;
  late final TextEditingController _brand;
  late final TextEditingController _price;
  late final TextEditingController _stock;
  late final TextEditingController _image;
  late final TextEditingController _description;

  bool _saving = false;
  final ImagePicker _imagePicker = ImagePicker();

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _title = TextEditingController(text: p?.title ?? '');
    _category = TextEditingController(text: p?.category ?? 'groceries');
    _brand = TextEditingController(text: p?.brand ?? '');
    _price = TextEditingController(text: p == null ? '' : p.price.toString());
    _stock = TextEditingController(text: p == null ? '' : p.stock.toString());
    _image = TextEditingController(text: p?.thumbnail ?? '');
    _description = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _title,
      _category,
      _brand,
      _price,
      _stock,
      _image,
      _description
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1200,
      );
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      final extension = picked.name.toLowerCase().split('.').last;
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      final dataUri = 'data:$mimeType;base64,${base64Encode(bytes)}';

      if (!mounted) return;
      setState(() => _image.text = dataUri);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not select image: $e')),
      );
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final market = context.read<MarketProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final imageUrl = _image.text.trim();
    final brand = _brand.text.trim();

    setState(() => _saving = true);

    try {
      if (_isEdit) {
        final old = widget.product!;
        final changedImage = imageUrl.isNotEmpty && imageUrl != old.thumbnail;
        final updated = old.copyWith(
          title: _title.text.trim(),
          category: _category.text.trim(),
          brand: brand.isEmpty ? null : brand,
          price: double.parse(_price.text.trim()),
          stock: int.parse(_stock.text.trim()),
          description: _description.text.trim(),
          thumbnail: changedImage ? imageUrl : null,
          images: changedImage ? [imageUrl] : null,
        );
        await market.updateProduct(updated);
        navigator.pop('Item updated');
      } else {
        final draft = Product(
          id: 0,
          title: _title.text.trim(),
          category: _category.text.trim(),
          brand: brand.isEmpty ? null : brand,
          price: double.parse(_price.text.trim()),
          stock: int.parse(_stock.text.trim()),
          description: _description.text.trim(),
          thumbnail: imageUrl,
          images: imageUrl.isEmpty ? const [] : [imageUrl],
          isLocal: true,
        );
        await market.addProduct(draft);
        navigator.pop('Item added');
      }
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit item' : 'Add item')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _title,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _required(v, 'Title'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _category,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => _required(v, 'Category'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _brand,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Brand / Farm (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Price (৳)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final n = double.tryParse((v ?? '').trim());
                          if (n == null || n <= 0) return 'Enter a valid price';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stock,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Stock',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n < 0) return 'Enter a valid number';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Product Image',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  height: 180,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context)
                        .colorScheme.surfaceContainerHighest,
                  ),
                  child: ProductImage(
                    url: _image.text.trim(),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _saving ? null : _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Choose from Gallery'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _image,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Image URL (optional)',
                    helperText: 'Use a public image URL or choose from gallery',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    final text = (v ?? '').trim();
                    if (text.isNotEmpty &&
                        !text.startsWith('http://') &&
                        !text.startsWith('https://') &&
                        !text.startsWith('data:image/')) {
                      return 'Enter a valid image URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().length < 10) {
                      return 'Write at least 10 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isEdit ? 'Save changes' : 'Add item'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
