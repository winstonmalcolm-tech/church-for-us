import "package:email_validator/email_validator.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";

class Authentication extends StatefulWidget {
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {

  bool newUser = false;

  final _key = GlobalKey<FormState>();

  TextEditingController firstName = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController isMember = TextEditingController(text: "");
  TextEditingController password = TextEditingController();
  TextEditingController churchName = TextEditingController();

  double scaleValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: register(),
              )
                  
            ),
        
          ],
        ),
      ),
    );
  }


  Form register() {

    return Form(
      key: _key,
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

          const SizedBox(height: 20,),

          if (isMember.text == "2") ... [
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
          ]
        ],
      ) 
    );
  }
}