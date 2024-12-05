import 'package:doctorapp/models/getLabsPatient.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/stateprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final assignedLabsProvider =
    StateNotifierProvider<AssignedLabsNotifier, List<AssignedLab>>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AssignedLabsNotifier(authRepository);
});

class AssignedLabsScreen extends ConsumerWidget {
  const AssignedLabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the assigned labs data
    final assignedLabs = ref.watch(assignedLabsProvider);

    // Trigger a refresh of assigned labs when the screen is first built
    Future.delayed(Duration.zero, () {
      ref.read(assignedLabsProvider.notifier).fetchAssignedLabs();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients Assigned to Labs'),
      ),
      body: assignedLabs.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while data is fetched
          : ListView.builder(
              itemCount: assignedLabs.length,
              itemBuilder: (context, index) {
                final assignment = assignedLabs[index];

                // Collect all reports for the patient
                final reports = assignment.reports;

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(assignment.patient.name),
                    subtitle: Text(
                      'Age: ${assignment.patient.age}, Gender: ${assignment.patient.gender}\n'
                      'Assigned by: ${assignment.doctor.doctorName}\n'
                      'Contact: ${assignment.patient.contact}',
                    ),
                    children: [
                      if (reports.isNotEmpty)
                        ...reports.map((report) {
                          return ListTile(
                            title: Text(report.labTestName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Uploaded At: ${report.uploadedAt}'),
                                Text('Lab Type: ${report.labType}'),
                                Text('Report URL:'),
                                InkWell(
                                  onTap: () {
                                    // Optionally, open the report URL
                                  },
                                  child: Text(
                                    report.reportUrl,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      if (reports.isEmpty)
                        const ListTile(
                          title: Text('No reports available.'),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
