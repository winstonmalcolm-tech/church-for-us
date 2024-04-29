import "package:flutter/material.dart";

class ChurchDashboard extends StatefulWidget {
  const ChurchDashboard({super.key});

  @override
  State<ChurchDashboard> createState() => _ChurchDashboardState();
}

class _ChurchDashboardState extends State<ChurchDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            const SliverAppBar(
              backgroundColor: Colors.amber,
              expandedHeight: 150,
              toolbarHeight: 100,
              flexibleSpace: FlexibleSpaceBar(
                
                title: const Text("Church name"),
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
                  onPressed: () {}, 
                  icon: const Icon(Icons.live_tv_sharp, size: 40,)
                ),

                IconButton(onPressed: (){}, icon: const Icon(Icons.video_call, size: 40,))
              ],
            )
          ],
        ),
      )
    );
  }
}