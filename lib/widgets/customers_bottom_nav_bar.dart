import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:j_app/screens/customer/customer_chat.dart';

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

    switch (index) {

      case 0:
        Navigator.pushNamed(
          context,
          '/home',
        );
        break;

      case 1:
        Navigator.pushNamed(
          context,
          '/cart',
        );
        break;

      case 2:
        Navigator.pushNamed(
          context,
          '/order_history',
        );
        break;

      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
            const CustomerChat(),
          ),
        );
        break;

      case 4:
        Navigator.pushNamed(
          context,
          '/profile',
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

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

      items: [

        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),

        BottomNavigationBarItem(
          icon: user == null

              ? const Icon(
            Icons.shopping_cart,
          )

              : StreamBuilder<DatabaseEvent>(

            stream: FirebaseDatabase.instance
                .ref(
              "users/${user.uid}/cart",
            )
                .onValue,

            builder: (context, snapshot) {

              int cartCount = 0;

              if (snapshot.hasData &&
                  snapshot.data!.snapshot.value !=
                      null) {

                final data =
                    snapshot.data!.snapshot.value;

                if (data is Map) {
                  cartCount = data.length;
                }
              }

              return Badge(

                backgroundColor:
                selectedIndex == 1
                    ? Colors.white
                    : const Color(
                  0xFFC67C4E,
                ),

                textColor:
                selectedIndex == 1
                    ? const Color(
                  0xFFC67C4E,
                )
                    : Colors.white,

                isLabelVisible:
                cartCount > 0,

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

        const BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Order",
        ),

        BottomNavigationBarItem(
          icon: user == null

              ? const Icon(
            Icons.chat_bubble,
          )

              : StreamBuilder<DatabaseEvent>(
            stream: FirebaseDatabase.instance
                .ref("chats/${user.uid}/messages")
                .onValue,

            builder: (context, snapshot) {

              int unreadCount = 0;

              if (snapshot.hasData &&
                  snapshot.data!.snapshot.value != null) {

                final data =
                    snapshot.data!.snapshot.value;

                if (data is Map) {

                  for (final entry in data.entries) {

                    final message =
                    Map<dynamic, dynamic>.from(
                      entry.value,
                    );

                    final isFromAdmin =
                        message["senderType"] == "admin";

                    final isRead =
                        message["isRead"] == true;

                    if (isFromAdmin && !isRead) {
                      unreadCount++;
                    }
                  }
                }
              }

              return Badge(
                backgroundColor:
                selectedIndex == 3
                    ? Colors.white
                    : const Color(0xFFC67C4E),

                textColor:
                selectedIndex == 3
                    ? const Color(0xFFC67C4E)
                    : Colors.white,

                isLabelVisible: unreadCount > 0,

                label: Text(
                  unreadCount.toString(),
                ),

                child: const Icon(
                  Icons.chat_bubble,
                ),
              );
            },
          ),

          label: "Chat",
        ),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profile",
        ),
      ],
    );
  }
}