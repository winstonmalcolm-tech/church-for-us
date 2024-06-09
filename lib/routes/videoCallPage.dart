import "dart:isolate";
import "package:church_stream/firebase_options.dart";
import "package:church_stream/models/viewer.dart";
import "package:church_stream/private/keys.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:provider/provider.dart";
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoCallPage extends StatefulWidget {
  final String callID;
  final bool isHost;
  final String? videoDocID;
  const VideoCallPage({super.key, required this.callID, required this.isHost, required this.videoDocID});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: zegoCloudAppID,
        appSign: zegoCloudAppSignIn,
        conferenceID: widget.callID, 
        userID: Provider.of<Viewer>(context).docID, 
        userName: '${Provider.of<Viewer>(context).firstName} ${Provider.of<Viewer>(context).lastName}', 
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          
          onLeaveConfirmation: (context) async {
            final token = RootIsolateToken.instance;
            Map<String,dynamic> info ={"videoDocID": widget.videoDocID, "token": token, "recordedData": {"isLive": false, "link":"https://"}};

            await Isolate.spawn(handleMeetingClose, info);
            return true;
          },
          turnOnCameraWhenJoining: true,
          turnOnMicrophoneWhenJoining: true,
          useSpeakerWhenJoining: true,
          audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(useVideoViewAspectFill: true),
        ),
      ),
    );
  }
}

//Update backend data
Future<void> handleMeetingClose(Map<String,dynamic> data) async {

  BackgroundIsolateBinaryMessenger.ensureInitialized(data["token"]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseFirestore.instance.collection("videos").doc(data["videoDocID"]).update(data["recordedData"]);
} 