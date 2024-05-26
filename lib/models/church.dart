import 'package:flutter/material.dart';

class Church extends ChangeNotifier{
  String churchName;
  String country;
  String createdBy;
  String churchDocID;
  List<dynamic> subscribers;

  Church({required this.churchName, required this.country, required this.createdBy, required this.churchDocID, required this.subscribers});

  factory Church.fromMap(Map<String, dynamic> data) {

    return Church(churchName: data["churchName"], country: data["country"], createdBy: data["createdBy"], churchDocID: data["churchDocID"], subscribers: data["subscribers"]);
  }
}