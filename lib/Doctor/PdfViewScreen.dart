// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// class PdfViewScreen extends StatelessWidget {
//   final String url;

//   const PdfViewScreen({Key? key, required this.url}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PDF Report'),
//       ),
//       body: FutureBuilder(
//         future: _downloadPdf(url),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             return PDFView(
//               filePath: snapshot.data as String,
//             );
//           } else if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else {
//             return const Center(child: Text('Error loading PDF.'));
//           }
//         },
//       ),
//     );
//   }

//   Future<String> _downloadPdf(String url) async {
//     // You could use packages like Dio or http to download the PDF file to the device and get the local file path.
//     // For simplicity, let's assume the URL directly links to the PDF
//     return url;
//   }
// }
