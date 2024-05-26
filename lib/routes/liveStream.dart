import "package:church_stream/models/viewer.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LiveStream extends StatefulWidget {
  final String liveID;
  final bool isHost;
  final String? videoDocID;
  final String? title;
  
  const LiveStream({super.key, required this.liveID, required this.isHost, required this.videoDocID, required this.title});

  @override
  State<LiveStream> createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {

  @override
  void initState() {
    
    super.initState();
  }

  @override
  void dispose() async {
    if (widget.isHost && widget.videoDocID != null) {
      await FirebaseFirestore.instance.collection("videos").doc(widget.videoDocID).update({"isLive": false, "link": "http://url.com"});
    }

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: 867092340,// Fill in the appID that you get from ZEGOCLOUD Admin Console.
        appSign: "1e193406f88e377a7de9cf2549ecfc698799387bc438bb8b5258de5e32ff1693",// Fill in the appSign that you get from ZEGOCLOUD Admin Console.
        userID: Provider.of<Viewer>(context, listen: false).docID,
        userName: '${Provider.of<Viewer>(context, listen: false).firstName} ${Provider.of<Viewer>(context, listen: false).lastName}',
        liveID: widget.liveID,
        events: ZegoUIKitPrebuiltLiveStreamingEvents(
          onEnded: (event, defaultAction) {
            if (ZegoLiveStreamingEndReason.hostEnd == event.reason) {
              _showAlertDialog(context);
            }
          },
          
        ),
        config: widget.isHost
            ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
            : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
      ),
    );
  }


  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stream ended'),
          content: const Text('The host stopped the stream'),
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