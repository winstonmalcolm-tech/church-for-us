import 'package:church_stream/models/church.dart';
import 'package:church_stream/models/viewer.dart';
import 'package:church_stream/routes/homepage.dart';
import 'package:church_stream/routes/liveStream.dart';
import 'package:church_stream/routes/videoCallPage.dart';
import 'package:church_stream/services/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ChurchDashboard extends StatefulWidget {
  const ChurchDashboard({super.key});

  @override
  State<ChurchDashboard> createState() => _ChurchDashboardState();
}

class _ChurchDashboardState extends State<ChurchDashboard> {

  final uuid = const Uuid();
  Church? church;

  TextEditingController streamTitle = TextEditingController();
  final _streamKey = GlobalKey<FormState>();

  Future<Church> getChurchData() async {
    DocumentSnapshot snapshot =  await FirebaseFirestore.instance.collection("churches").doc(Provider.of<Viewer>(context, listen: false).churchDocID).get();

    return Church(churchName: snapshot["churchName"], country: snapshot["country"], createdBy: Provider.of<Viewer>(context, listen: false).firstName, churchDocID: snapshot["docID"], subscribers: snapshot["subscribers"]);

  }


  Future<void> _createLivestream(String title, BuildContext context) async {

      if (title.isEmpty) {
        return;
      }

      final meetingID = uuid.v1();

      meetingID.replaceAll("-", "_");

      DocumentReference ref = await FirebaseFirestore.instance.collection("videos").add({
        "churchDocID": church!.churchDocID,
        "isLive": true,
        "link": meetingID,
        "title": title,
        "isConference": false,
        "churchName": church!.churchName
      });

      await FirebaseFirestore.instance.collection("videos").doc(ref.id).set({"videoDocID": ref.id}, SetOptions(merge: true));

      if (church!.subscribers.isNotEmpty) {
        NotificationService.sendNotification(church!.subscribers, church!.churchName, "(New stream) $title");
      }

      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiveStream(liveID: meetingID, isHost: true, videoDocID: ref.id, title: title,)));
  }

  Future<void> _createVideoCall(String title) async {
    final meetingID = uuid.v1();
    meetingID.replaceAll("-", "_");

    DocumentReference ref = await FirebaseFirestore.instance.collection("videos").add({
      "churchDocID": Provider.of<Church>(context, listen: false).churchDocID,
      "isLive": true,
      "link": meetingID,
      "title": title,
      "isConference": true,
      "churchName": church!.churchName,
    });

    await FirebaseFirestore.instance.collection("videos").doc(ref.id).set({"videoDocID": ref.id}, SetOptions(merge: true));

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoCallPage(callID: meetingID, isHost: true,)));
  }


  void showStartStream() {
    showDialog(
      context: context, 
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: const Text("Video title"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text("Cancel", style: TextStyle(color: Colors.red),)
            ),

            TextButton(
              onPressed: () async {

                await _createLivestream(streamTitle.text, context);
              }, 
              child: const Text("Begin", style: TextStyle(color: Color.fromARGB(255, 143, 131, 25)),)
            )
          ],
          content: Form(
            key: _streamKey,
            child: TextFormField(
              controller: streamTitle,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter title";
                }
          
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter title for video"
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {

    getChurchData().then((value) {
      setState(() {
        church = value;
      });
    });

    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: NestedScrollView(   
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const Home()), (_)=>false);
                  },
                ),
                expandedHeight: 150,
                toolbarHeight: 100,
                pinned: true,
                centerTitle: true,
                backgroundColor: Colors.amber,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    height: 200,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.amber, Color.fromARGB(255, 168, 57, 23)])
                    ),
                  ),
                  title: (church == null) ? const Text("...") : Text(church!.churchName),
                ),
              )
            ];
          }, 
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    onPressed: () {
                      showStartStream();
                    }, 
                    icon: const Icon(Icons.live_tv_sharp, size: 40,)
                  ),
      
                  IconButton(
                    onPressed:  () async {
                      //await _createVideoCall();
                    } , 
                    icon: const Icon(Icons.video_call, size: 40,))
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}