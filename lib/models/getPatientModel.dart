// lib/models/patient.dart
class FollowUp {
  final String nurseId;
  final String date;
  final String notes;
  final String observations;

  FollowUp({
    required this.nurseId,
    required this.date,
    required this.notes,
    required this.observations,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      nurseId: json['nurseId'],
      date: json['date'],
      notes: json['notes'],
      observations: json['observations'],
    );
  }
}

class Doctor {
  final String id;
  final String name;

  Doctor({
    required this.id,
    required this.name,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      name: json['name'],
    );
  }
}

class AdmissionRecord {
  final String id;
  final Doctor doctor;
  final String admissionDate;
  final String reasonForAdmission;
  final String symptoms;
  final String initialDiagnosis;
  final List<FollowUp> followUps;

  AdmissionRecord({
    required this.id,
    required this.doctor,
    required this.admissionDate,
    required this.reasonForAdmission,
    required this.symptoms,
    required this.initialDiagnosis,
    required this.followUps,
  });

  factory AdmissionRecord.fromJson(Map<String, dynamic> json) {
    var followUpsList = json['followUps'] as List;
    List<FollowUp> followUps =
        followUpsList.map((i) => FollowUp.fromJson(i)).toList();

    return AdmissionRecord(
      id: json['_id'],
      doctor: Doctor.fromJson(json['doctor']),
      admissionDate: json['admissionDate'],
      reasonForAdmission: json['reasonForAdmission'],
      symptoms: json['symptoms'],
      initialDiagnosis: json['initialDiagnosis'],
      followUps: followUps,
    );
  }
}

class Patient {
  final String id;
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String address;
  final List<AdmissionRecord> admissionRecords;

  Patient({
    required this.id,
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.address,
    required this.admissionRecords,
  });

  // Factory constructor to create a Patient instance from JSON
  factory Patient.fromJson(Map<String, dynamic> json) {
    var admissionRecordsList = json['admissionRecords'] as List;
    List<AdmissionRecord> admissionRecords =
        admissionRecordsList.map((i) => AdmissionRecord.fromJson(i)).toList();

    return Patient(
      id: json['_id'],
      patientId: json['patientId'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      contact: json['contact'],
      address: json['address'],
      admissionRecords: admissionRecords,
    );
  }
}
