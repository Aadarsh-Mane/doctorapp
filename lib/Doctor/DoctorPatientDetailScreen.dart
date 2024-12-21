import 'package:doctorapp/Doctor/DoctorPatientHistoryScreen.dart';
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
  final TextEditingController _prescriptionController = TextEditingController();
  late Future<List<String>> _prescriptionsFuture;
  @override
  void initState() {
    super.initState();
    // Fetch initial prescriptions
    _prescriptionsFuture =
        _fetchPrescriptions(widget.patient.admissionRecords.first.id);
  }

  Future<void> _addPrescription(
      String patientId, String admissionId, String prescription) async {
    final url = Uri.parse('${VERCEL_URL}/doctors/addPresciption');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    final body = {
      "patientId": patientId,
      "admissionId": admissionId,
      "prescription": prescription,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );
      print(response.body);
      if (response.statusCode == 200) {
        // Prescription added successfully
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Prescription added successfully!')),
        );

        // Refresh the prescriptions
        setState(() {
          _prescriptionsFuture = _fetchPrescriptions(admissionId);
        });
      } else {
        throw Exception('Failed to add prescription: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<List<String>> _fetchPrescriptions(String admissionId) async {
    final url =
        Uri.parse('${VERCEL_URL}/doctors/getPrescriptions/$admissionId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');
    print("the admiison is ${admissionId}");
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      print(response.body);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<String>.from(data.map((item) => item.toString()));
      } else {
        throw Exception('Failed to fetch prescriptions');
      }
    } catch (e) {
      throw Exception('Error fetching prescriptions: $e');
    }
  }

  void _openAddPrescriptionDialog(String patientId, String admissionId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Prescription'),
          content: TextField(
            controller: _prescriptionController,
            decoration: InputDecoration(
              labelText: 'Enter Prescription',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final prescription = _prescriptionController.text;
                if (prescription.isNotEmpty) {
                  // Add current date and time
                  final now = DateTime.now();
                  final formattedDateTime =
                      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                  final prescriptionWithDateTime =
                      '$prescription $formattedDateTime';

                  await _addPrescription(
                      patientId, admissionId, prescriptionWithDateTime);

                  _prescriptionController.clear();
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Prescription cannot be empty!')),
                  );
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> generatePdf(
      List<FollowUp> followUps, BuildContext context) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Tambe Hospital',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.teal,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Patient Follow-Up Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Divider(thickness: 1.5, color: PdfColors.teal),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Patient Name: ${widget.patient.name}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Report Generated: ${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
                pw.SizedBox(height: 20),
              ],
            ),

            // Follow-Ups Section (2-hour fields)
            if (followUps.isNotEmpty)
              pw.Column(
                children: followUps.map((followUp) {
                  return pw.Container(
                    margin: pw.EdgeInsets.only(bottom: 15),
                    padding: pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          '2hr Fields - Date: ${followUp.date}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                            color: PdfColors.teal,
                          ),
                        ),
                        pw.Divider(),

                        // Table for 2-hour Fields
                        pw.Table(
                          columnWidths: {
                            0: pw.FlexColumnWidth(1),
                            1: pw.FlexColumnWidth(2),
                          },
                          border: pw.TableBorder(
                            horizontalInside: pw.BorderSide(
                              color: PdfColors.grey300,
                              width: 0.5,
                            ),
                          ),
                          children: [
                            pw.TableRow(children: [
                              pw.Text('Notes:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(followUp.notes),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Temperature:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.temperature}°C'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Oxygen Saturation:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.oxygenSaturation}%'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Peep/Cap:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.peepCpap}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Ie Ratio:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fiO2}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Blood Pressure:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.bloodPressure}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Oxygen Saturation:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.oxygenSaturation} %'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Blood Sugar Level:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.bloodSugarLevel} mg/dL'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Other Vitals:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.otherVitals}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('IV Fluid:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.ivFluid} ml'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Nasogastric:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.nasogastric}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('RT Feed/Oral:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.rtFeedOral}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Total Intake:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.totalIntake} ml'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('CVP:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.cvp} mmHg'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Urine:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.urine} ml'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Stool:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.stool}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('RT Aspirate:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.rtAspirate}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Other Output:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.otherOutput}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Ventilator Mode:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.ventyMode}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Set Rate:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.setRate} bpm'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('FiO2:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fiO2} %'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('PIP:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.pip} cmH2O'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('PEEP/CPAP:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.peepCpap} cmH2O'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('IE Ratio:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.ieRatio}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('Other Ventilator Info:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.otherVentilator}'),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            // Start new page for 4-hour Fields
            pw.NewPage(),

            // 4-hour Fields Section
            if (followUps.isNotEmpty)
              pw.Column(
                children: followUps.map((followUp) {
                  return pw.Container(
                    margin: pw.EdgeInsets.only(bottom: 15),
                    padding: pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        // Date for 4-hour fields
                        pw.Text(
                          '4hr Fields - Date: ${followUp.date}',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 14,
                            color: PdfColors.teal,
                          ),
                        ),
                        pw.Divider(),

                        // Table for 4-hour Fields
                        pw.Table(
                          columnWidths: {
                            0: pw.FlexColumnWidth(1),
                            1: pw.FlexColumnWidth(2),
                          },
                          border: pw.TableBorder(
                            horizontalInside: pw.BorderSide(
                              color: PdfColors.grey300,
                              width: 0.5,
                            ),
                          ),
                          children: [
                            pw.TableRow(children: [
                              pw.Text('4hr Temperature:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhrTemperature}°C'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr Blood Pressure:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhrbloodPressure}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr IV Fluid:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhrivFluid} ml'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr Pulse:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhrpulse} bpm'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr Oxygen Saturation:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhroxygenSaturation} %'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr Blood Sugar Level:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text(
                                  '${followUp.fourhrbloodSugarLevel} mg/dL'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr Other Vitals:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhrotherVitals}'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr Urine:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhrurine} ml'),
                            ]),
                            pw.TableRow(children: [
                              pw.Text('4hr IV Fluid:',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                              pw.Text('${followUp.fourhrivFluid} ml'),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              pw.Text(
                'No follow-up records available.',
                style: pw.TextStyle(fontSize: 14, color: PdfColors.red),
              ),

            // Footer Section
            pw.SizedBox(height: 40),
            pw.Divider(thickness: 1),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'Generated on ${DateFormat('dd/MM/yyyy, HH:mm').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            ),
          ];
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
                            ElevatedButton.icon(
                              onPressed: () async {
                                final followUps = await _fetchFollowUps(
                                  widget.patient.admissionRecords.first.id,
                                );
                                generatePdf(followUps, context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                              ),
                              icon: const Icon(
                                Icons.picture_as_pdf,
                                size: 18,
                              ),
                              label: const Text(
                                'Generate PDF',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ),
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
                          // ElevatedButton(
                          //   onPressed: () => _openAddPrescriptionDialog(
                          //       widget.patient.patientId, record.id),
                          //   child: Text('Add Prescription'),
                          // ),
                          FutureBuilder<List<String>>(
                            future: _prescriptionsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'Error loading prescriptions: ${snapshot.error}',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                );
                              }

                              final prescriptions = snapshot.data ?? [];
                              if (prescriptions.isEmpty) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    'No prescriptions available.',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: prescriptions.map((prescription) {
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    elevation: 2,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.medical_services_outlined,
                                        color: Colors.teal[600],
                                        size: 28,
                                      ),
                                      title: Text(
                                        'Consultant: $prescription',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

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
                                return const Text(
                                  'No follow-ups available.',
                                  style: TextStyle(fontSize: 14),
                                );
                              }

                              final dateFormat =
                                  DateFormat('d/M/yyyy, HH:mm:ss');

                              // Sort follow-ups by date (newest first)
                              followUps.sort((a, b) {
                                final dateA = dateFormat.parse(a.date);
                                final dateB = dateFormat.parse(b.date);
                                return dateB.compareTo(dateA);
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
                                  const Text(
                                    'Follow-Ups:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...followUps.map((followUp) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 4.0),
                                      child: Align(
                                        alignment: Alignment
                                            .center, // Center the dropdown
                                        child: Container(
                                          width:
                                              400, // Adjust width to make it smaller for desktop
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                            color: Colors
                                                .white, // Background color for dropdown
                                          ),
                                          child: ExpansionTile(
                                            title: Text(
                                              'Date: ${followUp.date}',
                                              style:
                                                  const TextStyle(fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              'Time: ${followUp.date.split(',').last.trim()}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey),
                                            ),
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0),
                                                child: _buildFollowUpTable(
                                                    followUp),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PatientHistoryDetailsScreen(
                                          patientId: widget.patient.patientId),
                                ),
                              );
                            },
                            child: Text('Cancel'),
                          )
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
      floatingActionButton: Container(
        margin: const EdgeInsets.only(
            bottom: 20), // Moves the button up by 20 pixels
        child: FloatingActionButton(
          onPressed: () {
            // Handle the action for adding a prescription
            _openAddPrescriptionDialog(
              widget.patient.patientId,
              widget.patient.admissionRecords.first.id,
            );
          },
          backgroundColor: Colors.teal,
          elevation: 8, // Adds elevation to the button
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
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
                _buildTableRow('Temperature', followUp.temperature.toString()),
                _buildTableRow('Pulse', followUp.pulse.toString()),
                _buildTableRow(
                    'Respiration Rate', followUp.respirationRate.toString()),
                _buildTableRow(
                    'Respiration Rate', followUp.respirationRate.toString()),
                _buildTableRow('Temperature', followUp.temperature.toString()),
                _buildTableRow('Pulse', followUp.pulse.toString()),
                _buildTableRow(
                    'Respiration Rate', followUp.respirationRate.toString()),
                _buildTableRow('Blood Pressure', followUp.bloodPressure),
                _buildTableRow(
                    'Oxygen Saturation', followUp.oxygenSaturation.toString()),
                _buildTableRow(
                    'Blood Sugar Level', followUp.bloodSugarLevel.toString()),
                _buildTableRow('Other Vitals', followUp.otherVitals),
                _buildTableRow('IV Fluid', followUp.ivFluid),
                _buildTableRow('Nasogastric', followUp.nasogastric),
                _buildTableRow('RT Feed Oral', followUp.rtFeedOral),
                _buildTableRow('Total Intake', followUp.totalIntake),
                _buildTableRow('CVP', followUp.cvp),
                _buildTableRow('Urine Output', followUp.urine),
                _buildTableRow('Stool', followUp.stool),
                _buildTableRow('RT Aspirate', followUp.rtAspirate),
                _buildTableRow('Other Output', followUp.otherOutput),
                _buildTableRow('Ventilator Mode', followUp.ventyMode),
                _buildTableRow('Set Rate', followUp.setRate.toString()),
                _buildTableRow('FiO2', followUp.fiO2.toString()),
                _buildTableRow('PIP', followUp.pip.toString()),
                _buildTableRow('PEEP/CPAP', followUp.peepCpap),
                _buildTableRow('IE Ratio', followUp.ieRatio),
                _buildTableRow('Other Ventilator', followUp.otherVentilator),
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
                _buildTableRow('4-Hr Temperature', followUp.fourhrTemperature),
                _buildTableRow('Blood Pressure', followUp.fourhrbloodPressure),
                _buildTableRow('Sugar Level', followUp.fourhrbloodSugarLevel),
                _buildTableRow('4-Hr Temperature', followUp.fourhrTemperature),
                _buildTableRow('Blood Pressure', followUp.fourhrbloodPressure),
                _buildTableRow('Sugar Level', followUp.fourhrbloodSugarLevel),
                _buildTableRow('4-Hr Pulse', followUp.fourhrpulse),
                _buildTableRow(
                    'Oxygen Saturation', followUp.fourhroxygenSaturation),
                _buildTableRow('4-Hr Temperature', followUp.fourhrTemperature),
                _buildTableRow('Blood Pressure', followUp.fourhrbloodPressure),
                _buildTableRow('Sugar Level', followUp.fourhrbloodSugarLevel),
                _buildTableRow('Other Vitals', followUp.fourhrotherVitals),
                _buildTableRow('IV Fluid', followUp.fourhrivFluid),
                _buildTableRow('Urine Output', followUp.fourhrurine),
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
