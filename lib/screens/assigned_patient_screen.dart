import 'package:doctorapp/models/getPatientModel.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/patient_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignedPatientsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientsAsyncValue = ref.watch(assignedPatientsProvider);

    return Scaffold(
      appBar: AppBar(title: Text("Assigned Patients")),
      body: patientsAsyncValue.when(
        data: (patients) {
          if (patients.isEmpty) {
            return Center(child: Text("No patients assigned."));
          }
          return ListView.builder(
            itemCount: patients.length,
            itemBuilder: (context, index) {
              final Patient patient = patients[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text("Name: ${patient.name}"),
                  subtitle: Text("ID: ${patient.patientId}"),
                  onTap: () {
                    // Navigate to the patient detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientDetailScreen(patient: patient),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
