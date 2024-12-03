import 'package:doctorapp/Doctor/DoctorPatientDetailScreen.dart';
import 'package:doctorapp/Nurse/PatientDetailScreen2.dart';
import 'package:doctorapp/models/getPatientModel.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/patient_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignedPatientsScreen extends ConsumerWidget {
  const AssignedPatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedPatients = ref.watch(assignedPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Patients'),
      ),
      body: assignedPatients.when(
        data: (patients) => ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];
            return ListTile(
              title: Text(patient.name),
              subtitle: Text('Age: ${patient.age}, Gender: ${patient.gender}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PatientDetailScreen4(patient: patient),
                  ),
                );
              },
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
