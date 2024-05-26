import 'package:flutter/material.dart';

class Viewer extends ChangeNotifier{
  String firstName;
  String lastName;
  String email;
  String deviceToken;
  String docID;
  String role;
  String? churchDocID;
  List<dynamic> subscriptions;

  Viewer({required this.firstName, required this.lastName, required this.email, required this.deviceToken, required this.docID, required this.role, required this.churchDocID, required this.subscriptions});

  factory Viewer.fromMap(Map<dynamic,dynamic> data) {
    return Viewer(firstName: data["firstName"], lastName: data["lastName"], email: data["email"], deviceToken: data["deviceToken"], docID: data["userDocID"], role: data["role"], churchDocID: data["churchDocID"], subscriptions: data["subscriptions"]);
  }

  factory Viewer.empty() {
    return Viewer(firstName: "", lastName: "", email: "", deviceToken: "", docID: "", role: "", churchDocID: "", subscriptions: []);
  }

  void changeRole() {
    role = "admin";
    notifyListeners();
  }

  void updateViewer(String firstName, String lastName, String email, String deviceToken, String userDocID, String role, String churchDocID, List<dynamic> subscriptions) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
    this.deviceToken = deviceToken;
    docID = userDocID;
    this.role = role;
    this.churchDocID = churchDocID;
    this.subscriptions = subscriptions;
  }

}