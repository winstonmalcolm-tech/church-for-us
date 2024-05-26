import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Uri sendNotificationEndpoint = Uri.parse("http://192.168.100.7:8000/send"); 

  static Future<void> sendNotification(List<dynamic> deviceTokens, String title, String message) async {

    await http.post(
      Uri.parse("http://192.168.100.7:8000/send"),
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": title,
        "message": message,
        "tokens": deviceTokens
      })
    );

  }

  static void initializeLocalNotification() {
    AwesomeNotifications().initialize(
      null, 
      [
        NotificationChannel(
          channelKey: "church_cast_123", 
          channelName: "Church Cast", 
          channelDescription: "Notification for church cast"
        )
      ],
      debug: true 
    );
  }

  static void displayNotification(RemoteMessage message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, 
        channelKey: "church_cast_123",
        title: message.notification!.title,
        body: message.notification!.body,
      ),
    );
  }
  
  static Future<void> getPerimission() async {

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true
    );  
  }

  static void listenMessageInForeground() {

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        displayNotification(message);
      }
    });

  }

}