import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";

class AllChurches extends StatefulWidget {
  const AllChurches({super.key});

  @override
  State<AllChurches> createState() => _AllChurchesState();
}

class _AllChurchesState extends State<AllChurches> {

  Container churchCard() {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black45),
        borderRadius: const BorderRadius.all(Radius.circular(20))
      ),
      child: Column(
        children: [
          
          Container(
              height: 200,
              decoration: const BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20))
              ),
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(topRight: Radius.circular(20), 
                topLeft: Radius.circular(20)),
                child: Image.asset("assets/praise.jpg", fit: BoxFit.cover, )
              )
            ),

          ListTile(
            tileColor: Colors.white,
            title: const Text("Church of God"),
            subtitle: const Text("200 subscribers"),
            trailing: OutlinedButton(
              onPressed: (){

              }, 
              child: const Text("Subscribe", style: TextStyle(color: Colors.amber),),
            ),
          )
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            churchCard()
          ],
        ),
      ),
    );
  }
}