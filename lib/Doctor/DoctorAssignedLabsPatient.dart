import 'package:doctorapp/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignedLabsScreen extends ConsumerWidget {
  const AssignedLabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.refresh(assignedLabsProvider);
    final assignedLabs = ref.watch(assignedLabsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients Assigned to Labs'),
      ),
      body: assignedLabs.when(
        data: (assignments) => ListView.builder(
          itemCount: assignments.length,
          itemBuilder: (context, index) {
            final assignment = assignments[index];

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
                  // Display the reports for the patient
                  if (reports.isNotEmpty)
                    ...reports.map((report) {
                      return ListTile(
                        title: Text(report.labTestName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Uploaded At: ${report.uploadedAt}'),
                            Text('Lab Type: ${report.labType}'),
                            // Optionally show the report URL
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
                        onTap: () {
                          // Optionally, handle the report tap (e.g., show PDF or more details)
                        },
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  // Function to open the report URL
}
