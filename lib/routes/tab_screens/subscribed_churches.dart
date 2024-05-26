import "package:church_stream/models/church.dart";
import "package:church_stream/routes/detailedScreen.dart";
import "package:flutter/material.dart";

class SubscribedChurches extends StatefulWidget {
  final Future<List<Church>>? followedChurches;

  const SubscribedChurches({super.key, required this.followedChurches});

  @override
  State<SubscribedChurches> createState() => _SubscribedChurchesState();
}

class _SubscribedChurchesState extends State<SubscribedChurches> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: widget.followedChurches, 
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.done) {

            if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No subscriptions", style: TextStyle(fontSize: 20),),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Church church = snapshot.data![index];

                return ListTile(
                  leading: const CircleAvatar(backgroundImage: AssetImage("assets/praise.jpg")),
                  title: Text(church.churchName),
                  subtitle: Text("${church.subscribers.length} subscribers"),
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SingleChurch(church: church)));
                  },
                );
              },
            );

          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }
}