import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:church_stream/appEntry.dart';
import 'package:church_stream/models/church.dart';
import 'package:church_stream/routes/detailedScreen.dart';
import 'package:church_stream/routes/liveStream.dart';
import 'package:church_stream/routes/videoCallPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;

  static Uri sendNotificationEndpoint = Uri.parse("http://192.168.1.10:8000/send"); 

  static Future<void> sendNotification(List<dynamic> deviceTokens, String title, String message, Map<String,String> data) async {

    await http.post(
      sendNotificationEndpoint,
      headers: {
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": title,
        "message": message,
        "tokens": deviceTokens,
        "data": data,
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

    AwesomeNotifications().setListeners(onActionReceivedMethod: onActionReceivedMethod);
  
  }

  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
      final payload = receivedAction.payload ?? {};

      if (payload["liveID"] != null) {
        
        if (payload["notificationType"] == "conference") {
            AppEntry.navigatorKey.currentState?.push(MaterialPageRoute(builder: (_)=>VideoCallPage(callID: payload["liveID"]!, isHost: false, videoDocID: null,)));
        } else {
            AppEntry.navigatorKey.currentState?.push(MaterialPageRoute(builder: (_)=>LiveStream(liveID: payload["liveID"]!, isHost: false, videoDocID: null)));
        }
        
                
      } else {
        final churchDocID = payload["churchDocID"];

        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("churches").doc(churchDocID!).get();

        AppEntry.navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => SingleChurch(church: Church.fromMap(snapshot.data() as Map<String,dynamic>))));

      }

      
  }

  static void displayNotification(RemoteMessage message, Map<String,String> payload) {

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10, 
        channelKey: "church_cast_123",
        title: message.notification!.title,
        body: message.notification!.body,
        payload: payload
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

}