import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

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
