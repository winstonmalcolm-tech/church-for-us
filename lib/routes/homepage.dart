import "package:church_stream/routes/churchDashboard.dart";
import "package:church_stream/routes/newChannel.dart";
import "package:church_stream/routes/tab_screens/all_churches.dart";
import "package:church_stream/routes/tab_screens/subscribed_churches.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.amber
              ),
              child: Center(
                child: Text("Welcolme", style: TextStyle(fontSize: 30, color: Colors.white),),
              )
            ),

            ListTile(
              title: const Text("Church dashboard"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChurchDashboard()));
              },
            ),

            ListTile(
              title: const Text("Create a channel"),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NewChannel()));
              },
            ),
          
          ],
        )
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                iconTheme: const IconThemeData(color: Colors.white,size: 30),
                pinned: true,
                primary: false,
                backgroundColor: Colors.grey,
                expandedHeight: 250,
                toolbarHeight: 70,
                actions: [
                  IconButton(
                    onPressed: () {
                      
                    }, 
                  icon: const Icon(Icons.video_call_sharp, size: 30,)
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
                      Tab(text: "All Churches", ),
                      Tab(text: "Subscribed",)
                    ]
                ),
              ),
            ];
          }, 
          body: const TabBarView(
            children: [
               AllChurches(),
               SubscribedChurches()
            ]
          )
          
        )
      ),
    );
  }
}