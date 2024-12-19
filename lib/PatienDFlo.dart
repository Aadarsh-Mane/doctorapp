import 'package:doctorapp/constants/Urls.dart';
import 'package:flutter/material.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PatientDetailScreen2 extends StatefulWidget {
  final Patient1 patient;

  const PatientDetailScreen2({Key? key, required this.patient})
      : super(key: key);

  @override
  _PatientDetailScreen2State createState() => _PatientDetailScreen2State();
}

class _PatientDetailScreen2State extends State<PatientDetailScreen2> {
  Future<List<FollowUp>> _fetchFollowUps(String admissionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = Uri.parse(
        '${MAC_BASE_URL}/nurse/followups/$admissionId'); // API endpoint for fetching follow-ups
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => FollowUp.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load follow-ups');
      }
    } catch (e) {
      throw Exception('Error fetching follow-ups: $e');
    }
  }

  Future<void> _addFollowUp(String patientId, String admissionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    TextEditingController notesController = TextEditingController();
    TextEditingController observationsController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Follow-Up'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: 'Notes'),
              ),
              TextField(
                controller: observationsController,
                decoration: InputDecoration(labelText: 'Observations'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final body = {
                  "patientId": patientId,
                  "admissionId": admissionId,
                  "notes": notesController.text,
                  "observations": observationsController.text,
                };
                final url = Uri.parse('${MAC_BASE_URL}/nurse/addFollowUp');

                try {
                  final response = await http.post(
                    url,
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: json.encode(body),
                  );

                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Follow-up added successfully!')),
                    );
                    setState(() {}); // Refresh UI
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to add follow-up!')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient.name} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Name: ${widget.patient.name}',
                style: TextStyle(fontSize: 18)),
            Text('Patient ID: ${widget.patient.patientId}',
                style: TextStyle(fontSize: 18)),
            Text('Age: ${widget.patient.age}', style: TextStyle(fontSize: 18)),
            Text('Gender: ${widget.patient.gender}',
                style: TextStyle(fontSize: 18)),
            Text('Contact: ${widget.patient.contact}',
                style: TextStyle(fontSize: 18)),
            Text('Address: ${widget.patient.address}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            Text('Admission Records:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ...widget.patient.admissionRecords.map((record) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ExpansionTile(
                  title: Text('Reason: ${record.reasonForAdmission}'),
                  subtitle: Text('Date: ${record.admissionDate}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Symptoms: ${record.symptoms}'),
                          Text('Initial Diagnosis: ${record.initialDiagnosis}'),
                          SizedBox(height: 8),
                          FutureBuilder<List<FollowUp>>(
                            future: _fetchFollowUps(record.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              final followUps = snapshot.data ?? [];
                              if (followUps.isEmpty) {
                                return Text('No follow-ups available.',
                                    style: TextStyle(fontSize: 14));
                              }
                              return Column(
                                children: followUps.map((followUp) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 4.0, horizontal: 8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Date: ${followUp.date}',
                                            style: TextStyle(fontSize: 14)),
                                        Text('Notes: ${followUp.notes}',
                                            style: TextStyle(fontSize: 14)),
                                        Text(
                                            'Observations: ${followUp.observations}',
                                            style: TextStyle(fontSize: 14)),
                                        Divider(),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                          SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => _addFollowUp(
                                widget.patient.patientId, record.id),
                            child: Text('Add Follow-Up'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class FollowUp {
  final String date;
  final String notes;
  final String observations;

  FollowUp(
      {required this.date, required this.notes, required this.observations});

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      date: json['date'] ?? '',
      notes: json['notes'] ?? '',
      observations: json['observations'] ?? '',
    );
  }
}
