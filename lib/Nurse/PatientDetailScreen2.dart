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
  late Future<List<String>> _prescriptionsFuture;
  @override
  void initState() {
    super.initState();
    // Fetch initial prescriptions
    _prescriptionsFuture =
        _fetchPrescriptions(widget.patient.admissionRecords.first.id);
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
    // Create controllers for each field

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
                        _buildTextField(
                            nasogastricController, 'Nasogastric Tube'),
                        _buildNumberInputField(
                            rtFeedOralController, 'RT Feed Oral'),
                        _buildNumberInputField(cvpController, 'CVP'),
                        _buildNumberInputField(fiO2Controller, 'FiO2'),
                        _buildNumberInputField(pipController, 'PIP'),
                        _buildNumberInputField(peepController, 'PEEP'),
                        _buildNumberInputField(ieRatioController, 'IE Ratio'),

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
                                  "nasogastric": nasogastricController.text,
                                  "rtFeedOral": rtFeedOralController.text,
                                  "cvp": cvpController.text,
                                  "fiO2": fiO2Controller.text,
                                  "pip": pipController.text,
                                  "peep": peepController.text,
                                  "ieRatio": ieRatioController.text,
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

  Future<void> _add4FollowUp(String patientId, String admissionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('auth_token');

    // Add controllers for new fields
    TextEditingController notesController = TextEditingController();
    TextEditingController observationsController = TextEditingController();
    // Create controllers for each field
    TextEditingController fourHrPulseController = TextEditingController();
    TextEditingController fourHrBloodPressureController =
        TextEditingController();
    TextEditingController fourHrOxygenSaturationController =
        TextEditingController();
    TextEditingController fourHrTemperatureController = TextEditingController();
    TextEditingController fourHrBloodSugarLevelController =
        TextEditingController();
    TextEditingController fourHrOtherVitalsController = TextEditingController();
    TextEditingController fourHrIvFluidController = TextEditingController();
    TextEditingController fourHrUrineController = TextEditingController();

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

                        // Grouping observations and notes
                        _buildSectionTitle('Observations'),
                        _buildTextField(notesController, 'Notes'),
                        _buildTextField(observationsController, 'Observations'),

                        // IV fluid and Urine output
                        _buildSectionTitle('Other Information'),

                        _buildNumberInputField(
                            fourHrPulseController, '4hr Pulse'),
                        _buildNumberInputField(fourHrBloodPressureController,
                            '4hr Blood Pressure'),
                        _buildNumberInputField(fourHrOxygenSaturationController,
                            '4hr Oxygen Saturation'),
                        _buildNumberInputField(
                            fourHrTemperatureController, '4hr Temperature'),
                        _buildNumberInputField(fourHrBloodSugarLevelController,
                            '4hr Blood Sugar Level'),
                        _buildTextField(
                            fourHrOtherVitalsController, '4hr Other Vitals'),
                        _buildTextField(
                            fourHrIvFluidController, '4hr IV Fluid'),
                        _buildNumberInputField(
                            fourHrUrineController, '4hr Urine'),
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
                                  "fourHrPulse": fourHrPulseController.text,
                                  "fourHrBloodPressure":
                                      fourHrBloodPressureController.text,
                                  "fourHrOxygenSaturation":
                                      fourHrOxygenSaturationController.text,
                                  "fourHrTemperature":
                                      fourHrTemperatureController.text,
                                  "fourHrBloodSugarLevel":
                                      fourHrBloodSugarLevelController.text,
                                  "fourHrOtherVitals":
                                      fourHrOtherVitalsController.text,
                                  "fourHrIvFluid": fourHrIvFluidController.text,
                                  "fourHrUrine": fourHrUrineController.text,
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
                _prescriptionsFuture = _fetchPrescriptions(
                    widget.patient.admissionRecords.first.id);
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
            _fetchPrescriptions(widget.patient.admissionRecords.first.id);
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
                                  return Container(
                                    foregroundDecoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
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
                          //   onPressed: () => _add4FollowUp(
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
      floatingActionButton: Stack(
        children: <Widget>[
          // First Floating Action Button with Label
          Positioned(
            bottom: 10, // Moves the button up by 20 pixels
            right: 20, // Adjusts the button's position from the right
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Handle the action for adding a prescription
                    _addFollowUp(
                      widget.patient.patientId,
                      widget.patient.admissionRecords.first.id,
                    );
                  },
                  backgroundColor: Colors.teal,
                  elevation: 10, // Increased elevation for better shadow effect
                  child: const Icon(Icons.add,
                      color: Colors.white, size: 30), // Larger icon
                ),
                const SizedBox(
                    height: 10), // Increased space between button and label
                const Text(
                  '2hr Follow-Up',
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize:
                        14, // Slightly bigger font size for better readability
                    fontWeight: FontWeight.bold, // Bold label text for emphasis
                  ),
                ),
              ],
            ),
          ),
          // Second Floating Action Button with Label
          Positioned(
            bottom: 100, // Moves the second button further up
            right: 20, // Adjusts the button's position from the right
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Handle the action for t
                    //he second button
                    _add4FollowUp(
                      widget.patient.patientId,
                      widget.patient.admissionRecords.first.id,
                    );
                    print("Second button clicked");
                  },
                  backgroundColor: Colors.black, // Color of the second button
                  elevation: 10, // Increased elevation for better shadow effect
                  child: const Icon(Icons.edit,
                      color: Colors.cyan, size: 30), // Larger icon
                ),
                const SizedBox(
                    height: 8), // Increased space between button and label
                const Text(
                  '4 hr Follow-Up',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        14, // Slightly bigger font size for better readability
                    fontWeight: FontWeight.bold, // Bold label text for emphasis
                  ),
                ),
              ],
            ),
          ),
        ],
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
                    label: Text('Values ',
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
                  _buildTableRow(
                      'Temperature', followUp.temperature.toString()),
                  _buildTableRow('Pulse', followUp.pulse.toString()),
                  _buildTableRow(
                      'Respiration Rate', followUp.respirationRate.toString()),
                  _buildTableRow('Blood Pressure', followUp.bloodPressure),
                  _buildTableRow('Oxygen Saturation',
                      followUp.oxygenSaturation.toString()),
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
                  _buildTableRow(
                      '4-Hr Temperature', followUp.fourhrTemperature),
                  _buildTableRow(
                      'Blood Pressure', followUp.fourhrbloodPressure),
                  _buildTableRow('Sugar Level', followUp.fourhrbloodSugarLevel),
                  _buildTableRow('4-Hr Pulse', followUp.fourhrpulse),
                  _buildTableRow(
                      'Oxygen Saturation', followUp.fourhroxygenSaturation),
                  _buildTableRow(
                      '4-Hr Temperature', followUp.fourhrTemperature),
                  _buildTableRow(
                      'Blood Pressure', followUp.fourhrbloodPressure),
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
