import 'package:autokaar/mechanicMod/detialchatMechanic.dart';
import 'package:autokaar/userMod/userChatScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserChatScreen extends StatefulWidget {
  final String userId;

  UserChatScreen({required this.userId});

  @override
  _UserChatScreenState createState() => _UserChatScreenState();
}

class _UserChatScreenState extends State<UserChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('senderID', isEqualTo: widget.userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final messages = snapshot.data!.docs;

            // Collect unique mechanics from the chat messages
            Set<String> uniqueMechanics = Set<String>();

            for (final message in messages) {
              String mechanicID = message['mechanicID'] ?? '';
              uniqueMechanics.add(mechanicID);
            }

            return ListView.builder(
              itemCount: uniqueMechanics.length,
              itemBuilder: (context, index) {
                String mechanicID = uniqueMechanics.elementAt(index);

                // Fetch mechanic data from Firestore
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('mechanicGarage')
                      .doc(mechanicID)
                      .get(),
                  builder: (context, garageSnapshot) {
                    if (garageSnapshot.connectionState == ConnectionState.waiting) {
                      // Garage data is still loading
                      return CircularProgressIndicator();
                    }
                    if (garageSnapshot.hasData) {
                      final garageData = garageSnapshot.data!;
                      String garageName = garageData?['garageName'] ?? '';
                      String garageID = garageData?['garagenum'] ?? '';


                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                            garageName, // Display garage name
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                              color: Colors.white,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreenUser(garageIDVar: garageID, currentUserID: widget.userId,
                                ),
                              ),
                            );

                          },
                        ),
                      );
                    } else {
                      // Garage data not found
                      return Container();
                    }
                  },
                );
              },
            );
          }

          // If there are no messages or the snapshot is still loading
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
