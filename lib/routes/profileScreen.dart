import "package:church_stream/models/viewer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:provider/provider.dart";
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool saveAiChat = false;
  

  Future<void> loadAISettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool? status = prefs.getBool("status");

    setState(() {
      saveAiChat = (status == null || status == false) ? false : true;
    });
  }

  Future<void> updateAiSettings(bool status) async {

    setState(() {
      saveAiChat = status;
    });
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("status", status);

    if (status == false) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("chats").doc(Provider.of<Viewer>(context, listen: false).docID).get();
      if (snapshot.exists) {
        await FirebaseFirestore.instance.collection("chats").doc(Provider.of<Viewer>(context, listen: false).docID).delete();
      }
    } 
  }

  @override
  void initState() {
    loadAISettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                maxRadius: 50,
                child: Text("${Provider.of<Viewer>(context).firstName.substring(0,1)}${Provider.of<Viewer>(context).lastName.substring(0,1)}", style: const TextStyle(fontSize: 30, color: Colors.black54),),
              ),
            ),

            const SizedBox(height: 40,),
            Text("Name: ", style: GoogleFonts.poppins(),),
            Text("${Provider.of<Viewer>(context).firstName} ${Provider.of<Viewer>(context).lastName}"),
            const SizedBox(height: 20,),
            Text("Email:", style: GoogleFonts.poppins(),),
            Text(Provider.of<Viewer>(context).email),
            const SizedBox(height: 20,),
            Text("Number of subscriptions:", style: GoogleFonts.poppins(),),
            Text("${Provider.of<Viewer>(context).subscriptions.length}"),

            const SizedBox(height: 20,),
            const Text("Save chat with Deacon (AI):"),
            Switch(
              value: saveAiChat, 
              onChanged: updateAiSettings
            )
          ],
        ),
      ),
    );
  }
}