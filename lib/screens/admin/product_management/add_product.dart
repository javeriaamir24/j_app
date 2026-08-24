import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../services/product_service.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final ProductService _productService = ProductService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController =
  TextEditingController();
  final TextEditingController _detailedDescriptionController =
  TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  bool _popular = false;
  bool _isLoading = false;

  FilePickerResult? result;
  File? _selectedImage;

  // =========================
  // PICK IMAGE
  // =========================

  Future<void> pickImage() async {
    final pickedResult = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (pickedResult != null &&
        pickedResult.files.single.path != null) {
      setState(() {
        result = pickedResult;
        _selectedImage = File(
          pickedResult.files.single.path!,
        );
      });
    }
  }

  // =========================
  // UPLOAD IMAGE TO CLOUDINARY
  // =========================

  Future<String?> uploadImage(File imageFile) async {
    final cloudName = 'qaakxnsu';
    final uploadPreset = 'cafe_products';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final response = await request.send();

    final responseData =
    await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);

      return data['secure_url'];
    } else {
      print(
        'Cloudinary upload failed: $responseData',
      );

      return null;
    }
  }

  // =========================
  // ADD PRODUCT
  // =========================

  Future<void> _addProduct() async {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    final description = _descriptionController.text.trim();
    final detailedDescription =
    _detailedDescriptionController.text.trim();
    final category = _categoryController.text.trim();

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
      // =========================
      // UPLOAD IMAGE
      // =========================

      String? imageUrl;

      if (_selectedImage != null) {
        imageUrl = await uploadImage(
          _selectedImage!,
        );

        if (imageUrl == null) {
          throw Exception(
            'Image upload failed',
          );
        }
      }

      // =========================
      // SAVE PRODUCT TO FIREBASE
      // =========================

      await _productService.addProduct(
        name: name,
        price: price,
        category: category,
        description: description,
        detailedDescription: detailedDescription,
        popular: _popular,
        imageUrl: imageUrl,
      );

      Fluttertoast.showToast(
        msg: 'Product added successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Add product error: $e');

      Fluttertoast.showToast(
        msg: 'Failed to add product',
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

  // =========================
  // DISPOSE
  // =========================

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _detailedDescriptionController.dispose();
    _categoryController.dispose();

    super.dispose();
  }

  // =========================
  // UI
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,

        title: const Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            // =========================
            // IMAGE PREVIEW
            // =========================

            Center(
              child: Container(
                height: 150,
                width: 150,

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius:
                  BorderRadius.circular(15),

                  child: Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                )
                    : const Icon(
                  Icons.coffee,
                  size: 70,
                  color: Colors.black87,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // =========================
            // CHOOSE IMAGE BUTTON
            // =========================

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : pickImage,

                icon: const Icon(
                  Icons.image,
                ),

                label: const Text(
                  'Choose Image',
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // PRODUCT NAME
            // =========================

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
                hintText: 'Enter product name',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // PRICE
            // =========================

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
                hintText: 'Enter price',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // CATEGORY
            // =========================

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
                hintText: 'Enter category',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // DESCRIPTION
            // =========================

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
                hintText:
                'Enter short description',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // DETAILED DESCRIPTION
            // =========================

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
                hintText:
                'Enter detailed description',

                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 10),



            SwitchListTile(
              contentPadding:
              EdgeInsets.zero,

              title: const Text(
                'Popular',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              value: _popular,

              activeColor: Colors.black87,

              onChanged: _isLoading
                  ? null
                  : (value) {
                setState(() {
                  _popular = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // =========================
            // ADD PRODUCT BUTTON
            // =========================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed:
                _isLoading ? null : _addProduct,

                style:
                ElevatedButton.styleFrom(
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
                  'Add Product',
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