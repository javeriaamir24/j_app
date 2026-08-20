import 'package:flutter/material.dart';
import 'package:j_app/models/product_model.dart';
import 'package:j_app/widgets/admin_bottom_nav_bar.dart';

import 'product_functions.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();

    _loadProducts();
  }

  void _loadProducts() {
    _productsFuture = getProducts();
  }

  void _refreshProducts() {
    setState(() {
      _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,

        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: () async {
              await openAddProduct(context);

              _refreshProducts();
            },

            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),

      body: FutureBuilder<List<Product>>(
        future: _productsFuture,

        builder: (context, snapshot) {

          // Loading
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.black87,
              ),
            );
          }

          // Error
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Something went wrong',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
            );
          }

          final products = snapshot.data ?? [];

          // Empty
          if (products.isEmpty) {
            return const Center(
              child: Text(
                'No products available',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                ),
              ),
            );
          }

          // Product list
          return ListView.builder(
            padding: const EdgeInsets.all(16),

            itemCount: products.length,

            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                color: Colors.white,

                elevation: 3,

                margin: const EdgeInsets.only(
                  bottom: 14,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Row(
                    children: [

                      // Product image
                      Container(
                        height: 75,
                        width: 75,

                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,

                          borderRadius:
                          BorderRadius.circular(12),
                        ),

                        clipBehavior: Clip.antiAlias,

                        child: Image.asset(
                          product.image,

                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return const Icon(
                              Icons.coffee,
                              size: 38,
                              color: Colors.black87,
                            );
                          },
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Product information
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(
                              product.name,

                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              'Rs. ${product.price.toStringAsFixed(2)}',

                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight:
                                FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              product.category,

                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),

                            const SizedBox(height: 5),

                            // Popular status
                            Row(
                              children: [
                                Icon(
                                  product.popular
                                      ? Icons.star
                                      : Icons.star_border,

                                  size: 16,

                                  color: product.popular
                                      ? Colors.orange
                                      : Colors.grey,
                                ),

                                const SizedBox(width: 4),

                                Text(
                                  product.popular
                                      ? 'Popular'
                                      : 'Not Popular',

                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w500,
                                    color: product.popular
                                        ? Colors.orange
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Edit and Delete buttons
                      Column(
                        children: [

                          IconButton(
                            tooltip: 'Edit',

                            onPressed: () async {
                              await openEditProduct(
                                context,
                                product,
                              );

                              _refreshProducts();
                            },

                            icon: const Icon(
                              Icons.edit,
                              color: Colors.black87,
                            ),
                          ),

                          IconButton(
                            tooltip: 'Delete',

                            onPressed: () async {
                              await deleteProduct(
                                context,
                                product,
                              );

                              _refreshProducts();
                            },

                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      bottomNavigationBar: const AdminNavBar(
        selectedIndex: 1,
      ),
    );
  }
}