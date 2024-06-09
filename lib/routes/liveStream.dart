import "dart:isolate";
import "package:church_stream/firebase_options.dart";
import "package:church_stream/models/viewer.dart";
import "package:church_stream/private/keys.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LiveStream extends StatefulWidget {
  final String liveID;
  final bool isHost;
  final String? videoDocID;
  
  const LiveStream({super.key, required this.liveID, required this.isHost, required this.videoDocID});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: liveStreamWidget(context)
    );
  }

  ZegoUIKitPrebuiltLiveStreaming liveStreamWidget(BuildContext context) {
    return ZegoUIKitPrebuiltLiveStreaming(
          appID: zegoCloudAppID,
          appSign: zegoCloudAppSignIn,
          userID: Provider.of<Viewer>(context, listen: false).docID,
          userName: '${Provider.of<Viewer>(context, listen: false).firstName} ${Provider.of<Viewer>(context, listen: false).lastName}',
          liveID: widget.liveID,
          events: ZegoUIKitPrebuiltLiveStreamingEvents(
            onEnded: (event, defaultAction) {
              defaultAction.call();
              if (event.reason == ZegoLiveStreamingEndReason.hostEnd) {
                _showAlertDialog(context);
              }
              
            },
            onLeaveConfirmation: (event, defaultAction) async {
              final token = RootIsolateToken.instance;
              Map<String,dynamic> info ={"videoDocID": widget.videoDocID, "token": token, "recordedData": {"isLive": false, "link":"https://"}};

              await Isolate.spawn(streamCloseHandler, info);
              
              return defaultAction.call();
            },
          ),
          config: widget.isHost
              ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
              : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
        );
  }


  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stream ended'),
          content: const Text('The host stopped the stream'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)..pop()..pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

//Update database
Future<void> streamCloseHandler(Map<String,dynamic> data) async {

  BackgroundIsolateBinaryMessenger.ensureInitialized(data["token"]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await FirebaseFirestore.instance.collection("videos").doc(data["videoDocID"]).update(data["recordedData"]);
}