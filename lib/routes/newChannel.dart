import "package:flutter/material.dart";

class NewChannel extends StatefulWidget {
  const NewChannel({super.key});

  @override
  State<NewChannel> createState() => _NewChannelState();
}

class _NewChannelState extends State<NewChannel> {
  final _newChannelFormKey = GlobalKey<FormState>();

  TextEditingController churchName = TextEditingController();
  TextEditingController country = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Channel"),
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
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Church name")
                ),
              ),
        
              const SizedBox(height: 20,),
        
              TextFormField(
                controller: country,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Country")
                ),
              ),
        
              const SizedBox(height: 20,),
        
              SizedBox(
                height: 60,
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 156, 120, 9),
                    foregroundColor: Colors.white,
                    fixedSize: const Size(150, 60)
              
                  ),
                  onPressed: () { 
                      
                  }, 
                  child: const Text("Add channel", style: TextStyle(fontSize: 20),)),
              ),
            ],
          )
        ),
      ),
    );
  }
}