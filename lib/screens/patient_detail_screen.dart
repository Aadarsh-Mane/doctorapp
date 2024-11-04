import 'package:doctorapp/models/getPatientModel.dart';
import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final Patient patient;

  const PatientDetailScreen({Key? key, required this.patient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${patient.name}'s Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Patient ID: ${patient.patientId}"),
            SizedBox(height: 8),
            Text("Name: ${patient.name}"),
            SizedBox(height: 8),
            Text("Age: ${patient.age}"),
            SizedBox(height: 8),
            Text("Gender: ${patient.gender}"),
            SizedBox(height: 8),
            Text("Contact: ${patient.contact}"),
            SizedBox(height: 8),
            Text("Address: ${patient.address}"),
            SizedBox(height: 16),
            Text("Admission Records:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            if (patient.admissionRecords.isNotEmpty)
              ...patient.admissionRecords.map((record) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Admission Date: ${record.admissionDate}"),
                        Text("Reason: ${record.reasonForAdmission}"),
                        Text("Symptoms: ${record.symptoms}"),
                        Text("Initial Diagnosis: ${record.initialDiagnosis}"),
                        Text("Doctor: ${record.doctor.name}"),
                        if (record.followUps.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 8),
                              Text("Follow-ups:",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              ...record.followUps.map((followUp) {
                                return Text(
                                    "${followUp.date} - ${followUp.notes}");
                              }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }).toList()
            else
              Text("No admission records available."),
          ],
        ),
      ),
    );
  }
}
