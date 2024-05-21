import 'package:chatfirebase/pages/chatApp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GeneralPage extends StatefulWidget {
  @override
  _GeneralPageState createState() => _GeneralPageState();
}

class _GeneralPageState extends State<GeneralPage> {
  String searchQuery = "";
  String currentUserId = "";

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users found'));
                }

                final users = snapshot.data!.docs.where((user) {
                  final name = user['name'].toLowerCase();
                  final surname = user['surname'].toLowerCase();
                  return name.contains(searchQuery) || surname.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final email = user['email'];
                    final name = user['name'];
                    final surname = user['surname'];
                    final lastSeen = user['lastSeen'];
                    final isActive = user['isActive']; // 'isActive' field to indicate user status

                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(Icons.person, color: Colors.grey.shade800),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isActive ? Colors.green : Colors.red,
                              ),
                            ),
                          )
                        ],
                      ),
                      title: Text('$name $surname'),
                      subtitle: Text('Email: $email\nLast Seen: $lastSeen'),
                      isThreeLine: true,
                      onTap: () {
                        // Implement navigation to chat screen with the user
                        Get.to(
                              () => ChatPage(user: user, currentUserId: currentUserId),
                          transition: Transition.rightToLeft,
                          duration: Duration(milliseconds: 100),
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
}

class ChatPage extends StatelessWidget {
  final DocumentSnapshot user;
  final String currentUserId;

  ChatPage({required this.user, required this.currentUserId});

  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatId = getChatId(currentUserId, user.id);

    return Scaffold(
      appBar: AppBar(
        title: Text('${user['name']} ${user['surname']}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .where('chatId', isEqualTo: chatId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No messages found'));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == currentUserId;

                    return ListTile(
                      title: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['message'],
                                style: TextStyle(color: isMe ? Colors.white : Colors.black),
                              ),
                              SizedBox(height: 5),
                              Text(
                                (message['timestamp'] as Timestamp).toDate().toString(),
                                style: TextStyle(color: isMe ? Colors.white70 : Colors.black87, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter your message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(chatId);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode ? '${userId1}_$userId2' : '${userId2}_$userId1';
  }

  void sendMessage(String chatId) {
    if (_messageController.text.isNotEmpty) {
      FirebaseFirestore.instance.collection('chats').add({
        'chatId': chatId,
        'senderId': currentUserId,
        'receiverId': user.id,
        'message': _messageController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'type': 'text',
      });

      _messageController.clear();
    }
  }
}
