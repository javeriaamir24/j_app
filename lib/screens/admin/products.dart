import 'package:flutter/material.dart';
import 'package:j_app/widgets/admin_bottom_nav_bar.dart';


class ProductsPage extends StatelessWidget{

@override
  Widget build(BuildContext context) {
  return Scaffold(
    body: Center(
      child: Text("Edit Products"),
    ),
    bottomNavigationBar: const AdminNavBar(
      selectedIndex: 1,
    ),
  );
  }
}