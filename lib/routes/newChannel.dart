import "package:church_stream/models/viewer.dart";
import "package:church_stream/routes/churchDashboard.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:provider/provider.dart";

class NewChannel extends StatefulWidget {
  const NewChannel({super.key});

  @override
  State<NewChannel> createState() => _NewChannelState();
}

class _NewChannelState extends State<NewChannel> {
  final _newChannelFormKey = GlobalKey<FormState>();

  TextEditingController churchName = TextEditingController();
  TextEditingController country = TextEditingController();
  bool _isLoading = false;

  final _box = Hive.box("cache_auth");
  late Viewer _viewer;

  Future<void> newChannel() async {
    DocumentReference ref =  await FirebaseFirestore.instance.collection("churches").add({
        "churchName": churchName.text,
        "country":country.text,
        "createdBy": _viewer.docID,
        "subscribers": [],
        "events": []
    });

    String docID = ref.id;

    await FirebaseFirestore.instance.collection("churches").doc(docID).set({"docID": docID}, SetOptions(merge: true));
    await FirebaseFirestore.instance.collection("users").doc(_viewer.docID).update({"role": "admin"});
    await FirebaseFirestore.instance.collection("users").doc(_viewer.docID).set({"churchDocID": docID}, SetOptions(merge: true));
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("users").doc(_viewer.docID).get();
    List<dynamic> subscriptions = snapshot["subscriptions"];
    
    Map<String, dynamic> updatedUser = {
      "firstName": _viewer.firstName,
      "lastName": _viewer.lastName,
      "email": _viewer.email,
      "deviceToken": _viewer.deviceToken,
      "userDocID": _viewer.docID,
      "role": "admin",
      "churchDocID": docID,
      "subscriptions": subscriptions
    };

    await _box.put("cache", updatedUser);
    Provider.of<Viewer>(context, listen: false).updateViewer(_viewer.firstName, _viewer.lastName, _viewer.email, _viewer.deviceToken, _viewer.docID, "admin", docID, subscriptions);
  }

  @override
  void initState() {
    _viewer = Viewer.fromMap(_box.get("cache"));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text("New Channel", style: TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _newChannelFormKey, 
          child: ListView(
            children: [
              TextFormField(
                controller: churchName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a church name";
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Church name")
                ),
              ),
        
              const SizedBox(height: 20,),
        
              TextFormField(
                controller: country,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a country";
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Country")
                ),
              ),
        
              const SizedBox(height: 20,),
        
              (_isLoading) ? const Center(child: CircularProgressIndicator()): ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.white,
                  fixedSize: const Size(150, 60)
                ),
                onPressed: () async { 
                    if (!_newChannelFormKey.currentState!.validate()) {
                      return;
                    }
                    
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                    
                    await newChannel();
              
                    setState(() {
                      _isLoading = !_isLoading;
                    });
                    
                    churchName.text = "";
                    country.text = "";
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Channel Created")));
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ChurchDashboard()));
                }, 
                child: const Text("Add channel", style: TextStyle(fontSize: 20),)),
            ],
          )
        ),
      ),
    );
  }
}