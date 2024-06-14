import 'package:church_stream/models/church.dart';
import 'package:church_stream/models/viewer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    if (searchResult == null) {
      return Lottie.asset("assets/no_video.json");
    }

    return const SizedBox(width: 10, height: 10);
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
            return (church.churchName.toLowerCase().contains(query.toLowerCase()) && (Provider.of<Viewer>(context).churchDocID != church.churchDocID));
          }).toList();

          return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                Church church = suggestions[index];
                
                return ListTile(
                  title: Text(church.churchName),
                  onTap: () {
                    query = church.churchName;
                    searchResult = church;

                    close(context, searchResult);
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
    );  
  }
}