import 'package:flutter/material.dart';
import 'package:j_app/widgets/admin_bottom_nav_bar.dart';


class OrderManagement extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("Manage Orders"),
      ),
      bottomNavigationBar: const AdminNavBar(
        selectedIndex: 2,
      ),
    );
  }
}