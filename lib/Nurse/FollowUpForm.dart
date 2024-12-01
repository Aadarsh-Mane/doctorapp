import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FollowUpForm extends StatefulWidget {
  final String patientId;
  final String admissionId;

  FollowUpForm({Key? key, required this.patientId, required this.admissionId})
      : super(key: key);

  @override
  _FollowUpFormState createState() => _FollowUpFormState();
}

class _FollowUpFormState extends State<FollowUpForm> {
  final _formKey = GlobalKey<FormState>();
  String notes = '';
  String observations = '';

  Future<void> addFollowUp() async {
    final response = await http.post(
      Uri.parse('http://http://192.168.0.103:3000/nurse/addFollowUp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'patientId': widget.patientId,
        'admissionId': widget.admissionId,
        'notes': notes,
        'observations': observations,
      }),
    );

    if (response.statusCode == 200) {
      // Follow-up added successfully
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Follow-up added successfully!')));
      Navigator.pop(context); // Close the form after successful submission
    } else {
      // Handle error
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add follow-up.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Follow-Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter notes';
                  }
                  return null;
                },
                onChanged: (value) {
                  notes = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Observations'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter observations';
                  }
                  return null;
                },
                onChanged: (value) {
                  observations = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addFollowUp();
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
