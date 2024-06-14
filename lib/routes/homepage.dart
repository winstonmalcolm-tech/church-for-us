import "package:church_stream/models/church.dart";
import "package:church_stream/models/viewer.dart";
import "package:church_stream/routes/aiPage.dart";
import "package:church_stream/routes/auth.dart" as a;
import "package:church_stream/routes/churchDashboard.dart";
import "package:church_stream/routes/detailedScreen.dart";
import "package:church_stream/routes/newChannel.dart";
import "package:church_stream/routes/profileScreen.dart";
import "package:church_stream/routes/searchDelegate.dart";
import "package:church_stream/routes/tab_screens/all_churches.dart";
import "package:church_stream/routes/tab_screens/subscribed_churches.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:provider/provider.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final _box = Hive.box("cache_auth");
  Future<List<Church>>? churches;
  Future<List<Church>>? followedChurches;

  @override
  void initState() {
    churches = getChurches();
    followedChurches = getSubcribeChurches();

    super.initState();
  }

  Future<List<Church>> getChurches() async {
    List<Church> data = [];

    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance.collection("churches").get();
    List<QueryDocumentSnapshot> docs =  snapshot.docs;

    for (QueryDocumentSnapshot doc in docs) {
        data.add(Church(churchName: doc["churchName"], country: doc["country"], createdBy: doc["createdBy"], churchDocID: doc["docID"], subscribers: doc["subscribers"], events: doc["events"]));
    }
    
    return data;
  }

  Future<List<Church>> getSubcribeChurches() async {
    List<Church> churchSubscriptions = [];

    List<dynamic> churchDocIDs = Provider.of<Viewer>(context, listen: false).subscriptions;

    for (String churchDocID in churchDocIDs) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("churches").doc(churchDocID).get();
      churchSubscriptions.add(Church(churchDocID: snapshot["docID"], churchName: snapshot["churchName"], country: snapshot["country"], createdBy: snapshot["createdBy"], subscribers: snapshot["subscribers"], events: snapshot["events"]));  
    }

    return churchSubscriptions;
  }
  

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.amber
              ),
              child: Center(
                child: Text("Welcome ${Provider.of<Viewer>(context,listen: false).firstName}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, color: Colors.white),),
              )
            ),

            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
            ),
        
            if (Provider.of<Viewer>(context, listen: false).role == "admin")
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text("Church dashboard"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChurchDashboard()));
                },
              ),
        
            if (Provider.of<Viewer>(context, listen: false).role == "user")
              ListTile(
                leading: const Icon(Icons.movie_creation_rounded),
                title: const Text("Create a channel"),
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewChannel()));
                },
              ),
            
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () async {
                await _box.clear();
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const a.Authentication()));
              },
            )
          ],
        )
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  ),
                ),
                iconTheme: const IconThemeData(color: Colors.white,size: 30),
                pinned: true,
                primary: false,
                expandedHeight: 250,
                toolbarHeight: 100,
                backgroundColor: Colors.amber,
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: IconButton(
                      onPressed: () async {
                        Church? church = await showSearch<Church?>(
                          context: context, 
                          delegate: SearchChurchDelegate(churches)
                        );
                        
                        if (church != null) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => SingleChurch(church: church)));
                        }
                        
                      }, 
                      icon: const Icon(Icons.search)
                    ),
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(

                  background: Image.asset("assets/praise.jpg", fit: BoxFit.cover, color: Colors.black26,colorBlendMode: BlendMode.darken,),
                ),
                bottom: const TabBar(
                    labelColor: Colors.white,
                    indicatorColor: Colors.amber,
                    labelStyle: TextStyle(fontSize: 20, ),
                    tabs: [
                      Tab(text: "Streams",),
                      Tab(text: "Subscriptions",)
                    ]
                ),
              ),
            ];
          }, 
          body: TabBarView(
            children: [
              const AllChurches(),
        
               RefreshIndicator(
                onRefresh: () async {
                  followedChurches = getSubcribeChurches();
                  setState(() {
                    
                  });
                },
                child: SubscribedChurches(followedChurches: followedChurches)
              )
            ]
          )
          
        )
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        heroTag: null,
        elevation: 0,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => AIPage(firstName: Provider.of<Viewer>(context, listen: false).firstName, docID: Provider.of<Viewer>(context).docID)));
        },
        child: Hero(tag: "bot",child: Image.asset("assets/chatbot.png")),
      ),
    );
  }
}