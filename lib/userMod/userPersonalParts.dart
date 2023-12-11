import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class UserAddedPartsScreen extends StatefulWidget {
  @override
  _UserAddedPartsScreenState createState() => _UserAddedPartsScreenState();
}

class _UserAddedPartsScreenState extends State<UserAddedPartsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Added Parts'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('autopartOrder').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No user-added parts found'),
            );
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;

              return UserAddedPartCard(data: data);
            }).toList(),
          );
        },
      ),
    );
  }
}

class UserAddedPartCard extends StatefulWidget {
  final Map<String, dynamic> data;

  UserAddedPartCard({required this.data});

  @override
  State<UserAddedPartCard> createState() => _UserAddedPartCardState();
}

class _UserAddedPartCardState extends State<UserAddedPartCard> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.data['name'] ?? ''),
        subtitle: Text('Quantity: ${widget.data['quantity']}'),
        trailing: IconButton(
          icon: Icon(Icons.notifications),
          onPressed: () {
            _showDateTimePicker(context, widget.data);
          },
        ),
      ),
    );
  }

  Future<void> _showDateTimePicker(
      BuildContext context, Map<String, dynamic> autopartData) async {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    ).then((pickedDate) {
      if (pickedDate != null && pickedDate != selectedDate) {
        selectedDate = pickedDate;

        showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        ).then((pickedTime) {
          if (pickedTime != null && pickedTime != selectedTime) {
            selectedTime = pickedTime;

            // Store autopart information and reminder in Firestore
            _storeReminder(selectedDate, selectedTime, autopartData);

            // Schedule a notification for the selected date and time
            _scheduleNotification(
                selectedDate, selectedTime, autopartData['name']);
          }
        });
      }
    });
  }

  void _storeReminder(DateTime selectedDate, TimeOfDay selectedTime,
      Map<String, dynamic> autopartData) {
    FirebaseFirestore.instance.collection('serviceReminders').add({
      'autopartId':
          autopartData['id'], // Adjust this according to your data structure
      'autopartName': autopartData['name'],
      'reminderDate': selectedDate.toString(),
      'reminderTime': selectedTime.toString(),
    });
  }

  void _scheduleNotification(DateTime selectedDate, TimeOfDay selectedTime,
      String autopartName) async {
    // Convert local DateTime to tz.TZDateTime
    tz.TZDateTime scheduledDateTime = tz.TZDateTime(
      tz.getLocation('Asia/Karachi'), // Pakistan Time (PKT)
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    print('Scheduled DateTime (UTC): ${scheduledDateTime.toUtc()}');
    print('Scheduled DateTime (PKT): $scheduledDateTime');

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder: Autopart Maintenance',
      'Don\'t forget to check $autopartName!',
      scheduledDateTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'AutopartReminder',
    );
  }
}
