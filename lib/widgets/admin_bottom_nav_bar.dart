import 'package:flutter/material.dart';

class AdminNavBar extends StatelessWidget {
  final int selectedIndex;

  const AdminNavBar({
    super.key,
    required this.selectedIndex,
  });

  void navigate(BuildContext context, int index) {
    if (index == selectedIndex) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushNamed(
          context,
          '/users',
        );
        break;

      case 1:
        Navigator.pushNamed(
          context,
          '/products',
        );
        break;

      case 2:
        Navigator.pushNamed(
          context,
          '/order_manage',
        );
        break;

      case 3:
        Navigator.pushNamed(
          context,
          '/slider_management',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,

      backgroundColor: Colors.black87,

      selectedItemColor:
      const Color(0xFFC67C4E),

      unselectedItemColor:
      Colors.white70,

      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        navigate(context, index);
      },

      items: const [

        BottomNavigationBarItem(
          icon: Icon(Icons.people_alt_rounded),
          label: "Users",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.production_quantity_limits_sharp),
          label: "Products",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Orders",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.view_carousel),
          label: "Slider",
        ),

      ],
    );
  }
}