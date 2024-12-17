import 'package:doctorapp/Check.dart';
import 'package:doctorapp/Doctor/DoctorAssignedLabsPatient.dart';
import 'package:doctorapp/Doctor/DoctorPatientDetailScreen.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

final assignedPatientsProvider =
    StateNotifierProvider<AssignedPatientsNotifier, AsyncValue<List<Patient1>>>(
  (ref) {
    final authRepository = ref.read(authRepositoryProvider);
    final notifier = AssignedPatientsNotifier(authRepository);
    notifier.fetchAssignedPatients();
    return notifier;
  },
);

class AssignedPatientsScreen extends ConsumerStatefulWidget {
  const AssignedPatientsScreen({Key? key}) : super(key: key);

  @override
  _AssignedPatientsScreenState createState() => _AssignedPatientsScreenState();
}

class _AssignedPatientsScreenState
    extends ConsumerState<AssignedPatientsScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    // Initial manual refresh
    ref.refresh(assignedPatientsProvider.notifier).fetchAssignedPatients();
    // Set up the timer to refresh every 1 minute (60 seconds)
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.refresh(assignedPatientsProvider.notifier).fetchAssignedPatients();
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the screen is disposed to avoid memory leaks
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.refresh(assignedPatientsProvider.notifier).fetchAssignedPatients();
  }

  @override
  @override
  Widget build(BuildContext context) {
    final assignedPatients = ref.watch(assignedPatientsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text('Assigned Patients',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref
                  .refresh(assignedPatientsProvider.notifier)
                  .fetchAssignedPatients();
            },
          ),
          IconButton(
            icon: const Icon(Icons.assignment, color: Colors.white),
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
            final admissionStatus = patient.admissionRecords.isNotEmpty
                ? patient.admissionRecords.first.status
                : 'Pending';

            // Set status color based on the admission status
            Color statusColor =
                admissionStatus == 'admitted' ? Colors.green : Colors.red;

            return Dismissible(
              key: Key(patient.id),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) async {
                bool? shouldDischarge =
                    await _showDischargeConfirmationDialog(context);

                if (shouldDischarge == true) {
                  await _dischargePatient(patient, ref);
                  ref
                      .read(assignedPatientsProvider.notifier)
                      .removePatient(patient);
                } else {
                  ref
                      .refresh(assignedPatientsProvider.notifier)
                      .fetchAssignedPatients();
                }
              },
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red, Colors.deepOrange],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              child: Card(
                elevation: 4.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      patient.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                  title: Text(
                    patient.name,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Age: ${patient.age}, Gender: ${patient.gender}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 5),
                      // Display status with color changes based on status
                      Text(
                        'Status: $admissionStatus',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:
                              statusColor, // Apply the color based on the status
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.assignment_late,
                            color: Colors.deepPurple),
                        onPressed: () async {
                          await _handleAssignLab(context, patient, ref);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_add,
                            color: Colors.deepPurple),
                        onPressed: () async {
                          await _admitPatient(patient, ref, context);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            PatientDetailScreen4(patient: patient),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error', style: TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Future<void> _admitPatient(
      Patient1 patient, WidgetRef ref, BuildContext context) async {
    try {
      // Assuming the first admission record's ID is used as the admissionId
      if (patient.admissionRecords.isEmpty) {
        throw Exception('No admission records found for this patient.');
      }

      final admissionId = patient.admissionRecords.first
          .id; // Adjust logic if not using the first record

      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.admitPatient1(
        admissionId: admissionId,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Unknown error occurred.'),
          backgroundColor:
              (result['success'] as bool? ?? false) ? Colors.green : Colors.red,
        ),
      );
      ;

      ref.refresh(assignedPatientsProvider.notifier).fetchAssignedPatients();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to admit patient:'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool?> _showDischargeConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Discharge',
              style: TextStyle(color: Colors.deepPurple)),
          content: const Text(
              'Are you sure you want to discharge this patient?',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discharge',
                  style: TextStyle(color: Colors.deepPurple)),
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
          : '';
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.dischargePatient(
        patientId: patient.patientId,
        admissionId: admissionId,
      );
      print("the admission id is ${admissionId}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Unknown error occurred.'),
          backgroundColor:
              (result['success'] as bool? ?? false) ? Colors.green : Colors.red,
        ),
      );
      ;

      ref.refresh(assignedPatientsProvider.notifier).fetchAssignedPatients();
    } catch (e) {
      print('Error discharging patient: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error discharging patient: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleAssignLab(
      BuildContext context, Patient1 patient, WidgetRef ref) async {
    final authRepository = ref.read(authRepositoryProvider);
    final admissionId = await showDialog<String>(
      context: context,
      builder: (context) => SelectAdmissionDialog(
        admissionRecords: patient.admissionRecords,
      ),
    );

    if (admissionId == null) return;

    final labTestNameGivenByDoctor = await showDialog<String>(
      context: context,
      builder: (context) => AssignLabDialog(),
    );

    if (labTestNameGivenByDoctor == null || labTestNameGivenByDoctor.isEmpty) {
      return;
    }

    try {
      final result = await authRepository.assignPatientToLab(
        patientId: patient.id,
        admissionId: admissionId,
        labTestNameGivenByDoctor: labTestNameGivenByDoctor,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );

      ref.refresh(assignedPatientsProvider.notifier).fetchAssignedPatients();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to assign lab: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
      title: const Text('Select Admission Record',
          style: TextStyle(color: Colors.deepPurple)),
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
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
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
      title: const Text('Assign to Lab',
          style: TextStyle(color: Colors.deepPurple)),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Lab Test Name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(controller.text);
          },
          child:
              const Text('Assign', style: TextStyle(color: Colors.deepPurple)),
        ),
      ],
    );
  }
}
