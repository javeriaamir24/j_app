import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:j_app/widgets/admin_bottom_nav_bar.dart';


class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({
    super.key,
    required this.product,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState
    extends State<EditProductPage> {

  final ProductService _productService = ProductService();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  late TextEditingController _detailedDescriptionController;
  late TextEditingController _categoryController;
  late bool _popular;
  bool _isLoading = false;

  FilePickerResult? result;
  File? _selectedImage;

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

    try {
      final response = await request.send();

      final responseData =
      await response.stream.bytesToString();

      print('CLOUDINARY STATUS: ${response.statusCode}');
      print('CLOUDINARY RESPONSE: $responseData');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);

        return data['secure_url'];
      }

      return null;
    } catch (e) {
      print('CLOUDINARY ERROR: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product.name,);

    _priceController = TextEditingController(text: widget.product.price.toString(),);

    _descriptionController = TextEditingController(text: widget.product.description,);

    _detailedDescriptionController = TextEditingController(text: widget.product.detailedDescription,     );

    _categoryController = TextEditingController(text: widget.product.category,);

    _popular = widget.product.popular;
  }

  Future<void> _updateProduct() async {
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
      String? imageUrl;

      // Upload only if a new image was selected
      if (_selectedImage != null) {
        imageUrl = await uploadImage(_selectedImage!);

        if (imageUrl == null) {
          throw Exception('Image upload failed');
        }
      }

      await _productService.updateProduct(
        id: widget.product.id,
        name: name,
        price: price,
        category: category,
        description: description,
        detailedDescription: detailedDescription,
        popular: _popular,
        imageUrl: imageUrl,
      );

      Fluttertoast.showToast(
        msg: 'Product updated successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Update product error: $e');

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
                  borderRadius: BorderRadius.circular(15),
                ),

                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),

                  child: Image.file(
                    _selectedImage!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                )
                    : widget.product.image.startsWith('http')
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(15),

                  child: Image.network(
                    widget.product.image,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,

                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const Icon(
                        Icons.broken_image,
                        size: 70,
                        color: Colors.grey,
                      );
                    },
                  ),
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(15),

                  child: Image.asset(
                    widget.product.image,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFFC67C4E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),

                icon: const Icon(
                  Icons.image,
                ),

                label: const Text(
                  'Choose New Image',
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: const AdminNavBar(
          selectedIndex: 1,
        ),
      ),
    );
  }
}