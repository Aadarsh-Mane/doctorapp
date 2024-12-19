import 'package:doctorapp/models/getPatientHistoryModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart'; // For PDF document creation
import 'package:pdf/widgets.dart' as pw; // For PDF widget creation
import 'package:printing/printing.dart'; // F

// Fetch Patient History Function
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';

// Fetch Patient History Function
Future<PatientHistory> fetchPatientHistory(String patientId) async {
  final response = await http
      .get(Uri.parse('http://192.168.0.103:3000/patientHistory/$patientId'));

  if (response.statusCode == 200) {
    return PatientHistory.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load patient history');
  }
}

// Define a Riverpod Provider for fetching the patient history
final patientHistoryProvider =
    FutureProvider.family<PatientHistory, String>((ref, patientId) {
  return fetchPatientHistory(patientId);
});

// Main Widget
// Main Widget
class PatientHistoryDetailsScreen extends ConsumerWidget {
  final String patientId;

  const PatientHistoryDetailsScreen({Key? key, required this.patientId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientHistoryAsync = ref.watch(patientHistoryProvider(patientId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient History'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: patientHistoryAsync.when(
          data: (history) => _buildPlainDataView(context, history),
          loading: () =>
              const Center(child: CircularProgressIndicator.adaptive()),
          error: (error, stack) => Center(
            child: Text(
              'Error: ${error.toString()}',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlainDataView(BuildContext context, PatientHistory history) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildKeyValuePairs(history.toJson()),
          if (history.history != null && history.history!.isNotEmpty) ...[
            const SizedBox(height: 16), // Spacer between sections
            for (var record in history.history!)
              _buildKeyValuePairs(record.toJson()),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: () => _generatePDF(context, history),
            child: const Text('Generate Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValuePairs(Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: data.entries.map((entry) {
          return Text(
            '${entry.key}: ${_parseValue(entry.value)}',
            style: const TextStyle(fontSize: 16),
          );
        }).toList(),
      ),
    );
  }

  String _parseValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    } else {
      return value?.toString() ?? 'N/A';
    }
  }

  // Generate PDF
  Future<void> _generatePDF(
      BuildContext context, PatientHistory history) async {
    final pdf = pw.Document();

    // Add the content to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text(
                'Patient History Report',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              // Use spread operator here to directly add widgets
              ..._buildPDFContent(history),
            ],
          );
        },
      ),
    );

    // Printing the PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdf.save();
    });
  }

// Build PDF content based on the history
  List<pw.Widget> _buildPDFContent(PatientHistory history) {
    List<pw.Widget> content = [];

    content.add(pw.Text('Patient Info',
        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)));
    content.add(pw.SizedBox(height: 10));
    content.addAll(_convertMapToPDFWidgets(history.toJson()));

    if (history.history != null && history.history!.isNotEmpty) {
      content.add(pw.SizedBox(height: 20));
      content.add(pw.Text('Admission Records',
          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)));
      content.add(pw.SizedBox(height: 10));
      for (var record in history.history!) {
        content.addAll(_convertMapToPDFWidgets(record.toJson()));
        content.add(pw.SizedBox(height: 10));
      }
    }

    return content;
  }

// Convert map entries to PDF widgets
  List<pw.Widget> _convertMapToPDFWidgets(Map<String, dynamic> data) {
    return data.entries.map((entry) {
      return pw.Text(
        '${entry.key}: ${_parsePDFValue(entry.value)}',
        style: pw.TextStyle(fontSize: 14),
      );
    }).toList();
  }

  // Parse the value for PDF display (handling lists/maps)
  String _parsePDFValue(dynamic value) {
    if (value is List) {
      return value.join(', ');
    } else if (value is Map) {
      return value.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    } else {
      return value?.toString() ?? 'N/A';
    }
  }
}
