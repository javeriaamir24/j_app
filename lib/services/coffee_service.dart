import 'package:firebase_database/firebase_database.dart';

class CoffeeService {
  final DatabaseReference _coffeeRef = FirebaseDatabase.instance.ref('coffees');

  Future<List<Map<String, dynamic>>> getCoffees() async {
    final snapshot = await _coffeeRef.get();

    if (!snapshot.exists) {
      return [];
    }

    final data = Map<String, dynamic>.from(
      snapshot.value as Map,
    );

    return data.entries.map((entry) {
      final coffee = Map<String, dynamic>.from(
        entry.value as Map,
      );

      coffee['id'] = entry.key;

      return coffee;
    }).toList();
  }
}