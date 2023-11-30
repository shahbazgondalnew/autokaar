import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class ChatScreenUser extends StatefulWidget {
  final String garageIDVar;
  final String currentUserID; // Add the user's ID

  ChatScreenUser({required this.garageIDVar, required this.currentUserID});

  @override
  _ChatScreenUserState createState() => _ChatScreenUserState();
}

class _ChatScreenUserState extends State<ChatScreenUser> {
  List<Map<String, dynamic>> messages = [];
  List<String> messagessent = [];
  TextEditingController messageController = TextEditingController();
  String garageNameMain = "User";

  @override
  void initState() {
    super.initState();
    fetchGarageName(widget.garageIDVar);
    fetchMessages(widget.garageIDVar);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(garageNameMain),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final timestamp = message['timestamp']?.toDate().toString() ?? '';
                final typeOfMessage = message['type'] ?? '';

                if (typeOfMessage == 'mechanic') {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blueGrey,
                          ),
                          child: Text(
                            message['message'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            timestamp,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            color: Colors.blueGrey,
                          ),
                          child: Text(
                            message['message'] ?? '',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            timestamp,
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(widget.garageIDVar, messageController.text.toString());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void fetchGarageName(String garageId) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('mechanicGarage').doc(garageId).get();
    if (snapshot.exists) {
      String? garageName = snapshot?['garageName'] as String?;
      if (garageName != null) {
        setState(() {
          garageNameMain = garageName;
        });
      } else {
        print('Garage name not found.');
      }
    } else {
      print('Garage document not found.');
    }
  }

  void fetchMessages(String mechanicID) {
    FirebaseFirestore.instance
        .collection('messages')
        .where('mechanicID', isEqualTo: mechanicID)
        .where('senderID', isEqualTo: widget.currentUserID) // Filter by user's ID
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      List<Map<String, dynamic>> fetchedMessages = [];
      snapshot.docs.forEach((doc) {
        Map<String, dynamic> messageData = {
          'message': doc['message'] as String?,
          'timestamp': doc['timestamp'] as Timestamp?,
          'type': doc['type'] as String?,
        };
        fetchedMessages.add(messageData);
      });
      setState(() {
        messages = fetchedMessages;
      });
    });
  }

  void sendMessage(String mechanicID, String message) async {
    if (message.isNotEmpty) {
      String senderID = widget.currentUserID; // Use the user's ID
      await FirebaseFirestore.instance.collection('messages').add({
        'mechanicID': mechanicID,
        'senderID': senderID,
        'message': message,
        'timestamp': DateTime.now(),
        'type': 'user', // Set the type as 'user'
      }).then((docRef) {
        print('Message sent ');
        setState(() {
          messagessent.add(message);
        });
        messageController.clear();
        fetchMessages(mechanicID);
      }).catchError((error) {
        print('Error sending message: $error');
      });
    }
  }
}
