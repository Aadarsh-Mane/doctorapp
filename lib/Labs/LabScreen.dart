// import 'dart:io';
// import 'package:doctorapp/providers/auth_providers.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class LabPatientsScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Get the current state (labPatients)
//     final labPatients = ref.watch(labPatientsProvider);

//     // Watch loading state as well
//     final isLoading = labPatients.isEmpty;

//     // Trigger data fetch if it's empty (this ensures data is fetched only once)
//     if (isLoading && ref.read(labPatientsProvider.notifier).state.isEmpty) {
//       ref.read(labPatientsProvider.notifier).fetchLabPatients();
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Lab Patients'),
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator()) // Show loading spinner
//           : ListView.builder(
//               itemCount: labPatients.length,
//               itemBuilder: (context, index) {
//                 final labPatient = labPatients[index];
//                 return ListTile(
//                   title: Text(labPatient.patient.name),
//                   subtitle:
//                       Text('Test: ${labPatient.labTestNameGivenByDoctor}'),
//                   trailing: IconButton(
//                     icon: Icon(Icons.upload_file),
//                     onPressed: () {
//                       // Navigate to the Upload Lab Report screen and pass patient details
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => UploadLabReportScreen(
//                             admissionId: labPatient.admissionId,
//                             patientId: labPatient.patient.id,
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

// class UploadLabReportScreen extends StatefulWidget {
//   final String admissionId;
//   final String patientId;

//   UploadLabReportScreen({required this.admissionId, required this.patientId});

//   @override
//   _UploadLabReportScreenState createState() => _UploadLabReportScreenState();
// }

// class _UploadLabReportScreenState extends State<UploadLabReportScreen> {
//   File? _selectedFile;
//   String? labTestName;
//   String? labType;

//   final ImagePicker _picker = ImagePicker();

//   // Function to pick an image from the gallery
//   Future<void> pickImageFromGallery() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       setState(() {
//         _selectedFile = File(image.path);
//       });
//     }
//   }

//   // Function to capture an image using the camera
//   Future<void> captureImageWithCamera() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.camera);
//     if (image != null) {
//       setState(() {
//         _selectedFile = File(image.path);
//       });
//     }
//   }

//   // Function to upload the image
//   Future<void> uploadReport() async {
//     if (_selectedFile == null || labTestName == null || labType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Please fill in all fields and select a file')),
//       );
//       return;
//     }

//     var request = http.MultipartRequest(
//         'POST', Uri.parse('${BASE_URL}/labs/upload-lab-report'));
//     request.fields['admissionId'] = widget.admissionId;
//     request.fields['patientId'] = widget.patientId;
//     request.fields['labTestName'] = labTestName!;
//     request.fields['labType'] = labType!;

//     // Attach the selected file
//     request.files
//         .add(await http.MultipartFile.fromPath('file', _selectedFile!.path));

//     try {
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Lab report uploaded successfully')));
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Failed to upload report')));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Upload Lab Report')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               decoration: InputDecoration(labelText: 'Lab Test Name'),
//               onChanged: (value) => labTestName = value,
//             ),
//             TextField(
//               decoration: InputDecoration(labelText: 'Lab Type'),
//               onChanged: (value) => labType = value,
//             ),
//             SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: pickImageFromGallery,
//                   child: Text(_selectedFile == null
//                       ? 'Pick Image from Gallery'
//                       : 'File Selected: ${_selectedFile!.path.split('/').last}'),
//                 ),
//                 ElevatedButton(
//                   onPressed: captureImageWithCamera,
//                   child: Text('Capture with Camera'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: uploadReport,
//               child: Text('Upload Report'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
