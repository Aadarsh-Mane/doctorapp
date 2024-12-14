import 'package:doctorapp/constants/Urls.dart';
import 'package:flutter/material.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart'; // For PDF document creation
import 'package:pdf/widgets.dart' as pw; // For PDF widget creation
import 'package:printing/printing.dart'; // For printing or viewing the PDF

class PatientDetailScreen4 extends StatefulWidget {
  final Patient1 patient;

  const PatientDetailScreen4({Key? key, required this.patient})
      : super(key: key);

  @override
  _PatientDetailScreen2State createState() => _PatientDetailScreen2State();
}

class _PatientDetailScreen2State extends State<PatientDetailScreen4> {
  Future<void> generatePdf(
      List<FollowUp> followUps, BuildContext context) async {
    final pdf = pw.Document();

    // Create the PDF structure
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Patient Follow-Up Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Follow-Ups:'),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  'Date',
                  'Notes',
                  'Temperature',
                  'oxygen',
                  'bloodPressure',
                  'four hr temperature'
                ],
                data: followUps
                    .map((followUp) => [
                          followUp.date,
                          followUp.notes,
                          followUp.temperature,
                          followUp.oxygenSaturation,
                          followUp.bloodPressure,
                          followUp.fourhrTemperature,
                          followUp.fourhrbloodPressure,
                          followUp.fourhrivFluid,
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    // Display the generated PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdf.save();
    });
  }

  Future<List<FollowUp>> _fetchFollowUps(String admissionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final url = Uri.parse(
        '${VERCEL_URL}/nurse/followups/$admissionId'); // API endpoint for fetching follow-ups
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => FollowUp.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load follow-ups');
      }
    } catch (e) {
      throw Exception('Error fetching follow-ups: $e');
    }
  }

  Future<void> _addFollowUp(String patientId, String admissionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Add controllers for new fields
    TextEditingController notesController = TextEditingController();
    TextEditingController observationsController = TextEditingController();
    TextEditingController temperatureController = TextEditingController();
    TextEditingController pulseController = TextEditingController();
    TextEditingController bloodPressureController = TextEditingController();
    TextEditingController oxygenSaturationController = TextEditingController();
    TextEditingController bloodSugarLevelController = TextEditingController();
    TextEditingController ivFluidController = TextEditingController();
    TextEditingController urineController = TextEditingController();
    TextEditingController nasogastricController = TextEditingController();
    TextEditingController rtFeedOralController = TextEditingController();
    TextEditingController cvpController = TextEditingController();
    TextEditingController fiO2Controller = TextEditingController();
    TextEditingController pipController = TextEditingController();
    TextEditingController peepController = TextEditingController();
    TextEditingController ieRatioController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width *
                0.9, // Set width to 90% of the screen
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height * 0.8, // Limit height
            ),
            child: SingleChildScrollView(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Heading
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            'Patient Follow-Up Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // Grouping the related fields
                        _buildSectionTitle('Vitals'),
                        _buildNumberInputField(
                            temperatureController, 'Temperature'),
                        _buildNumberInputField(pulseController, 'Pulse'),
                        _buildTextField(
                            bloodPressureController, 'Blood Pressure'),
                        _buildNumberInputField(
                            oxygenSaturationController, 'Oxygen Saturation'),
                        _buildNumberInputField(
                            bloodSugarLevelController, 'Blood Sugar Level'),

                        // Grouping observations and notes
                        _buildSectionTitle('Observations'),
                        _buildTextField(notesController, 'Notes'),
                        _buildTextField(observationsController, 'Observations'),

                        // IV fluid and Urine output
                        _buildSectionTitle('Other Information'),
                        _buildTextField(
                            ivFluidController, 'Intravenous Fluids'),
                        _buildTextField(urineController, 'Urinary Output'),

                        // Action Buttons
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                final body = {
                                  "patientId": patientId,
                                  "admissionId": admissionId,
                                  "notes": notesController.text,
                                  "observations": observationsController.text,
                                  "temperature": double.tryParse(
                                          temperatureController.text) ??
                                      0.0,
                                  "pulse":
                                      int.tryParse(pulseController.text) ?? 0,
                                  "bloodPressure": bloodPressureController.text,
                                  "oxygenSaturation": int.tryParse(
                                          oxygenSaturationController.text) ??
                                      0,
                                  "bloodSugarLevel": int.tryParse(
                                          bloodSugarLevelController.text) ??
                                      0,
                                  "ivFluid": ivFluidController.text,
                                  "urine": urineController.text,
                                };

                                final url = Uri.parse(
                                    '${VERCEL_URL}/nurse/addFollowUp');

                                try {
                                  final response = await http.post(
                                    url,
                                    headers: {
                                      'Content-Type': 'application/json',
                                      'Authorization': 'Bearer $token',
                                    },
                                    body: json.encode(body),
                                  );

                                  if (response.statusCode == 201) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Follow-up added successfully!')),
                                    );
                                    setState(() {}); // Refresh UI
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Failed to add follow-up!')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.greenAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

// Reusable section title builder
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

// Reusable text field builder function
  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.blueGrey[50], // Soft background color
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

// Reusable number input field builder
  Widget _buildNumberInputField(
      TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.blueGrey[50], // Soft background color
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patient.name} Details'),
        backgroundColor: Colors.teal,
        elevation: 5,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              setState(() {
                // Trigger a refresh of follow-ups
                _fetchFollowUps(widget.patient.admissionRecords.first.id);
              });
            },
          ),
          ElevatedButton(
            onPressed: () async {
              final followUps = await _fetchFollowUps(
                  widget.patient.admissionRecords.first.id);
              generatePdf(followUps, context);
            },
            child: const Text('Generate PDF'),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            // Trigger a refresh of follow-ups
            _fetchFollowUps(widget.patient.admissionRecords.first.id);
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.teal[100],
                        child: Icon(Icons.person, size: 30, color: Colors.teal),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 500),
                              child: Text('${widget.patient.name}',
                                  key: ValueKey(widget.patient.name),
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 8),
                            Text('Patient ID: ${widget.patient.patientId}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Age: ${widget.patient.age}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Gender: ${widget.patient.gender}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Contact: ${widget.patient.contact}',
                                style: const TextStyle(fontSize: 16)),
                            Text('Address: ${widget.patient.address}',
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Admission Records:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Column(
                children: widget.patient.admissionRecords.map((record) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reason: ${record.reasonForAdmission}',
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Date: ${record.admissionDate}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Symptoms: ${record.symptoms}',
                              style: const TextStyle(fontSize: 16)),
                          Text('Initial Diagnosis: ${record.initialDiagnosis}',
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          FutureBuilder<List<FollowUp>>(
                            future: _fetchFollowUps(record.id),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              var followUps = snapshot.data ?? [];
                              if (followUps.isEmpty) {
                                return const Text('No follow-ups available.',
                                    style: TextStyle(fontSize: 14));
                              }

                              final dateFormat =
                                  DateFormat('d/M/yyyy, HH:mm:ss');

                              followUps.sort((a, b) {
                                final dateA = dateFormat.parse(a.date);
                                final dateB = dateFormat.parse(b.date);
                                return dateB.compareTo(dateA); // Newest first
                              });

                              final latestFollowUp = followUps.first;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Latest Follow-Up:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  AnimatedOpacity(
                                    duration: const Duration(milliseconds: 500),
                                    opacity: 1.0,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Date: ${latestFollowUp.date}',
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          Text('Notes: ${latestFollowUp.notes}',
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          Text(
                                              'Temperature: ${latestFollowUp.temperature}',
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider(),
                                  const Text('All Follow-Ups:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  ...followUps.map((followUp) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0, horizontal: 8.0),
                                      child: AnimatedSize(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        child: _buildFollowUpTable(followUp),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.teal,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(15.0),
                          //     ),
                          //   ),
                          //   onPressed: () => _addFollowUp(
                          //       widget.patient.patientId, record.id),
                          //   child: const Text('Add Follow-Up'),
                          // ),
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.teal,
                          //     shape: RoundedRectangleBorder(
                          //       borderRadius: BorderRadius.circular(15.0),
                          //     ),
                          //   ),
                          //   onPressed: () => _addFollowUp(
                          //       widget.patient.patientId, record.id),
                          //   child: const Text('Add 4hr Follow-Up'),
                          // ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
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
                headingRowColor: MaterialStateProperty.all(Colors.black),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Type',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text('Values',
                        style: TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ],
                rows: [
                  // First row (Date) with custom color
                  DataRow(
                    color: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        // Custom color for the first row (Date)
                        return Colors.lightBlueAccent
                            .withOpacity(0.2); // Teal color for 'Date' row
                      },
                    ),
                    cells: [
                      DataCell(
                        Text(
                          '2-Hour Follow Up',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          followUp.date,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      DataCell(
                        Text(
                          '4-Hour Follow-Up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          followUp.date,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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
        DataCell(
          Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        DataCell(
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              value,
              key: ValueKey(value),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
