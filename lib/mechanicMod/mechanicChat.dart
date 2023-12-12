import 'package:autokaar/mechanicMod/detialchatMechanic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MechanicChatScreen extends StatefulWidget {
  final List<String> garageIds;

  MechanicChatScreen({required this.garageIds});

  @override
  _MechanicChatScreenState createState() => _MechanicChatScreenState();
}

class _MechanicChatScreenState extends State<MechanicChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: ListView.builder(
        itemCount: widget.garageIds.length,
        itemBuilder: (context, index) {
          String garageId = widget.garageIds[index];
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('messages')
                .where('mechanicID', isEqualTo: garageId)
                .orderBy('timestamp', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final messages = snapshot.data!.docs;
                if (messages.isNotEmpty) {
                  final message = messages[0];
                  String senderID = message['senderID'] ?? '';
                  String chatMessage = message['message'] ?? '';
                  String chatID = message['chatID'] ?? '';

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(senderID)
                        .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        // User data is still loading
                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: CircularProgressIndicator(),
                            subtitle: Text(chatMessage),
                          ),
                        );
                      }
                      if (userSnapshot.hasData) {
                        final userData = userSnapshot.data!;
                        String userName = userData?['name'] ?? '';

                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              userName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              chatMessage,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatScreenMechanic(
                                    garageIDVar: garageId,
                                    chatId: chatID,
                                  ),
                                ),
                              );
                              // Handle onTap action for individual chat
                            },
                          ),
                        );
                      } else {
                        // User data not found
                        return Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              'Unknown User',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                            subtitle: Text(
                              chatMessage,
                              style: TextStyle(
                                fontSize: 16.0,
                                color: Colors.white,
                              ),
                            ),
                            onTap: () {},
                          ),
                        );
                      }
                    },
                  );
                }
              }

              return Container();
            },
          );
        },
      ),
    );
  }
}
