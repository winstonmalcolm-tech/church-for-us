import "package:church_stream/models/viewer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoCallPage extends StatefulWidget {
  final String callID;
  final bool isHost;
  const VideoCallPage({super.key, required this.callID, required this.isHost});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {

  @override
  void dispose() {

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: 867092340,// Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign: "1e193406f88e377a7de9cf2549ecfc698799387bc438bb8b5258de5e32ff1693",// Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        conferenceID: widget.callID, 
        userID: Provider.of<Viewer>(context).docID, 
        userName: '${Provider.of<Viewer>(context).firstName} ${Provider.of<Viewer>(context).lastName}', 
        config: ZegoUIKitPrebuiltVideoConferenceConfig(
          turnOnCameraWhenJoining: true,
          turnOnMicrophoneWhenJoining: true,
          useSpeakerWhenJoining: true,
          audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(useVideoViewAspectFill: true),
        ),

      ),
    );
  }
}