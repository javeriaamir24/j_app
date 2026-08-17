import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'admin_chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:j_app/screens/first_Screen.dart';
import 'dart:async';
import 'saved_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';



class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchText =
            searchController.text.toLowerCase().trim();
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
        actions: [
          Padding(
            padding: const EdgeInsets.all (10),
              child: IconButton(
                onPressed: () {
                 signout();
                },
                icon: const Icon(
                  Icons.logout_outlined, color: Colors.white,
                ),
              ),

          ),
        ],

      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,

              cursorColor: const Color(0xFFC67C4E),

              decoration: InputDecoration(
                hintText: "Search users...",

                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFFC67C4E),
                ),

                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                )
                    : null,

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Color(0xFFC67C4E),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          // USERS
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref("users")
                  .onValue,

              builder: (context, snapshot) {

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Something went wrong",
                    ),
                  );
                }

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC67C4E),
                    ),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text("No users found"),
                  );
                }

                final rawData =
                    snapshot.data!.snapshot.value;

                if (rawData is! Map) {
                  return const Center(
                    child: Text("No users found"),
                  );
                }

                final data =
                Map<dynamic, dynamic>.from(rawData);

                // ONLY CUSTOMERS
                final customers = data.entries.where((entry) {

                  final user =
                  Map<dynamic, dynamic>.from(
                    entry.value,
                  );

                  return user["role"] == "customer";

                }).toList();

                // SEARCH
                final filteredCustomers =
                customers.where((entry) {

                  final user =
                  Map<dynamic, dynamic>.from(
                    entry.value,
                  );

                  final name =
                      user["name"]
                          ?.toString()
                          .toLowerCase() ??
                          "";

                  final email =
                      user["email"]
                          ?.toString()
                          .toLowerCase() ??
                          "";

                  return name.contains(searchText) ||
                      email.contains(searchText);

                }).toList();

                if (filteredCustomers.isEmpty) {
                  return const Center(
                    child: Text(
                      "No customers found",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredCustomers.length,

                  itemBuilder: (context, index) {

                    final entry =
                    filteredCustomers[index];

                    final uid =
                    entry.key.toString();

                    final user =
                    Map<dynamic, dynamic>.from(
                      entry.value,
                    );

                    final name =
                        user["name"]?.toString() ??
                            "Unknown User";

                    final email =
                        user["email"]?.toString() ??
                            "";

                    return ListTile(
                      contentPadding:
                      const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 5,
                      ),

                      leading: CircleAvatar(
                        radius: 25,

                        backgroundColor:
                        const Color(0xFFC67C4E),

                        child: Text(
                          name.isNotEmpty
                              ? name[0].toUpperCase()
                              : "?",

                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      title: Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      subtitle: Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      trailing: const Icon(
                        Icons.chat_outlined,
                        color: Color(0xFFC67C4E),
                      ),

                      onTap: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AdminChat(
                                  customerId: uid,
                                  customerName: name,
                                ),
                          ),
                        );

                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Future<void> signout() async {

    final bool? remember = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Sign Out",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),

          content: const Text(
            "Do you want this device to remember your login?",
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Color(0xFFC67C4E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (remember == null) {
      return;
    }

    if (remember == false) {

      await _storage.delete(
        key: 'saved_email',
      );

      await _storage.delete(
        key: 'saved_password',
      );

      await _storage.write(
        key: 'remember_login',
        value: 'false',
      );

      await FirebaseAuth.instance.signOut();

      if (!mounted) {
        return;
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) =>
          const FirstScreen(),
        ),
            (route) => false,
      );

      return;
    }

    await _storage.write(
      key: 'remember_login',
      value: 'true',
    );

    await FirebaseAuth.instance.signOut();

    if (!mounted) {
      return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const SavedScreen(),
      ),
          (route) => false,
    );
  }

}
