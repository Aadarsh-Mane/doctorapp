import 'package:doctorapp/Nurse/FollowUpForm.dart';
import 'package:doctorapp/models/getPatientModel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientDetailScreen1 extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen1({Key? key, required this.patient})
      : super(key: key);

  @override
  _PatientDetailScreen1State createState() => _PatientDetailScreen1State();
}

class _PatientDetailScreen1State extends State<PatientDetailScreen1> {
  late Patient patientDetails; // To store refreshed patient details

  @override
  void initState() {
    super.initState();
    patientDetails = widget.patient; // Initialize with passed patient
  }

  Future<void> _refreshPatientDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://your-backend-api.com/patient/${widget.patient.patientId}'),
        headers: {
          'Authorization': 'Bearer your-jwt-token',
        },
      );

      if (response.statusCode == 200) {
        final updatedPatient = Patient.fromJson(json.decode(response.body));
        setState(() {
          patientDetails = updatedPatient;
        });
      } else {
        throw Exception('Failed to refresh patient details');
      }
    } catch (e) {
      print('Error refreshing patient details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patientDetails.name),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPatientDetails,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text("Patient ID: ${patientDetails.patientId}",
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Age: ${patientDetails.age}",
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Gender: ${patientDetails.gender}",
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Contact: ${patientDetails.contact}",
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text("Address: ${patientDetails.address}",
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final admissionId = patientDetails.admissionRecords.isNotEmpty
                      ? patientDetails.admissionRecords[0].id
                      : null;

                  if (admissionId != null) {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FollowUpForm(
                          admissionId: admissionId,
                          patientId: patientDetails.patientId,
                        ),
                      ),
                    );

                    if (result == true) {
                      _refreshPatientDetails();
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('No admission records found')),
                    );
                  }
                },
                child: Text('Add Follow-Up'),
              ),
              SizedBox(height: 16),
              Text("Admission Records:",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ...patientDetails.admissionRecords.map((admission) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Admission Date: ${admission.admissionDate}",
                          style: TextStyle(fontSize: 16)),
                      Text(
                          "Reason for Admission: ${admission.reasonForAdmission}",
                          style: TextStyle(fontSize: 16)),
                      Text("Symptoms: ${admission.symptoms}",
                          style: TextStyle(fontSize: 16)),
                      Text("Initial Diagnosis: ${admission.initialDiagnosis}",
                          style: TextStyle(fontSize: 16)),
                      if (admission.doctor != null)
                        Text(
                            "Doctor: ${admission.doctor?.name ?? 'Not Assigned'}",
                            style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text("Follow-Ups:",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      ...admission.followUps.map((followUp) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                              "Date: ${followUp.date}, Notes: ${followUp.notes}",
                              style: TextStyle(fontSize: 14)),
                        );
                      }).toList(),
                      Divider(),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
