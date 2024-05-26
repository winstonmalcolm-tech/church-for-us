import 'package:church_stream/models/church.dart';
import 'package:church_stream/models/viewer.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SearchChurchDelegate extends SearchDelegate<Church?> {

  Future<List<Church>>? churches;
  Church? searchResult;

  SearchChurchDelegate(this.churches);

  @override
  List<Widget>? buildActions(BuildContext context) {
    
    return [

      IconButton(
        onPressed: () {
          
          if (query.isEmpty) {
            close(context, null);
          } else {
            query = "";
          }
        }, 
        icon: const Icon(Icons.clear)
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
      }, icon: const Icon(Icons.arrow_back)
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return const Placeholder();
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    return FutureBuilder(
      future: churches,
      builder: (context, snapshot) {
        
        if (snapshot.connectionState == ConnectionState.done) {

          if (!snapshot.hasData) {
            return Center(
              child: Lottie.asset("assets/no_video.json", height: 250)
            );
          }

          List<Church> suggestions = snapshot.data!.where((church) {
            return church.churchName.toLowerCase().contains(query.toLowerCase());
          }).toList();

          return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                Church church = suggestions[index];
                
                return (Provider.of<Viewer>(context).churchDocID != church.churchDocID) ? ListTile(
                  title: Text(church.churchName),
                  onTap: () {
                    query = church.churchName;
                    searchResult = church;

                    close(context, searchResult);
                  },
                ) : null;
              },
            );
        } else {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );

    
  }

    InkWell churchCard(String churchName, int subscribersCount, BuildContext context) {
    return InkWell(
      onTap: () async {
       
      },
      child: Container(
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
              title: Text(churchName),
              subtitle: Text("$subscribersCount"),
              trailing: OutlinedButton(
                onPressed: (){
      
                }, 
                child: const Text("Subscribe", style: TextStyle(color: Colors.amber),),
              ),
            )
          ],
        ),
      ),
    );
  }
  
}