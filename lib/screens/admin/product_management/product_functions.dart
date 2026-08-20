import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

import 'add_product.dart';
import 'edit_product.dart';

final ProductService productService = ProductService();


Future<List<Product>> getProducts() async {
  return await productService.getProducts();
}


Future<void> openAddProduct(BuildContext context,) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddProductPage(),
    ),
  );
}


Future<void> openEditProduct(BuildContext context, Product product,) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProductPage(product: product,),
    ),
  );
}


Future<void> deleteProduct(BuildContext context, Product product,) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,

        title: const Text(
          'Delete Product',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),

        content: Text(
          'Are you sure you want to delete "${product.name}"?',
          style: const TextStyle(
            color: Colors.black54,
          ),
        ),

        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },

            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
            },

            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );

  if (shouldDelete != true) {
    return;
  }

  try {
    await productService.deleteProduct(
      product.id,
    );

    Fluttertoast.showToast(
      msg: 'Product deleted successfully',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  } catch (e) {
    Fluttertoast.showToast(
      msg: 'Failed to delete product',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}