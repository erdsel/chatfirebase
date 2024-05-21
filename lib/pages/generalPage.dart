import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'chatRoom.dart';

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
                    final userId = user.id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.person, color: Colors.grey.shade800),
                      ),
                      title: Text('$name $surname'),
                      subtitle: Text(email),
                      onTap: () {
                        String chatRoomId = getChatRoomId(currentUserId, userId);
                        Map<String, dynamic> userMap = {
                          'name': name,
                          'uid': userId,
                        };

                        Get.to(
                              () => ChatRoom(chatRoomId: chatRoomId, userMap: userMap),
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

  String getChatRoomId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode ? '${userId1}_$userId2' : '${userId2}_$userId1';
  }
}
