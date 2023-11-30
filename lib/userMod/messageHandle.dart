import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandler {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
