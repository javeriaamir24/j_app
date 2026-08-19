import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminChat extends StatefulWidget {

  final String customerId;
  final String customerName;

  const AdminChat({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<AdminChat> createState() => _AdminChatState();
}

class _AdminChatState extends State<AdminChat> {
  final TextEditingController messageController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Set<String> expandedMessages = {};
  final ScrollController _scrollController = ScrollController();
  int previousMessageCount = 0;

  DatabaseReference get messagesRef {
    return FirebaseDatabase.instance.ref("chats/${widget.customerId}/messages");
  }

  @override
  void dispose() {
    messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  void markMessagesAsRead(List<MapEntry> messages) {

    for (final entry in messages) {

      final message = Map<dynamic, dynamic>.from(entry.value);

      final isFromCustomer = message["senderType"] == "customer";

      final alreadyRead = message["isRead"] == true;

      if (isFromCustomer && !alreadyRead) {
        messagesRef.child(entry.key.toString()).update({
          "isRead": true,
        });
      }
    }
  }
  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
      }
    });
  }
  Future<void> sendMessage() async {

    final message = messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    final admin = auth.currentUser;

    if (admin == null) {
      return;
    }

    final messageRef = messagesRef.push();

    await messageRef.set({
      "senderId": admin.uid,
      "senderType": "admin",
      "message": message,
      "timestamp": ServerValue.timestamp,
      "isRead": false,
    });

    messageController.clear();
  }
  String formatTime(dynamic timestamp) {

    if (timestamp == null) {
      return "";
    }

    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp.toString()),
    );

    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour == 0 ? 12 : dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? "PM" : "AM";
    return "$hour:$minute $period";
  }
  String formatDate(dynamic timestamp) {

    if (timestamp == null) {
      return "";
    }

    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      int.parse(timestamp.toString()),
    );

    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate =
    DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return "Today";
    }

    if (messageDate == yesterday) {
      return "Yesterday";
    }

    const weekdays = [
      "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday",
    ];

    const months = [
      "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December",
    ];

    final weekday = weekdays[dateTime.weekday - 1];
    final month = months[dateTime.month - 1];

    return "$weekday, ${dateTime.day} $month ${dateTime.year}";
  }
  bool isNewDay(List<MapEntry> messages, int index) {

    if (index == 0) {
      return true;
    }

    final currentMessage = Map<dynamic, dynamic>.from(messages[index].value);

    final previousMessage = Map<dynamic, dynamic>.from(messages[index - 1].value);

    final currentTime = int.parse(
      (currentMessage["timestamp"] ?? 0).toString(),
    );

    final previousTime = int.parse(
      (previousMessage["timestamp"] ?? 0).toString(),
    );

    final currentDate = DateTime.fromMillisecondsSinceEpoch(currentTime);

    final previousDate = DateTime.fromMillisecondsSinceEpoch(previousTime);



    return currentDate.year != previousDate.year || currentDate.month != previousDate.month || currentDate.day != previousDate.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        centerTitle: true,
        title: Text(
          widget.customerName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<DatabaseEvent>(
              stream: messagesRef.onValue,

              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Something went wrong",
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {

                  return const Center(
                    child: Text("Start a conversation", style: TextStyle(color: Colors.grey,),
                    ),
                  );
                }

                final rawData = snapshot.data!.snapshot.value;

                if (rawData is! Map) {
                  return const Center(
                    child: Text("Start a conversation",),
                  );
                }

                final data = Map<dynamic, dynamic>.from(rawData);

                final messages = data.entries.toList();

                messages.sort((a, b) {

                  final timeA = a.value["timestamp"] ?? 0;

                  final timeB = b.value["timestamp"] ?? 0;

                  return int.parse(
                    timeA.toString(),
                  )
                      .compareTo(
                    int.parse(
                      timeB.toString(),
                    ),
                  );
                });

                if (messages.length != previousMessageCount) {
                  previousMessageCount = messages.length;

                  scrollToBottom();
                }

                markMessagesAsRead(messages);


                return ListView.builder(
                  controller: _scrollController,
                  padding:
                  const EdgeInsets.all(10),

                  itemCount: messages.length,

                  itemBuilder: (context, index) {

                    final entry = messages[index];

                    final message = Map<dynamic, dynamic>.from(
                      entry.value,
                    );

                    final admin = auth.currentUser;

                    final isMe = message["senderId"] == admin?.uid;

                    final messageKey = entry.key.toString();

                    final isExpanded = expandedMessages.contains(messageKey);

                    final showDateHeader = isNewDay(messages, index);
                    final isRead = message["isRead"] == true;


                    return Column(
                      children: [

                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Text(
                                  formatDate(message["timestamp"]),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,

                          child: Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,

                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isExpanded) {
                                    expandedMessages.remove(messageKey);
                                  } else {
                                    expandedMessages.add(messageKey);
                                  }
                                });
                              },

                              child: Column(
                                crossAxisAlignment: isMe
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,

                                children: [

                                  // MESSAGE BUBBLE
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                      MediaQuery.of(context).size.width * 0.75,
                                    ),

                                    margin: const EdgeInsets.symmetric(
                                      vertical: 5,
                                    ),

                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),

                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? const Color(0xFFC67C4E)
                                          : Colors.grey.shade300,

                                      borderRadius: BorderRadius.circular(15),
                                    ),

                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,

                                      crossAxisAlignment: CrossAxisAlignment.end,

                                      children: [

                                        Text(
                                          message["message"]?.toString() ?? "",

                                          style: TextStyle(
                                            color: isMe
                                                ? Colors.white
                                                : Colors.black,

                                            fontSize: 15,
                                          ),
                                        ),

                                        // TIME
                                        if (isExpanded) ...[
                                          const SizedBox(height: 4),

                                          Text(
                                            formatTime(
                                              message["timestamp"],
                                            ),

                                            style: TextStyle(
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.black54,

                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  if (isMe) ...[
                                    const SizedBox(height: 1),

                                    Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        Icon(
                                          isRead
                                              ? Icons.done_all
                                              : Icons.done,

                                          size: 14,

                                          color: isRead
                                              ? Color(0xFFC67C4E)
                                              : Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },

            ),
          ),



          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: TextField(
                      controller: messageController,

                      cursorColor:
                      const Color(0xFFC67C4E),

                      decoration: InputDecoration(
                        hintText: "Type a message...",

                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(20),

                          borderSide: const BorderSide(
                            color: Color(0xFFC67C4E),
                          ),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(20),

                          borderSide: const BorderSide(
                            color: Color(0xFFC67C4E),
                            width: 2,
                          ),
                        ),

                        contentPadding:
                        const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                      ),

                      onSubmitted: (_) {
                        sendMessage();
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFC67C4E),
                      shape: BoxShape.circle,
                    ),

                    child: IconButton(
                      onPressed: sendMessage,

                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}