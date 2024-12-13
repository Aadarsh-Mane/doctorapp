import 'dart:convert';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String contact;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['_id'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      contact: json['contact'],
    );
  }
}

class Doctor {
  final String id;
  final String email;
  final String doctorName;

  Doctor({
    required this.id,
    required this.email,
    required this.doctorName,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'],
      email: json['email'],
      doctorName: json['doctorName'],
    );
  }
}

class LabReport {
  final String labTestName;
  final String reportUrl;
  final String labType;
  final String uploadedAt;
  final String id;

  LabReport({
    required this.labTestName,
    required this.reportUrl,
    required this.labType,
    required this.uploadedAt,
    required this.id,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) {
    return LabReport(
      labTestName: json['labTestName'],
      reportUrl: json['reportUrl'],
      labType: json['labType'],
      uploadedAt: json['uploadedAt'],
      id: json['_id'],
    );
  }
}

class LabPatient {
  final String id;
  final String admissionId;
  final Patient patient;
  final Doctor doctor;
  final String labTestNameGivenByDoctor;
  final List<LabReport> reports;

  LabPatient({
    required this.id,
    required this.admissionId,
    required this.patient,
    required this.doctor,
    required this.labTestNameGivenByDoctor,
    required this.reports,
  });

  factory LabPatient.fromJson(Map<String, dynamic> json) {
    var reportsJson = json['reports'] as List;
    List<LabReport> reportsList =
        reportsJson.map((i) => LabReport.fromJson(i)).toList();

    return LabPatient(
      id: json['_id'],
      admissionId: json['admissionId'],
      patient: Patient.fromJson(json['patientId']),
      doctor: Doctor.fromJson(json['doctorId']),
      labTestNameGivenByDoctor: json['labTestNameGivenByDoctor'],
      reports: reportsList,
    );
  }
}

class LabPatientsResponse {
  final String message;
  final List<LabPatient> labReports;

  LabPatientsResponse({
    required this.message,
    required this.labReports,
  });

  factory LabPatientsResponse.fromJson(Map<String, dynamic> json) {
    var labReportsJson = json['labReports'] as List;
    List<LabPatient> labReportsList =
        labReportsJson.map((i) => LabPatient.fromJson(i)).toList();

    return LabPatientsResponse(
      message: json['message'],
      labReports: labReportsList,
    );
  }
}
