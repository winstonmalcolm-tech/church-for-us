import "dart:async";
import "package:church_stream/models/viewer.dart";
import "package:church_stream/routes/homepage.dart";
import "package:cloud_firestore/cloud_firestore.dart";
import "package:email_validator/email_validator.dart";
import "package:firebase_messaging/firebase_messaging.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";
import "package:provider/provider.dart";

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {

  bool newUser = true;
  bool showForm = false;
  late double _width;
  bool isLoading = false;


  final _registerKey = GlobalKey<FormState>();
  final _loginKey = GlobalKey<FormState>();

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  
  final _db = FirebaseFirestore.instance;
  final _box = Hive.box("cache_auth");
  final _fbMessaging = FirebaseMessaging.instance;

  Future<String> getToken() async {
    final deviceToken = await _fbMessaging.getToken();
    return deviceToken!;
  }

  Future<bool> isEmailAvailable(String email) async {
    var snapshot = await _db.collection("users").get();
    List<QueryDocumentSnapshot> docs = snapshot.docs;

    for(var doc in docs) {
      if (doc["email"] == email) {
        return false;
      }
    }

    return true;
  }
  Future<bool> loginMember(String email) async {
     
     var results = await _db.collection("users").get();

     List<QueryDocumentSnapshot> docs = results.docs;
     Map<String, dynamic> loggedData;
     

     for(QueryDocumentSnapshot doc in docs) {
        if (doc["email"] == email) {
          loggedData = {
            "firstName": doc["firstName"],
            "lastName": doc["lastName"],
            "email": doc["email"],
            "userDocID": doc["userDocID"],
            "deviceToken":doc["deviceToken"],
            "role": doc["role"],
            "churchDocID": doc["churchDocID"],
            "subscriptions": doc["subscriptions"]
          };

          Provider.of<Viewer>(context, listen: false).updateViewer(doc["firstName"], doc["lastName"], doc["email"], doc["deviceToken"], doc["userDocID"], doc["role"], doc["churchDocID"], doc["subscriptions"]);
          await _box.put("cache", loggedData);

          return true;
        }
     }
      
     return false;
  }

  Future<void> newMember(Map<String, dynamic> cacheData, BuildContext context) async {

    DocumentReference dr = await _db.collection("users").add(cacheData);
    _db.collection("users").doc(dr.id).set({"userDocID": dr.id}, SetOptions(merge: true));
    
    cacheData["userDocID"] = dr.id;

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      FirebaseFirestore.instance.collection("users").doc(dr.id).update({"deviceToken": token});
      cacheData["deviceToken"] = token;
    });

    await _box.put("cache", cacheData);
    
    if(context.mounted) {
      Viewer.fromMap(cacheData);
      
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Home()));
    }
    
    firstName.text = "";
    lastName.text = "";
    email.text = "";
  }

  @override
  void initState() {
    _width = 300;

   Timer(const Duration(milliseconds: 2000), () {
      setState(() {
        showForm = true;
        _width = 0;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 260,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 156, 120, 9),
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
            ),
            child: Center(
              child: Image.asset("assets/cross.png"),
            ),
          ),

          const SizedBox(height: 10,),
         
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: AnimatedCrossFade(
                excludeBottomFocus: false,
                firstChild: Container(
                  height: MediaQuery.of(context).size.height,
                  width:  _width,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: (showForm) ? null : const Align(alignment: Alignment.center,child: Text("WELCOME", style: TextStyle(fontSize: 30))),
                  
                ), 
                secondChild: (newUser) ? register() : login(), 
                crossFadeState: (!showForm) ? CrossFadeState.showFirst : CrossFadeState.showSecond, 
                duration: const Duration(milliseconds: 2000),
              )
            )     
          ),
      
          Expanded(
            flex: 1,
            child: (newUser) ? 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("Already have an account? ", style: TextStyle(fontSize: 20),),
                TextButton(
                  onPressed: () {
                    setState(() {
                      newUser = !newUser;
                    });
                  }, 
                  child: const Text("Login", style: TextStyle(fontSize: 20))
                ),
                        
              ],
            ) : 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("New user? ", style: TextStyle(fontSize: 20),),
                TextButton(
                  onPressed: () {
                    setState(() {
                      newUser = !newUser;
                    });
                  }, 
                  child: const Text("Register", style: TextStyle(fontSize: 20))
                ),
          
              ],
            )
          )
      
        ],
      ),
    );
  }


  Form login() {
    return Form(
      key: _loginKey,
      child: Column(
        children: [
          TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter email";
                } else if (!EmailValidator.validate(value)) {
                  return "Please enter valid email";
                }

                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "church@gmail.com",
                label: Text("Email")
              ),
            ),

            const SizedBox(height: 20,),

            (isLoading) ? const CircularProgressIndicator() : SizedBox(
              height: 60,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 156, 120, 9),
                  foregroundColor: Colors.white,
                  fixedSize: const Size(150, 60)    
                ),
                onPressed: () async {
                  setState(() {
                    isLoading = !isLoading;
                  }); 

                  if (_loginKey.currentState!.validate()) {

                    if (await loginMember(email.text)) {       
                      setState(() {
                        isLoading = !isLoading;
                      });          
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const Home()));                    
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email not registered")));
                    }
                  } 

                  setState(() {
                    isLoading = !isLoading;
                  });                  
                }, 
                child: const Text("Login", style: TextStyle(fontSize: 20),)),
            ),
        ],
      )
    );
  }

  Form register() {
    return Form(
      key: _registerKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: firstName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter first name";
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Maxwell",
                label: Text("First name")
              ),
            ),
        
            const SizedBox(height: 20,),
        
            TextFormField(
              controller: lastName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter last name";
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Jhonson",
                label: Text("last name")
              ),
            ),
        
            const SizedBox(height: 20,),
        
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter email";
                } else if (!EmailValidator.validate(value)) {
                  return "Please enter valid email";
                }

                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "name@gmail.com",
                label: Text("Email")
              ),
            ),

            const SizedBox(height: 20,),
        
            (isLoading) ? const CircularProgressIndicator() : SizedBox(
              height: 60,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 156, 120, 9),
                  foregroundColor: Colors.white,
                  fixedSize: const Size(150, 60)
            
                ),
                onPressed: () async { 
                  setState(() {
                    isLoading = ! isLoading;
                  });

                  if (!await isEmailAvailable(email.text)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email already registered")));
                    setState(() {
                      isLoading = ! isLoading;
                    });

                    return;
                  }
                  String token = await getToken();

                  Map<String, dynamic> data = {
                    "firstName": firstName.text,
                    "lastName": lastName.text,
                    "deviceToken": token,
                    "email": email.text,
                    "role": "user",
                    "churchDocID": "null",
                    "subscriptions": []
                  };

                  if (_registerKey.currentState!.validate()) {
                    await newMember(data, context);
                  }

                  setState(() {
                    isLoading = ! isLoading;
                  });

                  
                }, 
                child: const Text("Register", style: TextStyle(fontSize: 20),)),
            ),
        
            const SizedBox(height: 10,)
          ],
        ),
      ) 
    );
  }
}