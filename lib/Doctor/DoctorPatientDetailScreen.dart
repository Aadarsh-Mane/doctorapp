import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen4 extends StatelessWidget {
  final Patient1 patient;

  const PatientDetailScreen4({Key? key, required this.patient})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d/M/yyyy, HH:mm:ss');

    // Sort follow-ups by date, newest first
    patient.admissionRecords.forEach((record) {
      record.followUps.sort((a, b) {
        final dateA = dateFormat.parse(a.date);
        final dateB = dateFormat.parse(b.date);
        return dateB.compareTo(dateA); // Newest first
      });
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(patient.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Patient Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Name: ${patient.name}'),
            Text('Age: ${patient.age}'),
            Text('Gender: ${patient.gender}'),
            Text('Contact: ${patient.contact}'),
            Text('Address: ${patient.address}'),
            const SizedBox(height: 20),
            Text(
              'Admission Records (${patient.admissionRecords.length})',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...patient.admissionRecords.map(
              (record) => Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admission Date: ${record.admissionDate}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          'Reason for Admission: ${record.reasonForAdmission}'),
                      Text('Symptoms: ${record.symptoms}'),
                      Text('Initial Diagnosis: ${record.initialDiagnosis}'),
                      const SizedBox(height: 10),
                      Text(
                        'Reports (${record.reports.length}):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (record.reports.isNotEmpty)
                        ...record.reports.map((report) => Text('• $report'))
                      else
                        Text('No reports available'),
                      const SizedBox(height: 10),
                      Text(
                        'Follow-Ups (${record.followUps.length}):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (record.followUps.isNotEmpty)
                        ...record.followUps
                            .map((followUp) => _buildFollowUpTable(followUp))
                      else
                        Text('No follow-ups available'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpTable(FollowUp followUp) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Follow-Up Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AnimatedSize(
              duration: const Duration(milliseconds: 500),
              child: DataTable(
                columnSpacing: 20,
                dataRowHeight: 60,
                headingRowHeight: 40,
                border: TableBorder.all(color: Colors.grey.shade300),
                headingRowColor:
                    MaterialStateProperty.all(Colors.teal.shade100),
                columns: const [
                  DataColumn(
                    label: Text('Label', style: TextStyle(fontSize: 14)),
                  ),
                  DataColumn(
                    label: Text('Value', style: TextStyle(fontSize: 14)),
                  ),
                ],
                rows: [
                  _buildTableRow('Date', followUp.date),
                  _buildTableRow(
                      'Temperature', followUp.temperature.toString()),
                  _buildTableRow('Pulse', followUp.pulse.toString()),
                  _buildTableRow(
                      'Respiration Rate', followUp.respirationRate.toString()),
                  DataRow(
                    color: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return Colors.lightBlueAccent
                            .withOpacity(0.2); // Light blue row color
                      },
                    ),
                    cells: [
                      DataCell(Text(
                        '4-Hour Follow-Up',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontStyle: FontStyle.italic),
                      )),
                      DataCell(Text('')),
                    ],
                  ),
                  _buildTableRow(
                      '4-Hr Temperature', followUp.fourhrTemperature),
                  _buildTableRow(
                      'Blood Pressure', followUp.fourhrbloodPressure),
                  _buildTableRow('Sugar Level', followUp.fourhrbloodSugarLevel),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  DataRow _buildTableRow(String label, String value) {
    return DataRow(
      cells: [
        DataCell(Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        DataCell(AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(value,
              key: ValueKey(value), style: const TextStyle(fontSize: 14)),
        )),
      ],
    );
  }
}
