import 'package:flutter/material.dart';

class NurseMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nurse's Dashboard")),
      body: Center(child: Text("Welcome, Nurse!")),
    );
  }
}
