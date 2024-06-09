import 'package:flutter/material.dart';

class Church extends ChangeNotifier{
  String churchName;
  String country;
  String createdBy;
  String churchDocID;
  List<dynamic> subscribers;
  List<dynamic> events;

  Church({required this.churchName, required this.country, required this.createdBy, required this.churchDocID, required this.subscribers, required this.events});

  factory Church.fromMap(Map<String, dynamic> data) {

    return Church(churchName: data["churchName"], country: data["country"], createdBy: data["createdBy"], churchDocID: data["docID"], subscribers: data["subscribers"], events: data["events"]);
  }
}