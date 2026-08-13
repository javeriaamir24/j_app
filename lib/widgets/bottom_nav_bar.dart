import 'package:flutter/material.dart';
import 'package:j_app/data/cart_data.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BottomNavBar extends StatelessWidget {

  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  void navigate(BuildContext context, int index) {

    if (index == selectedIndex) {
      return;
    }

    if (index == 0) {
      Navigator.pushNamed(context, '/home');
    }


    if (index == 1) {
      Navigator.pushNamed(context, '/cart');
    }

    if (index == 2) {
      Navigator.pushNamed(context, '/order');
    }

    if (index == 3) {
      Navigator.pushNamed(context, '/wish');
    }

    if (index == 4) {
      Navigator.pushNamed(context, '/profile');
    }


  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(

      currentIndex: selectedIndex,

      backgroundColor: Colors.black87,

      selectedItemColor: const Color(0xFFC67C4E),

      unselectedItemColor: Colors.white70,

      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        navigate(context, index);
      },

      items: [

        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),


        BottomNavigationBarItem(
          icon: ValueListenableBuilder(
            valueListenable: cartBox.listenable(),

            builder: (context, box, _) {

              final cartCount = box.length;

              return Badge(
                backgroundColor: selectedIndex == 1
                    ? Colors.white
                    : const Color(0xFFC67C4E),

                textColor: selectedIndex == 1
                    ? Color(0xFFC67C4E)
                    : Colors.white,

                isLabelVisible: cartCount > 0,

                label: Text(
                  cartCount.toString(),
                ),

                child: const Icon(
                  Icons.shopping_cart,
                ),
              );
            },
          ),

          label: "Cart",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Order",
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "WishList",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),

      ],
    );
  }
}