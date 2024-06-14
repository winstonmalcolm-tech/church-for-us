import "package:church_stream/models/church.dart";
import "package:church_stream/models/event.dart";
import "package:church_stream/models/video.dart";
import "package:church_stream/models/viewer.dart";
import "package:church_stream/routes/liveStream.dart";
import "package:church_stream/routes/videoCallPage.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:provider/provider.dart";
import 'package:intl/intl.dart';

class SingleChurch extends StatefulWidget {
  final Church church;
  const SingleChurch({super.key, required this.church});

  @override
  State<SingleChurch> createState() => _SingleChurchState();
}

class _SingleChurchState extends State<SingleChurch> {

  List<Event> churchEvents = [];

  final _box = Hive.box("cache_auth");
  late Viewer _viewer;

  Future<String>? creator;

  @override
  void initState() {
    _viewer = Viewer.fromMap(_box.get("cache"));

    creator = getCreator();
    super.initState();
  }

  Future<String> getCreator() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("users").doc(widget.church.createdBy).get();
    
    String creator = "${snapshot["firstName"]} ${snapshot["lastName"]}";

    return creator;
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
                actions: [
                  IconButton(
                    onPressed: () {
                      _showEventBottomSheet(context);
                    }, 
                    icon: const Icon(Icons.event_note_sharp)
                  ),

                  IconButton(
                    onPressed: () {
                      _showAboutDialog(context);
                    }, 
                    icon: const Icon(Icons.more_vert_outlined)
                  )

                ],
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
              StreamBuilder(
                stream: FirebaseFirestore.instance.collection("churches").doc(widget.church.churchDocID).snapshots(),
                builder: (context, snapshot) {

                  if (!snapshot.hasData) {
                    return const Text("...");
                  }
                  return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Subscribers: ${snapshot.data!["subscribers"].length}", style: const TextStyle(fontSize: 18),),
                    
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
                    );
                },
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("videos").snapshots(),
                  builder: (context, snapshot) {

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No videos", style: TextStyle(fontSize: 20),),
                        );
                      }

                      List<dynamic> videos = snapshot.data!.docs.toList().where((video) => video["churchDocID"] == widget.church.churchDocID).toList();
                
                
                      return ListView.separated(
                        itemCount: videos.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10,),
                        itemBuilder: (context, index) {
                            Video video = Video(churchDocID: videos[index]["churchDocID"], videoDocID: videos[index]["videoDocID"], isLive: videos[index]["isLive"], link: videos[index]["link"], title: videos[index]["title"], isConference: videos[index]["isConference"], churchName: videos[index]["churchName"]);

                            return churchCard(video);
                        },
                      );
                  }
                )                
              )
              
            ],
          ),
        )
      )
    );
  }

  void _showAboutDialog(BuildContext context) {

    showDialog(
      context: context, 
      builder: (_) {
        return AlertDialog(
          title: const Text("About"),
          content: FutureBuilder(
            future: creator,
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.done) {
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Created By: ${snapshot.data}", textAlign: TextAlign.left,),
                    const SizedBox(height: 10,),
                    Text("Church Name: ${widget.church.churchName}", textAlign: TextAlign.left,),
                    const SizedBox(height: 10,),
                    Text("Country: ${widget.church.country}", textAlign: TextAlign.left,),
                    const SizedBox(height: 10,),                    
                    Text("Subscribers Count: ${widget.church.subscribers.length}", textAlign: TextAlign.left,)
                  ],
                );

              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
            
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text("OK")
            )
          
          ],
        );
      }
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


  InkWell churchCard(Video video) {
    return InkWell(
      onTap: () async {
        if (video.isLive) {
          
          if (video.isConference) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_)=> VideoCallPage(callID: video.link, isHost: false, videoDocID: null,)));
          } else {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiveStream(liveID: video.link, isHost: false, videoDocID: video.videoDocID)));
          }

        } else {
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
            )
          ],
        ),
      ),
    );
  }

  void _showEventBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, 
      
      builder: (context) {
        return Container(
          height: 400,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 5,
                      child: Center(child: Text("Events", style: TextStyle(fontSize: 25),)),
                    ),
                
                    Expanded(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          }, 
                          icon: const Icon(Icons.close, color: Colors.redAccent, size: 30,)
                        ),
                      ),
                    ),
                  ],
                ),

                Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance.collection("churches").doc(widget.church.churchDocID).snapshots(), 
                      builder: (context, snapshot) {

                        List<dynamic> events = snapshot.data?.get("events") ?? [];  

                        if (events.isEmpty) {
                          return const Center(
                            child: Text("No upcoming events"),
                          );
                        }
                        
                        return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {

                            Event event = Event(title: events[index]["title"], date: events[index]["date"], time: events[index]["time"], description: events[index]["description"]);

                            DateTime eventDate = DateFormat("E, MMM d, y").parse(event.date);
                            Duration difference =  eventDate.difference(DateTime.now());

                            return ListTile(
                              title: Text(event.title),
                              subtitle: Text("${event.date} ${event.time}"),
                              trailing: Text("In ${difference.inDays} days"),
                            );

                          }
                        );
                      },
                      
                    ),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}