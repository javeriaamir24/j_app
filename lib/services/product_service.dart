import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/models/product_model.dart';

class ProductService {
  final DatabaseReference _coffeesRef =
  FirebaseDatabase.instance.ref('coffees');

  Future<List<Product>> getProducts() async {
    final snapshot = await _coffeesRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      return [];
    }

    final data = Map<dynamic, dynamic>.from(
      snapshot.value as Map,
    );

    return data.entries.map((entry) {
      return Product.fromMap(
        entry.key.toString(),
        Map<dynamic, dynamic>.from(entry.value),
      );
    }).toList();
  }

  Future<void> addProduct({
    required String name,
    required double price,
    required String category,
    required String description,
    required String detailedDescription,
    required bool popular,
  }) async {
    final newCoffee = _coffeesRef.push();

    await newCoffee.set({
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'detailedDescription': detailedDescription,

      // Default image for now
      'image': 'assets/images/coffee_themed.avif',

      'popular': popular,
    });
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String category,
    required String description,
    required String detailedDescription,
    required bool popular,
  }) async {
    await _coffeesRef.child(id).update({
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'detailedDescription': detailedDescription,
      'popular': popular,
    });
  }

  Future<void> deleteProduct(String id) async {
    await _coffeesRef.child(id).remove();
  }
}