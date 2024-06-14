import 'package:church_stream/appEntry.dart';
import 'package:church_stream/firebase_options.dart';
import 'package:church_stream/services/notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {

    Map<String,String> payload = {};

    if (message.notification != null) {

      if (message.data["notificationType"] == "Event") {
          payload["churchDocID"] = message.data["churchDocID"];
      } else {
        payload["notificationType"] = message.data["notificationType"];
        payload["liveID"] = message.data["liveID"];
      }

      NotificationService.displayNotification(message, payload);
    }

    payload.clear();
}

void listenMessageInForeground() {  

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      Map<String,String> payload = {};
      
      if (message.notification != null) {

        if (message.data["notificationType"] == "Event") {
          payload["churchDocID"] = message.data["churchDocID"];
        } else {
          payload["notificationType"] = message.data["notificationType"];
          payload["liveID"] = message.data["liveID"];
        }
        NotificationService.displayNotification(message, payload);
      }

      payload.clear();
    });

  }


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await Hive.initFlutter();
  await FirebaseMessaging.instance.requestPermission();

  await NotificationService.getPerimission();

  NotificationService.initializeLocalNotification();

  FirebaseMessaging.instance.getInitialMessage();
  
  listenMessageInForeground();
  FirebaseMessaging.onBackgroundMessage((message) => _firebaseMessagingBackgroundHandler(message));


  await Hive.openBox("cache_auth");

  runApp(const AppEntry());
}


