import 'package:doctorapp/Doctor/DoctorAssignedLabsPatient.dart';
import 'package:doctorapp/Doctor/DoctorPatientDetailScreen.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignedPatientsScreen extends ConsumerWidget {
  const AssignedPatientsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedPatients = ref.watch(assignedPatientsProvider);

    final authRepository = ref.read(authRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assigned Patients'),
        actions: [
          // IconButton to navigate to AssignedLabsScreen
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
            return ListTile(
              title: Text(patient.name),
              subtitle: Text('Age: ${patient.age}, Gender: ${patient.gender}'),
              trailing: IconButton(
                icon: const Icon(Icons.label),
                onPressed: () async {
                  // Select Admission ID first
                  final admissionId = await showDialog<String>(
                    context: context,
                    builder: (context) => SelectAdmissionDialog(
                      admissionRecords: patient.admissionRecords,
                    ),
                  );

                  if (admissionId != null) {
                    // Collect Lab Test Name
                    final labTestNameGivenByDoctor = await showDialog<String>(
                      context: context,
                      builder: (context) => AssignLabDialog(),
                    );

                    if (labTestNameGivenByDoctor != null &&
                        labTestNameGivenByDoctor.isNotEmpty) {
                      // Call API to assign patient to lab
                      final result = await authRepository.assignPatientToLab(
                        patientId: patient.id,
                        admissionId: admissionId,
                        labTestNameGivenByDoctor: labTestNameGivenByDoctor,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message']),
                          backgroundColor:
                              result['success'] ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
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
