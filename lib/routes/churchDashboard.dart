import 'dart:async';
import 'package:church_stream/models/church.dart';
import 'package:church_stream/models/event.dart';
import 'package:church_stream/models/video.dart';
import 'package:church_stream/models/viewer.dart';
import 'package:church_stream/routes/homepage.dart';
import 'package:church_stream/routes/liveStream.dart';
import 'package:church_stream/routes/videoCallPage.dart';
import 'package:church_stream/services/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class ChurchDashboard extends StatefulWidget {
  const ChurchDashboard({super.key});

  @override
  State<ChurchDashboard> createState() => _ChurchDashboardState();
}

class _ChurchDashboardState extends State<ChurchDashboard> {

  final uuid = const Uuid();
  Future<Church>? church;

  TextEditingController streamTitle = TextEditingController();
  TextEditingController conferenceTitle = TextEditingController();
  final _streamKey = GlobalKey<FormState>();
  final _conferenceKey = GlobalKey<FormState>();


  TextEditingController titleController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  bool isNewEventLoading = false;
  List<Event> churchEvents = [];

  //videos loading decider
  bool isLiveStreamCreating = false;
  bool isConferenceCreating = false;

  @override
  void initState() {

    church = getChurchData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: church,
        builder: (context, futureSnapshot) {

          if (futureSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } 

          return NestedScrollView(   
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const Home()), (_)=>false);
                    },
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        showEventBottomSheet(context, futureSnapshot.data!);
                      }, 
                      icon: const Icon(Icons.event_note_sharp)
                    ),
              
                    IconButton(
                      onPressed: () {
                        addNewEvent(context, futureSnapshot.data!);
                      }, 
                      icon: const Icon(Icons.add)
                    ),

                    IconButton(
                      onPressed: () {
                        _showAboutDialog(context, futureSnapshot.data!);
                      }, 
                      icon: const Icon(Icons.more_vert_outlined)
                    )
                  ],
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
                    title: Text(futureSnapshot.data!.churchName),
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
                        showStartStream(futureSnapshot.data!);
                      }, 
                      icon: const Icon(Icons.live_tv_sharp, size: 40,)
                    ),
              
                    IconButton(
                      onPressed:  () {
                        showStartConference(futureSnapshot.data!);
                      } , 
                      icon: const Icon(Icons.video_call, size: 40,))
                  ],
                ),
              
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection("videos").snapshots(), 
                      builder: (context, snapshot) {
                              
                        if (snapshot.data == null || snapshot.data!.size < 1) {
                          return const Center(
                            child: Text("No Videos", style: TextStyle(fontSize: 20)),
                          );
                        }
                        
                        List<dynamic> videos = snapshot.data!.docs.reversed.toList();
          
                        return ListView.separated(
                          itemCount: videos.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10,),
                          itemBuilder: (context, index) {
          
                            Video video = Video(churchDocID: videos[index]["churchDocID"], videoDocID: videos[index]["videoDocID"], isLive: videos[index]["isLive"], link: videos[index]["link"], title: videos[index]["title"], isConference: videos[index]["isConference"], churchName: videos[index]["churchName"]);
          
                            if (video.churchDocID == futureSnapshot.data!.churchDocID) {
                              return churchCard(video);
                            }
                            return null;
                          },
                        
                        );
                        
                      },
                    ),
                  )
                
                )
              ],
            ),
          ); 
        },
        
      )
    );
  }

  void _showAboutDialog(BuildContext context, Church church) {

    showDialog(
      context: context, 
      builder: (_) {
        return AlertDialog(
          title: const Text("About"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Church Name: ${church.churchName}", textAlign: TextAlign.left,),
              const SizedBox(height: 10,),
              Text("Country: ${church.country}", textAlign: TextAlign.left,),
              const SizedBox(height: 10,),                    
              Text("Subscribers Count: ${church.subscribers.length}", textAlign: TextAlign.left,)
            ],
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


  Future<Church> getChurchData() async {
    DocumentSnapshot snapshot =  await FirebaseFirestore.instance.collection("churches").doc(Provider.of<Viewer>(context, listen: false).churchDocID).get();

    return Church(churchName: snapshot["churchName"], country: snapshot["country"], createdBy: Provider.of<Viewer>(context, listen: false).firstName, churchDocID: snapshot["docID"], subscribers: snapshot["subscribers"], events: snapshot["events"]);
  }

  Future<void> _createLivestream(String title, BuildContext context, Church church) async {

      setState(() {
        isLiveStreamCreating = true;
      });

      final meetingID = uuid.v1();

      meetingID.replaceAll("-", "_");

      DocumentReference ref = await FirebaseFirestore.instance.collection("videos").add({
        "churchDocID": church.churchDocID,
        "isLive": true,
        "link": meetingID,
        "title": title,
        "isConference": false,
        "churchName": church.churchName,
        "videoDocID": ""
      });


      await FirebaseFirestore.instance.collection("videos").doc(ref.id).update({"videoDocID": ref.id});

      if (church.subscribers.isNotEmpty) {
        NotificationService.sendNotification(church.subscribers, church.churchName, "(New stream) $title", <String,String>{"liveID": meetingID, "notificationType": "stream"});
      }

      setState((){
        isLiveStreamCreating = false;
      });

      Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiveStream(liveID: meetingID, isHost: true, videoDocID: ref.id)));
      streamTitle.text = "";
  }


  Future<void> _createVideoCall(String title, Church church) async {

    setState(() {
      isConferenceCreating = true;
    });

    final meetingID = uuid.v1();
    meetingID.replaceAll("-", "_");

    DocumentReference ref = await FirebaseFirestore.instance.collection("videos").add({
      "churchDocID": church.churchDocID,
      "isLive": true,
      "link": meetingID,
      "title": title,
      "isConference": true,
      "churchName": church.churchName,
      "videoDocID": ""
    });

    await FirebaseFirestore.instance.collection("videos").doc(ref.id).set({"videoDocID": ref.id}, SetOptions(merge: true));

    if (church.subscribers.isNotEmpty) {
      NotificationService.sendNotification(church.subscribers, church.churchName, "(New Conference) $title", <String,String>{"liveID": meetingID, "notificationType": "conference"});
    }

    setState(() {
      isConferenceCreating = false;
    });

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoCallPage(callID: meetingID, isHost: true, videoDocID: ref.id)));
    conferenceTitle.text = "";
  }


  void showStartStream(Church church) {
    showDialog(
      context: context, 
      barrierDismissible: true,
      useRootNavigator: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Stream title"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text("Cancel", style: TextStyle(color: Colors.red),)
            ),

            TextButton(
              onPressed: () async {

                if (!_streamKey.currentState!.validate()) {
                  return;
                }

                await _createLivestream(streamTitle.text, context, church);
              }, 
              child: (isLiveStreamCreating) ? const CircularProgressIndicator() : const Text("Begin", style: TextStyle(color: Color.fromARGB(255, 143, 131, 25)),)
            )
          ],
          content: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
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
                  hintText: "Enter title for stream"
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showStartConference(Church church) {

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text("Conference title"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              }, 
              child: const Text("Cancel", style: TextStyle(color: Colors.red),)
            ),

            TextButton(
              onPressed: () async {

                if (!_conferenceKey.currentState!.validate()) {
                  return;
                }

                await _createVideoCall(conferenceTitle.text, church);
              }, 
              child: (isConferenceCreating) ? const CircularProgressIndicator() : const Text("Begin", style: TextStyle(color: Color.fromARGB(255, 143, 131, 25)),)
            )
          ],
          content: Form(
            key: _conferenceKey,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: conferenceTitle,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter title";
                  }
                        
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: "Enter title for conference"
                ),
              ),
            ),
          )
        ); 
      },
    );
  }

  void addNewEvent(BuildContext context, Church church) {

    final eventKey = GlobalKey<FormState>();

    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: const Text("New Event"),
          content: Form(
            key: eventKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a title";
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Title",
                  ),
                ),

                const SizedBox(height: 10,),

                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a date";
                    }

                    return null;
                  },
                  onTap: () async {
                    DateTime? date = await showDatePicker(
                      context: context, 
                      firstDate: DateTime.now(), 
                      lastDate: DateTime(2100)
                    );

                    if (date != null) {
                      String result = DateFormat.yMMMEd().format(date);
                      dateController.text = result;
                    }

                  },
                  decoration: const InputDecoration(
                    hintText: "Date",
                  ),
                ),

                const SizedBox(height: 10,),

                TextFormField(
                  controller: timeController,
                  readOnly: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please select a time";
                    }

                    return null;
                  },
                  onTap: () async {
                    TimeOfDay? time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 12, minute: 0));

                    if (time != null) {
                      DateTime result = DateFormat("hh:mm").parse("${time.hour}:${time.minute}");
                      var dateFormat = DateFormat("h:mm a"); 
                      
                      timeController.text = dateFormat.format(result);

                    }
                  },
                  decoration: const InputDecoration(
                    hintText: "Time"
                  ),
                ),

                const SizedBox(height: 10,),

                TextFormField(
                  controller: descriptionController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter a description";
                    }

                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: "Description"
                  ),
                ),

                const SizedBox(height: 20,),

                SizedBox(
                  height: 50,
                  width: 180,
                  child: (isNewEventLoading) ? const SizedBox(height: 50, width: 50,child: CircularProgressIndicator()) : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black
                    ),
                    onPressed: () async {
                        
                      if (!eventKey.currentState!.validate()) {
                        return;
                      }

                      setState(() {
                        isNewEventLoading = true;
                      });

                      Map<String, String> newEvent = {
                        "title": titleController.text.trim(),
                        "date": dateController.text.trim(),
                        "time": timeController.text.trim(),
                        "description": descriptionController.text.trim()
                      };

                      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("churches").doc(church.churchDocID).get();

                      List<dynamic> events = snapshot["events"];

                      events.add(newEvent);

                      await FirebaseFirestore.instance.collection("churches").doc(church.churchDocID).update({"events": events});

                      setState(() {
                        isNewEventLoading = false;
                      });

                      NotificationService.sendNotification(church.subscribers, "New event", "${titleController.text} on ${dateController.text}", {"churchDocID": church.churchDocID, "notificationType": "Event"});

                      titleController.text = "";
                      timeController.text = "";
                      dateController.text = "";
                      descriptionController.text = "";
                      Navigator.pop(context);

                    }, 
                    child: const Text("Submit")),
                )
              ],

            )
          )
        );
      },
    );
  }

  void showEventBottomSheet(BuildContext context, Church church) {
    showModalBottomSheet(
      context: context, 
      
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Container(
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
                        stream: FirebaseFirestore.instance.collection("churches").doc(church.churchDocID).snapshots(),
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

                              return ListTile(
                                title: Text(event.title),
                                subtitle: Text("${event.date} ${event.time}"),
                                trailing: IconButton(
                                  onPressed: () async {
                                      events.removeAt(index);
                        
                                      await FirebaseFirestore.instance.collection("churches").doc(church.churchDocID).update({"events": events});
                                  }, 
                                  icon: const Icon(Icons.delete_rounded, color: Colors.redAccent,)),
                              );
                                    
                            });
                        }
                      ),
                    )
                ],
              ),
            ),
          ),
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
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => LiveStream(liveID: video.link, isHost: false, videoDocID: null)));
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
              trailing: const Icon(Icons.star, color: Colors.amber),
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