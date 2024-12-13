import 'package:doctorapp/constants/Urls.dart';
import 'package:flutter/material.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PatientDetailScreen2 extends StatefulWidget {
  final Patient1 patient;

  const PatientDetailScreen2({Key? key, required this.patient})
      : super(key: key);

  @override
  _PatientDetailScreen2State createState() => _PatientDetailScreen2State();
}

class _PatientDetailScreen2State extends State<PatientDetailScreen2> {
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

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: const Text('Add Follow-Up', style: TextStyle(fontSize: 18)),
          content: SingleChildScrollView(
            child: Card(
              elevation: 8, // Shadow for the card
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
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                      _buildTextField(ivFluidController, 'Intravenous Fluids'),
                      _buildTextField(urineController, 'Urinary Output'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
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
                  "temperature":
                      double.tryParse(temperatureController.text) ?? 0.0,
                  "pulse": int.tryParse(pulseController.text) ?? 0,
                  "bloodPressure": bloodPressureController.text,
                  "oxygenSaturation":
                      int.tryParse(oxygenSaturationController.text) ?? 0,
                  "bloodSugarLevel":
                      int.tryParse(bloodSugarLevelController.text) ?? 0,
                  "ivFluid": ivFluidController.text,
                  "urine": urineController.text,
                };

                final url = Uri.parse('${VERCEL_URL}/nurse/addFollowUp');

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
                          content: Text('Follow-up added successfully!')),
                    );
                    setState(() {}); // Refresh UI
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add follow-up!')),
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
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
      ),
      body: SingleChildScrollView(
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
                                    fontSize: 22, fontWeight: FontWeight.bold)),
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

                            final dateFormat = DateFormat('d/M/yyyy, HH:mm:ss');

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
                                            style:
                                                const TextStyle(fontSize: 14)),
                                        Text('Notes: ${latestFollowUp.notes}',
                                            style:
                                                const TextStyle(fontSize: 14)),
                                        Text(
                                            'Temperature: ${latestFollowUp.temperature}',
                                            style:
                                                const TextStyle(fontSize: 14)),
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
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () =>
                              _addFollowUp(widget.patient.patientId, record.id),
                          child: const Text('Add Follow-Up'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                          ),
                          onPressed: () =>
                              _addFollowUp(widget.patient.patientId, record.id),
                          child: const Text('Add 4hr Follow-Up'),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
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
                headingRowColor:
                    MaterialStateProperty.all(Colors.teal.shade100),
                columns: const [
                  DataColumn(
                      label: Text(
                    '2-Hour',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple, // Text color for the title
                      fontStyle:
                          FontStyle.italic, // Adds italic style to the text
                    ),
                  )),
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
                        // Set a background color for the row
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
                            color:
                                Colors.deepPurple, // Text color for the title
                            fontStyle: FontStyle
                                .italic, // Adds italic style to the text
                          ),
                        ),
                      ),
                      DataCell(
                        Text(
                          followUp.date,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent, // Text color for the dash
                            fontWeight:
                                FontWeight.w500, // Slightly lighter weight
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

class FollowUp {
  final String date;
  final String notes;
  final String observations;
  final double temperature;
  final int pulse;
  final int respirationRate;
  final String bloodPressure;
  final int oxygenSaturation;
  final int bloodSugarLevel;
  final String otherVitals;
  final String ivFluid;
  final String nasogastric;
  final String rtFeedOral;
  final String totalIntake;
  final String cvp;
  final String urine;
  final String stool;
  final String rtAspirate;
  final String otherOutput;
  final String ventyMode;
  final int setRate;
  final double fiO2;
  final int pip;
  final String peepCpap;
  final String ieRatio;
  final String otherVentilator;
  final String fourhrpulse;
  final String fourhrbloodPressure;
  final String fourhroxygenSaturation;
  final String fourhrTemperature;
  final String fourhrbloodSugarLevel;
  final String fourhrotherVitals;
  final String fourhrurine;
  final String fourhrivFluid;

  FollowUp({
    required this.date,
    required this.notes,
    required this.observations,
    required this.temperature,
    required this.pulse,
    required this.respirationRate,
    required this.bloodPressure,
    required this.oxygenSaturation,
    required this.bloodSugarLevel,
    required this.otherVitals,
    required this.ivFluid,
    required this.nasogastric,
    required this.rtFeedOral,
    required this.totalIntake,
    required this.cvp,
    required this.urine,
    required this.stool,
    required this.rtAspirate,
    required this.otherOutput,
    required this.ventyMode,
    required this.setRate,
    required this.fiO2,
    required this.pip,
    required this.peepCpap,
    required this.ieRatio,
    required this.otherVentilator,
    required this.fourhrpulse,
    required this.fourhrbloodPressure,
    required this.fourhroxygenSaturation,
    required this.fourhrTemperature,
    required this.fourhrbloodSugarLevel,
    required this.fourhrotherVitals,
    required this.fourhrurine,
    required this.fourhrivFluid,
    // Add more fields as needed
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      date: json['date'] ?? '',
      notes: json['notes'] ?? '',
      observations: json['observations'] ?? '',
      temperature: json['temperature']?.toDouble() ?? 0.0,
      pulse: json['pulse'] ?? 0,
      respirationRate: json['respirationRate'] ?? 0,
      bloodPressure: json['bloodPressure'] ?? '',
      oxygenSaturation: json['oxygenSaturation'] ?? 0,
      bloodSugarLevel: json['bloodSugarLevel'] ?? 0,
      otherVitals: json['otherVitals'] ?? '',
      ivFluid: json['ivFluid'] ?? '',
      nasogastric: json['nasogastric'] ?? '',
      rtFeedOral: json['rtFeedOral'] ?? '',
      totalIntake: json['totalIntake'] ?? '',
      cvp: json['cvp'] ?? '',
      urine: json['urine'] ?? '',
      stool: json['stool'] ?? '',
      rtAspirate: json['rtAspirate'] ?? '',
      otherOutput: json['otherOutput'] ?? '',
      ventyMode: json['ventyMode'] ?? '',
      setRate: json['setRate'] ?? 0,
      fiO2: json['fiO2']?.toDouble() ?? 0.0,
      pip: json['pip'] ?? 0,
      peepCpap: json['peepCpap'] ?? '',
      ieRatio: json['ieRatio'] ?? '',
      otherVentilator: json['otherVentilator'] ?? '',
      fourhrpulse: json['fourhrpulse'] ?? '',
      fourhrbloodPressure: json['fourhrbloodPressure'] ?? '',
      fourhroxygenSaturation: json['fourhroxygenSaturation'] ?? '',
      fourhrTemperature: json['fourhrTemperature'] ?? '',
      fourhrbloodSugarLevel: json['fourhrbloodSugarLevel'] ?? '',
      fourhrotherVitals: json['fourhrotherVitals'] ?? '',
      fourhrurine: json['fourhrurine'] ?? '',
      fourhrivFluid: json['fourhrivFluid'] ?? '',
      // Add more fields as needed
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'notes': notes,
      'observations': observations,
      'temperature': temperature,
      'pulse': pulse,
      'respirationRate': respirationRate,
      'bloodPressure': bloodPressure,
      'oxygenSaturation': oxygenSaturation,
      'bloodSugarLevel': bloodSugarLevel,
      'otherVitals': otherVitals,
      'ivFluid': ivFluid,
      'nasogastric': nasogastric,
      'rtFeedOral': rtFeedOral,
      'totalIntake': totalIntake,
      'cvp': cvp,
      'urine': urine,
      'stool': stool,
      'rtAspirate': rtAspirate,
      'otherOutput': otherOutput,
      'ventyMode': ventyMode,
      'setRate': setRate,
      'fiO2': fiO2,
      'pip': pip,
      'peepCpap': peepCpap,
      'ieRatio': ieRatio,
      'otherVentilator': otherVentilator,
      'fourhrpulse': fourhrpulse,
      'fourhrbloodPressure': fourhrbloodPressure,
      'fourhroxygenSaturation': fourhroxygenSaturation,
      'fourhrTemperature': fourhrTemperature,
      'fourhrbloodSugarLevel': fourhrbloodSugarLevel,
      'fourhrotherVitals': fourhrotherVitals,
      'fourhrurine': fourhrurine,
      'fourhrivFluid': fourhrivFluid,
      // Add more fields as needed
    };
  }
}
