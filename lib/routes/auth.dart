import "dart:async";

import "package:email_validator/email_validator.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {

  bool newUser = true;
  bool showForm = false;
  late double _width;

  final _key = GlobalKey<FormState>();

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController isMember = TextEditingController(text: "");
  TextEditingController password = TextEditingController();
  TextEditingController churchName = TextEditingController();

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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
              
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 199, 180, 12),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20))
                )
                
              )
            ),
            const SizedBox(height: 20,),
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedCrossFade(
                  excludeBottomFocus: false,
                  firstChild: Container(
                    height: MediaQuery.of(context).size.height,
                    width:  _width,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: (showForm) ? null : const Align(alignment: Alignment.center,child: Text("WELCOME", style: TextStyle(fontSize: 30))),
                    
                  ), 
                  secondChild: register(), 
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
      ),
    );
  }


  Form register() {

    return Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: firstName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter first name";
                }
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
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "church@gmail.com",
                label: Text("Email")
              ),
            ),
        
            const SizedBox(height: 20,),
        
            DropdownButtonFormField(
              value: "1",
              decoration: const InputDecoration(
                border: OutlineInputBorder()
              ),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: const [
                DropdownMenuItem(value: "1", child: Text("Member")),
                DropdownMenuItem(value: "2", child: Text("Church Admin"))
              ], 
              onChanged: (value) {
                setState(() {
                  isMember.text = value!;
                });
                
              }
            ),
        
            if (isMember.text == "2") ... [
              const SizedBox(height: 20,),
        
              TextFormField(
                  controller: churchName,
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter email";
                    }
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "name of church",
                    label: Text("Church name"),
                    
                  ),
                )
            ],
        
            const SizedBox(height: 20,),
        
            SizedBox(
              height: 60,
              width: 150,
              child: ElevatedButton(
                onPressed: () { 
        
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