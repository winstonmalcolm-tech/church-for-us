import "dart:math";

import "package:church_stream/models/video.dart";
import "package:church_stream/models/viewer.dart";
import "package:church_stream/routes/liveStream.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:lottie/lottie.dart";
import "package:provider/provider.dart";

class AllChurches extends StatefulWidget {

  const AllChurches({super.key});

  @override
  State<AllChurches> createState() => _AllChurchesState();
}

class _AllChurchesState extends State<AllChurches> {

  final _box = Hive.box("cache_auth");
  late Viewer _viewer;

  @override
  void initState() {
     _viewer = Viewer.fromMap(_box.get("cache"));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("videos").snapshots(),
          builder: (context, snapshot) {

              if (snapshot.data == null || snapshot.data!.size < 1) {
                return Center(
                    child: Lottie.asset("assets/no_video.json", height: 250)
                );
              }

              List<dynamic> videos = snapshot.data!.docs.toList().where((video) => video["isConference"] == false).toList();

              if(videos.isEmpty) {
                return Center(
                    child: Lottie.asset("assets/no_video.json", height: 250)
                );
              }

              return ListView.separated(
                itemCount: videos.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10,),
                itemBuilder: (context, index) {

                  Video video = Video(churchDocID: videos[index]["churchDocID"], videoDocID: videos[index]["videoDocID"], isLive: videos[index]["isLive"], link: videos[index]["link"], title: videos[index]["title"], isConference: videos[index]["isConference"], churchName: videos[index]["churchName"]);

                  return churchCard(video);
                  
                },
              );
          },
        ),
      ),
    );
  }

  InkWell churchCard(Video video) {
    return InkWell(
      onTap: () async {
        if (video.isLive) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiveStream(liveID: video.link, isHost: false, videoDocID: video.videoDocID)));
        } else {
          //Navigate to recording page
          _showAlertDialog(context);
        }
        
      },
      child: Container(
        height: 300,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Column(
          children: [
            Stack(
              children: [ 
                Container(
                  height: 200,
                  decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(20),
                          topLeft: Radius.circular(20))),
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(20),
                        topLeft: Radius.circular(20)),
                    child: Image.asset(
                      "assets/praise.jpg",
                      fit: BoxFit.cover,
                    ),
                  )
                ),

                if (video.isLive)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.play_arrow, color: Colors.amber,),
                        Text("Live", style: TextStyle(color: Colors.amber),)
                      ],
                    ),
                  )

              ]
            ),
            ListTile(
              tileColor: Colors.white,
              title: Text(video.title),
              subtitle: Text(video.churchName),
              trailing:(Provider.of<Viewer>(context).churchDocID == video.churchDocID) ? const Icon(Icons.star, color: Colors.amber,) : OutlinedButton(
                onPressed: () async {

                  if (Provider.of<Viewer>(context, listen: false).subscriptions.contains(video.churchDocID)) {
                    
                    //Update the user subscriptions list
                    Provider.of<Viewer>(context, listen: false).subscriptions.remove(video.churchDocID);
                    await FirebaseFirestore.instance.collection("users").doc(Provider.of<Viewer>(context, listen: false).docID).update({"subscriptions": Provider.of<Viewer>(context, listen: false).subscriptions});
                    

                    //Update church's subscribers list
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("churches").doc(video.churchDocID).get();
                    
                    List<dynamic> subscribers = snapshot["subscribers"];

                    subscribers.remove(Provider.of<Viewer>(context, listen: false).deviceToken);

                    await FirebaseFirestore.instance.collection("churches").doc(video.churchDocID).update({"subscribers": subscribers});

                    //Update local storage
                      Map<String, dynamic> updatedUser = {
                        "firstName": _viewer.firstName,
                        "lastName": _viewer.lastName,
                        "email": _viewer.email,
                        "deviceToken": _viewer.deviceToken,
                        "userDocID": _viewer.docID,
                        "role": _viewer.role,
                        "churchDocID": _viewer.churchDocID,
                        "subscriptions": Provider.of<Viewer>(context, listen: false).subscriptions
                      };

                      await _box.put("cache", updatedUser);
                      Provider.of<Viewer>(context, listen: false).updateViewer(_viewer.firstName, _viewer.lastName, _viewer.email, _viewer.deviceToken, _viewer.docID, _viewer.role, _viewer.churchDocID!, Provider.of<Viewer>(context, listen: false).subscriptions);


                  } else {
                    
                    //Update the user subscriptions list
                    Provider.of<Viewer>(context, listen: false).subscriptions.add(video.churchDocID);
                    await FirebaseFirestore.instance.collection("users").doc(Provider.of<Viewer>(context, listen: false).docID).update({"subscriptions": Provider.of<Viewer>(context, listen: false).subscriptions});

                    //Update church's subscribers list
                    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("churches").doc(video.churchDocID).get();
                    List<dynamic> subscribers = snapshot["subscribers"];

                    subscribers.add(Provider.of<Viewer>(context, listen: false).deviceToken);
                    await FirebaseFirestore.instance.collection("churches").doc(video.churchDocID).update({"subscribers": subscribers});

                    //Update local storage
                    Map<String, dynamic> updatedUser = {
                      "firstName": _viewer.firstName,
                      "lastName": _viewer.lastName,
                      "email": _viewer.email,
                      "deviceToken": _viewer.deviceToken,
                      "userDocID": _viewer.docID,
                      "role": _viewer.role,
                      "churchDocID": _viewer.churchDocID,
                      "subscriptions": Provider.of<Viewer>(context, listen: false).subscriptions
                    };

                    await _box.put("cache", updatedUser);
                    Provider.of<Viewer>(context, listen: false).updateViewer(_viewer.firstName, _viewer.lastName, _viewer.email, _viewer.deviceToken, _viewer.docID, _viewer.role, _viewer.churchDocID!, Provider.of<Viewer>(context, listen: false).subscriptions);  

                  }
         
                  setState(() {}); 
                },
                child: (Provider.of<Viewer>(context).subscriptions.contains(video.churchDocID)) ? 
                 const Text(
                        "Subscribed",
                        style: TextStyle(color: Colors.amber),
                      )
                  : 
                  const Text(
                    "Subscribe",
                    style: TextStyle(color: Colors.amber),
                  ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stream ended'),
          content: const Text('Recording is unavailable'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
