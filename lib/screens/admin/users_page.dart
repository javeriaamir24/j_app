import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:j_app/screens/first_Screen.dart';
import 'dart:async';
import '../saved_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:j_app/widgets/admin_bottom_nav_bar.dart';



class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController searchController = TextEditingController();

  String searchText = "";

  @override
  void initState() {
    super.initState();

    searchController.addListener(() {
      setState(() {
        searchText = searchController.text.toLowerCase().trim();
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
        title: const Text("Chats",
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
                hintText: "Search users.........",

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
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: FirebaseDatabase.instance
                  .ref("users")
                  .onValue,

              builder: (context, userSnapshot) {

                if (userSnapshot.hasError) {
                  return const Center(
                    child: Text("Something went wrong"),
                  );
                }

                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFC67C4E),
                    ),
                  );
                }

                if (!userSnapshot.hasData || userSnapshot.data!.snapshot.value == null) {
                  return const Center(
                    child: Text("No users found"),
                  );
                }

                final rawUserData = userSnapshot.data!.snapshot.value;

                if (rawUserData is! Map) {
                  return const Center(
                    child: Text("No users found"),
                  );
                }

                final userData = Map<dynamic, dynamic>.from(rawUserData);

                final customers = userData.entries.where((entry) {
                  final user = Map<dynamic, dynamic>.from(entry.value);

                  return user["role"] == "customer";

                }).toList();


                return StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance
                      .ref("chats")
                      .onValue,

                  builder: (context, chatSnapshot) {

                    if (chatSnapshot.hasError) {
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    }

                    final Map<String, Map<String, dynamic>>
                    chatInfo = {};

                    if (chatSnapshot.hasData && chatSnapshot.data!.snapshot.value != null) {

                      final rawChatData = chatSnapshot.data!.snapshot.value;

                      if (rawChatData is Map) {

                        final chats = Map<dynamic, dynamic>.from(rawChatData);

                        for (final chatEntry in chats.entries) {

                          final customerId = chatEntry.key.toString();

                          final chat = Map<dynamic, dynamic>.from(
                            chatEntry.value,
                          );

                          final rawMessages = chat["messages"];

                          if (rawMessages is! Map) {
                            continue;
                          }

                          final messages = Map<dynamic, dynamic>.from(
                            rawMessages,
                          );

                          int latestTimestamp = 0;
                          int unreadCount = 0;

                          for (final messageEntry
                          in messages.entries) {

                            final message = Map<dynamic, dynamic>.from(
                              messageEntry.value,
                            );

                            final timestamp = int.tryParse(
                                  message["timestamp"]
                                      ?.toString() ??
                                      "0",
                                ) ??
                                    0;

                            if (timestamp > latestTimestamp) {
                              latestTimestamp = timestamp;
                            }

                            final isCustomer = message["senderType"] == "customer";

                            final isRead = message["isRead"] == true;

                            if (isCustomer && !isRead) {
                              unreadCount++;
                            }
                          }

                          chatInfo[customerId] = {
                            "latestTimestamp":
                            latestTimestamp,
                            "unreadCount":
                            unreadCount,
                          };
                        }
                      }
                    }

                    final filteredCustomers = customers.where((entry) {

                      final user = Map<dynamic, dynamic>.from(
                        entry.value,
                      );

                      final name = user["name"]
                              ?.toString()
                              .toLowerCase() ??
                              "";

                      final email = user["email"]
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


                    filteredCustomers.sort((a, b) {

                      final aId = a.key.toString();
                      final bId = b.key.toString();

                      final aTime =
                          chatInfo[aId]?["latestTimestamp"] ?? 0;

                      final bTime =
                          chatInfo[bId]?["latestTimestamp"] ?? 0;

                      return (bTime as int).compareTo(
                        aTime as int,
                      );
                    });

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

                        final unreadCount =
                            chatInfo[uid]?["unreadCount"] ?? 0;

                        final hasNewMessage = unreadCount > 0;

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

                            backgroundImage:
                            user["profile_picture"] != null &&
                                user["profile_picture"]
                                    .toString()
                                    .isNotEmpty
                                ? NetworkImage(
                              user["profile_picture"].toString(),
                            )
                                : null,

                            child: user["profile_picture"] == null ||
                                user["profile_picture"]
                                    .toString()
                                    .isEmpty
                                ? Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : "?",

                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            )
                                : null,
                          ),
                          title: Row(
                            children: [

                              Expanded(
                                child: Text(
                                  name,

                                  style: TextStyle(
                                    fontWeight:
                                    hasNewMessage
                                        ? FontWeight.bold
                                        : FontWeight.normal,

                                    fontSize: 16,
                                  ),
                                ),
                              ),

                              if (hasNewMessage)
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),

                                  decoration:
                                  BoxDecoration(
                                    color:
                                    const Color(0xFFC67C4E),

                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),

                                  child: Text(
                                    unreadCount > 99
                                        ? "99+"
                                        : unreadCount.toString(),

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight:
                                      FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          subtitle: Text(
                            email,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                          ),

                          trailing: Icon(
                            hasNewMessage
                                ? Icons.mark_chat_unread_outlined
                                : Icons.chat_outlined,

                            color:
                            const Color(0xFFC67C4E),
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
                );
              },
            ),
          ),        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: const AdminNavBar(
          selectedIndex: 0,
        ),
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
