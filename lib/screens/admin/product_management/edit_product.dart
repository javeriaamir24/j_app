import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({
    super.key,
    required this.product,
  });

  @override
  State<EditProductPage> createState() =>
      _EditProductPageState();
}

class _EditProductPageState
    extends State<EditProductPage> {

  final ProductService _productService =
  ProductService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _detailedDescriptionController;
  late TextEditingController _categoryController;

  late bool _popular;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.product.name,
    );

    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );

    _descriptionController =
        TextEditingController(
          text: widget.product.description,
        );

    _detailedDescriptionController =
        TextEditingController(
          text: widget.product.detailedDescription,
        );

    _categoryController =
        TextEditingController(
          text: widget.product.category,
        );

    _popular = widget.product.popular;
  }

  Future<void> _updateProduct() async {
    final name = _nameController.text.trim();

    final priceText =
    _priceController.text.trim();

    final description =
    _descriptionController.text.trim();

    final detailedDescription =
    _detailedDescriptionController.text.trim();

    final category =
    _categoryController.text.trim();

    if (name.isEmpty ||
        priceText.isEmpty ||
        description.isEmpty ||
        detailedDescription.isEmpty ||
        category.isEmpty) {
      Fluttertoast.showToast(
        msg: 'Please fill all fields',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      return;
    }

    final price = double.tryParse(priceText);

    if (price == null) {
      Fluttertoast.showToast(
        msg: 'Please enter a valid price',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _productService.updateProduct(
        id: widget.product.id,
        name: name,
        price: price,
        category: category,
        description: description,
        detailedDescription: detailedDescription,
        popular: _popular,
      );

      Fluttertoast.showToast(
        msg: 'Product updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to update product',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _detailedDescriptionController.dispose();
    _categoryController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,

        title: const Text(
          'Edit Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // Default image
            Center(
              child: Container(
                height: 150,
                width: 150,

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,

                  borderRadius:
                  BorderRadius.circular(15),
                ),

                child: const Icon(
                  Icons.coffee,
                  size: 70,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'Product Name',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _nameController,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Price',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _priceController,

              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),

              decoration: InputDecoration(
                prefixText: 'Rs. ',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Category',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _categoryController,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Description',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _descriptionController,

              maxLines: 2,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Detailed Description',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller:
              _detailedDescriptionController,

              maxLines: 5,

              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              contentPadding: EdgeInsets.zero,

              title: const Text(
                'Popular',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              value: _popular,

              activeColor: Colors.black87,

              onChanged: (value) {
                setState(() {
                  _popular = value;
                });
              },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed:
                _isLoading
                    ? null
                    : _updateProduct,

                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  Colors.black87,

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                child: _isLoading
                    ? const SizedBox(
                  height: 22,
                  width: 22,

                  child:
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}