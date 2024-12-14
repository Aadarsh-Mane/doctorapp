import 'package:doctorapp/models/getLabsPatient.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/stateprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final assignedLabsProvider =
    StateNotifierProvider<AssignedLabsNotifier, List<AssignedLab>>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AssignedLabsNotifier(authRepository);
});

class AssignedLabsScreen extends ConsumerWidget {
  const AssignedLabsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignedLabs = ref.watch(assignedLabsProvider);

    Future.delayed(Duration.zero, () {
      ref.read(assignedLabsProvider.notifier).fetchAssignedLabs();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Assigned Labs',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: assignedLabs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assignedLabs.length,
              itemBuilder: (context, index) {
                final assignment = assignedLabs[index];
                final reports = assignment.reports;

                return Card(
                  margin: const EdgeInsets.all(10.0),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        tileColor: Colors.deepPurple[50],
                        title: Text(
                          assignment.patient.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        subtitle: Text(
                          'Age: ${assignment.patient.age}, Gender: ${assignment.patient.gender}\n'
                          'Assigned by: Dr. ${assignment.doctor.doctorName}\n'
                          'Contact: ${assignment.patient.contact}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        trailing: Icon(
                          Icons.assignment_outlined,
                          color: Colors.deepPurple,
                        ),
                        onTap: () {
                          // Navigate to the LabReportsScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LabReportsScreen(
                                patientName: assignment.patient.name,
                                reports: reports,
                              ),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      // ExpansionTile(
                      //   title: Text(
                      //     'Lab Reports (${reports.length})',
                      //     style: TextStyle(fontSize: 16, color: Colors.black87),
                      //   ),
                      //   children: [
                      //     if (reports.isNotEmpty)
                      //       ...reports.map((report) {
                      //         return Padding(
                      //           padding: const EdgeInsets.symmetric(
                      //               vertical: 8.0, horizontal: 16.0),
                      //           child: Card(
                      //             color: Colors.deepPurple[50],
                      //             shape: RoundedRectangleBorder(
                      //               borderRadius: BorderRadius.circular(12),
                      //             ),
                      //             child: ListTile(
                      //               contentPadding: const EdgeInsets.all(12.0),
                      //               title: Text(
                      //                 report.labTestName,
                      //                 style: TextStyle(
                      //                   fontSize: 18,
                      //                   fontWeight: FontWeight.bold,
                      //                   color: Colors.deepPurple,
                      //                 ),
                      //               ),
                      //               subtitle: Column(
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     'Uploaded At: ${report.uploadedAt}',
                      //                     style: TextStyle(
                      //                         color: Colors.grey[700]),
                      //                   ),
                      //                   Text(
                      //                     'Lab Type: ${report.labType}',
                      //                     style: TextStyle(
                      //                         color: Colors.grey[700]),
                      //                   ),
                      //                   const SizedBox(height: 8.0),
                      //                   Text(
                      //                     'Report URL:',
                      //                     style: TextStyle(
                      //                         color: Colors.black87,
                      //                         fontWeight: FontWeight.bold),
                      //                   ),
                      //                   GestureDetector(
                      //                     onTap: () async {
                      //                       final Uri url =
                      //                           Uri.parse(report.reportUrl);
                      //                       if (await canLaunchUrl(url)) {
                      //                         await launchUrl(url,
                      //                             mode: LaunchMode
                      //                                 .externalApplication);
                      //                       } else {
                      //                         ScaffoldMessenger.of(context)
                      //                             .showSnackBar(
                      //                           SnackBar(
                      //                               content: Text(
                      //                                   'Could not open the report URL')),
                      //                         );
                      //                       }
                      //                     },
                      //                     child: Text(
                      //                       report.reportUrl,
                      //                       style: TextStyle(
                      //                         color: Colors.blue,
                      //                         decoration:
                      //                             TextDecoration.underline,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ),
                      //         );
                      //       }).toList(),
                      //     if (reports.isEmpty)
                      //       const ListTile(
                      //         title: Text('No reports available.',
                      //             style:
                      //                 TextStyle(fontStyle: FontStyle.italic)),
                      //       ),
                      //   ],
                      // ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class LabReportsScreen extends StatelessWidget {
  final String patientName;
  final List<LabReport> reports;

  const LabReportsScreen({
    Key? key,
    required this.patientName,
    required this.reports,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('$patientName Lab Reports'),
      ),
      body: reports.isEmpty
          ? const Center(child: Text('No reports available.'))
          : ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    color: Colors.deepPurple[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12.0),
                      title: Text(
                        report.labTestName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uploaded At: ${report.uploadedAt}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            'Lab Type: ${report.labType}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            'Report URL:',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final Uri url = Uri.parse(report.reportUrl);
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Could not open the report URL')),
                                );
                              }
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
                    ),
                  ),
                );
              },
            ),
    );
  }
}
