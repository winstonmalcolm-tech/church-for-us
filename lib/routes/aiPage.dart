import 'package:church_stream/private/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter/widgets.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

//AIzaSyAw5qUB5GnU3hHXfxiLdavOe4xJdqcsHTk

class AIPage extends StatefulWidget {
  final String firstName;
  final String docID;

  const AIPage({super.key, required this.firstName, required this.docID});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  late GenerativeModel model;
  TextEditingController promptController = TextEditingController();

  List<types.TextMessage> _messages = [];

  late types.User _user;
  late types.User _ai;

  late bool shouldSave;

  @override
  void initState() {

    shouldSaveChat().then((value) {
      shouldSave = value;
    });

    getMessages();

    _user = types.User(
      id: 'user',
      firstName: widget.firstName,
    );

    _ai = const types.User(
      id: "ai_bot",
      firstName: "Deacon"
    );
   
    model = modelConfig;
    super.initState();
  }

  Future<bool> shouldSaveChat() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool("status") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.black54,)
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text("Deacon", style: TextStyle(color: Colors.black54),),
            const SizedBox(width: 10,),
            Hero(tag: "bot", child: SizedBox(height: 40, width: 40, child: Image.asset("assets/chatbot.png")))
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Chat(
                messages: _messages,
                onSendPressed: _handleSendPressed,
                showUserAvatars: true,
                showUserNames: true,
                user: _user,
                theme: const DefaultChatTheme(primaryColor: Color.fromARGB(255, 156, 120, 9), userAvatarNameColors: [Color.fromARGB(255, 156, 120, 9)]),
              ),
      ),
    );
  }



  void _addMessage(types.TextMessage message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  Future<void> _handleSendPressed(types.PartialText message) async {
    List<Map<String,dynamic>> messages = [];

    final userPrompt = types.TextMessage(
      author: _user,
      id: const Uuid().v4(),
      text: message.text,
    );

    _addMessage(userPrompt);

    final content = [Content.text(message.text)];
    final response = await model.generateContent(content);

    final aiResponse = types.TextMessage(
      author: _ai,
      id: const Uuid().v4(),
      text: response.text!
    );

    _addMessage(aiResponse);

    

    for (var m in _messages) {

      messages.add({
        "id": m.id,
        "text": m.text,
        "author": {
          "id": m.author.id,
          "firstName": m.author.firstName
        }
      });
    }

    if (shouldSave) {
      await FirebaseFirestore.instance.collection("chats").doc(widget.docID).set({"messages": messages});
    }

  }

  void getMessages() async {

    List<types.TextMessage> messages = [];

    DocumentSnapshot snapshot =  await FirebaseFirestore.instance.collection("chats").doc(widget.docID).get();

    if (!snapshot.exists) {
      return;
    }
    
    for(var message in snapshot["messages"]) {
      messages.add(types.TextMessage.fromJson(message));
    }

    setState(() {
      _messages = messages;
    });
  }
}