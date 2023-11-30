import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:uuid/uuid.dart';
import 'messageHandle.dart';

class ChatScreen extends StatefulWidget {
  final String garageId;

  ChatScreen({required this.garageId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> messages = [];
  List<String> messagessent = [];
  TextEditingController messageController = TextEditingController();
  String garageNameMain = "User";
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
   fetchGarageName(widget.garageId);
    fetchMessages(widget.garageId);
    initNotifications();
  }

  static Future<void> initNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(garageNameMain),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              garageNameMain,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final timestamp =
                    message['timestamp']?.toDate().toString() ?? '';
                final typeOfMessage = message['type'] ?? '';
                print(typeOfMessage);
                print(typeOfMessage);
                print("XXXXXXXXXXXXXXXXXXXXXXXXXX");
                if (typeOfMessage == 'user') {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
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
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.0),
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
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
                    sendMessage(
                        widget.garageId, messageController.text.toString());
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
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('mechanicGarage')
        .doc(garageId)
        .get();
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
    String currentUserID = FirebaseAuth.instance.currentUser!.uid;

    FirebaseFirestore.instance
        .collection('messages')
        .where('mechanicID', isEqualTo: mechanicID)
        .where('senderID', isEqualTo: currentUserID)
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
      String chatID = const Uuid().v1();
      String senderID = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('messages').doc(chatID).set({
        'mechanicID': mechanicID,
        'senderID': senderID,
        'message': message,
        'timestamp': DateTime.now(),
        'chatID': chatID,
        'type': 'user',
      }).then((docRef) {
        print('Message sent ');
        setState(() {
          messagessent.add(message);
        });
        messageController.clear();
        fetchMessages(mechanicID);

        // Call the function to show a notification at the receiver's end
        String receiverName =
            "Receiver's Name"; // Replace with the receiver's name
        Map<String, dynamic> messageData = {
          'receiverId': mechanicID,
          'receiverName': receiverName,
          'message': message,
        };
        onMessageReceived(messageData);
      }).catchError((error) {
        print('Error sending message: $error');
      });
    }
  }

  static Future<void> showNotification(
      String title, String message, String channelId) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId, // Replace with your unique channel ID
      'Channel Name', // Replace with your channel name
      channelDescription: 'Channel Description',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformChannelSpecifics,
    );
  }

  static void onMessageReceived(Map<String, dynamic> messageData) {
    String receiverName = messageData[
        'receiverName']; // Replace with the key for the receiver's name
    String messageText =
        messageData['message']; // Replace with the key for the message text

    String title = 'New Message from $receiverName';
    showNotification(title, messageText, 'your_channel_id');
  }
}
