import "package:flutter/material.dart";

class SubscribedChurches extends StatefulWidget {
  const SubscribedChurches({super.key});

  @override
  State<SubscribedChurches> createState() => _SubscribedChurchesState();
}

class _SubscribedChurchesState extends State<SubscribedChurches> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Subcribed churches"),
      ),
    );
  }
}