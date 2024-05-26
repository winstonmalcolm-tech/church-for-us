import "package:church_stream/models/church.dart";
import "package:church_stream/models/video.dart";
import "package:church_stream/models/viewer.dart";
import "package:church_stream/routes/liveStream.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:provider/provider.dart";

class SingleChurch extends StatefulWidget {
  final Church church;
  const SingleChurch({super.key, required this.church});

  @override
  State<SingleChurch> createState() => _SingleChurchState();
}

class _SingleChurchState extends State<SingleChurch> {

  Future<List<Video>>? _specificVideos;

  final _box = Hive.box("cache_auth");
  late Viewer _viewer;

  Future<List<Video>> getChurchVideos() async {

    List<Video> videos = [];

    QuerySnapshot<Map<String,dynamic>> snapshot = await FirebaseFirestore.instance.collection("videos").get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;

    for (QueryDocumentSnapshot doc in docs) {

      if (doc["churchDocID"] == widget.church.churchDocID) {
        videos.add(Video(churchDocID: doc["churchDocID"], videoDocID: doc["videoDocID"], isLive: doc["isLive"], link: doc["link"], title: doc["title"], isConference: doc["isConference"], churchName: doc["churchName"]));
      }

    }

    return videos; 
  }


  @override
  void initState() {
    _specificVideos = getChurchVideos();
    _viewer = Viewer.fromMap(_box.get("cache"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
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
                  title: Text(widget.church.churchName),
                ),
              )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Subscribers: ${widget.church.subscribers.length}", style: const TextStyle(fontSize: 18),),

                  OutlinedButton(
                    onPressed: () async {

                      if (Provider.of<Viewer>(context, listen: false).subscriptions.contains(widget.church.churchDocID)) {
                        
                        //Update the user subscriptions list
                        Provider.of<Viewer>(context, listen: false).subscriptions.remove(widget.church.churchDocID);
                        await FirebaseFirestore.instance.collection("users").doc(Provider.of<Viewer>(context, listen: false).docID).update({"subscriptions": Provider.of<Viewer>(context, listen: false).subscriptions});

                        //Update church's subscribers list
                        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("churches").doc(widget.church.churchDocID).get();
                        
                        List<dynamic> subscribers = snapshot["subscribers"];
                        subscribers.remove(Provider.of<Viewer>(context, listen: false).deviceToken);
                        await FirebaseFirestore.instance.collection("churches").doc(widget.church.churchDocID).update({"subscribers": subscribers});


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
                        Provider.of<Viewer>(context, listen: false).subscriptions.add(widget.church.churchDocID);
                        await FirebaseFirestore.instance.collection("users").doc(Provider.of<Viewer>(context, listen: false).docID).update({"subscriptions": Provider.of<Viewer>(context, listen: false).subscriptions});

                        //Update church's subscribers list
                        DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("churches").doc(widget.church.churchDocID).get();
                        List<dynamic> subscribers = snapshot["subscribers"];

                        subscribers.add(Provider.of<Viewer>(context, listen: false).deviceToken);
                        await FirebaseFirestore.instance.collection("churches").doc(widget.church.churchDocID).update({"subscribers": subscribers});

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
                    
                    child: (Provider.of<Viewer>(context).subscriptions.contains(widget.church.churchDocID)) ? 
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
                ],
              ),

              Expanded(
                child: FutureBuilder(
                  future: _specificVideos, 
                  builder: (context, snapshot) {
                    
                    if (snapshot.connectionState == ConnectionState.done) {

                      if (snapshot.data == null || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No videos", style: TextStyle(fontSize: 20),),
                        );
                      }

                      return ListView.separated(
                        itemCount: snapshot.data!.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10,),
                        itemBuilder: (context, index) {
                          Video video = snapshot.data![index];

                          return churchCard(video);
                        },
                      );

                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                
                )
                
              )
              
            ],
          ),
        )
      )
    );
  }


  InkWell churchCard(Video video) {
    return InkWell(
      onTap: () async {
        if (video.isLive) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiveStream(liveID: video.link, isHost: false, videoDocID: null, title: null,)));
        } else {
          //Navigate to recording page
        }
        
      },
      child: Container(
        height: 300,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black45),
            borderRadius: const BorderRadius.all(Radius.circular(20))),
        child: Column(
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
                    ))),
            ListTile(
              tileColor: Colors.white,
              title: Text(video.title),
            )
          ],
        ),
      ),
    );
  }
}