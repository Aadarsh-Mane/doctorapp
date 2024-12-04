import 'package:doctorapp/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AssignedLabsScreen extends ConsumerWidget {
  const AssignedLabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedLabs = ref.watch(assignedLabsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients Assigned to Labs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the assignedLabsProvider when the user taps the refresh icon
              ref.refresh(assignedLabsProvider);
            },
          ),
        ],
      ),
      body: assignedLabs.when(
        data: (assignments) {
          return ListView.builder(
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final assignment = assignments[index];
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}
