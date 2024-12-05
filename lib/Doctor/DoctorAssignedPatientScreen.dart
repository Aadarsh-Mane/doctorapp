import 'dart:convert';

import 'package:doctorapp/Check.dart';
import 'package:doctorapp/Doctor/DoctorAssignedLabsPatient.dart';
import 'package:doctorapp/Doctor/DoctorPatientDetailScreen.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final assignedPatientsProvider =
    StateNotifierProvider<AssignedPatientsNotifier, AsyncValue<List<Patient1>>>(
  (ref) {
    final authRepository = ref.read(authRepositoryProvider);
    final notifier = AssignedPatientsNotifier(authRepository);
    notifier.fetchAssignedPatients(); // Fetch data on initialization
    return notifier;
  },
);

class AssignedPatientsScreen extends ConsumerWidget {
  const AssignedPatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedPatients = ref.watch(assignedPatientsProvider);
    ref.refresh(assignedPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Patients'),
        actions: [
          // Refresh button to manually refresh patient data
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .refresh(assignedPatientsProvider.notifier)
                  .fetchAssignedPatients();
            },
          ),
          // Navigate to AssignedLabsScreen
          IconButton(
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AssignedLabsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: assignedPatients.when(
        data: (patients) => ListView.builder(
          itemCount: patients.length,
          itemBuilder: (context, index) {
            final patient = patients[index];

            return Dismissible(
              key: Key(patient.id), // Unique key for each item
              direction:
                  DismissDirection.endToStart, // Swipe from right to left
              onDismissed: (direction) async {
                bool? shouldDischarge =
                    await _showDischargeConfirmationDialog(context);

                if (shouldDischarge == true) {
                  await _dischargePatient(patient, ref);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Patient not discharged')),
                  );
                }
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: ListTile(
                title: Text(patient.name),
                subtitle:
                    Text('Age: ${patient.age}, Gender: ${patient.gender}'),
                onTap: () {
                  // Navigate to patient details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailScreen4(
                        patient: patient,
                      ),
                    ),
                  );
                },
              ),
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

  Future<bool?> _showDischargeConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Discharge'),
          content:
              const Text('Are you sure you want to discharge this patient?'),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Discharge canceled
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Confirm discharge
              child: const Text('Discharge'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _dischargePatient(Patient1 patient, WidgetRef ref) async {
    try {
      final admissionId = patient.admissionRecords.isNotEmpty
          ? patient.admissionRecords.first.id
          : ''; // Use the first admission record's ID

      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.dischargePatient(
        patientId: patient.patientId,
        admissionId: admissionId,
      );

      if (result['success']) {
        print(result);
        ref.refresh(assignedPatientsProvider.notifier).fetchAssignedPatients();
      } else {
        print("");
      }
    } catch (e) {
      print('Error discharging patient: $e');
    }
  }
}

class SelectAdmissionDialog extends StatelessWidget {
  final List<AdmissionRecord> admissionRecords;

  const SelectAdmissionDialog({
    Key? key,
    required this.admissionRecords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Admission Record'),
      content: SingleChildScrollView(
        child: Column(
          children: admissionRecords.map((admission) {
            return ListTile(
              title: Text('Admission Date: ${admission.admissionDate}'),
              subtitle: Text('Reason: ${admission.reasonForAdmission}'),
              onTap: () {
                Navigator.of(context).pop(admission.id);
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class AssignLabDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();

    return AlertDialog(
      title: const Text('Assign to Lab'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Lab Test Name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
          child: const Text('Assign'),
        ),
      ],
    );
  }
}
