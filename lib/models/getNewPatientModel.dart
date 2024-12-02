class FollowUp {
  final String nurseId;
  final String date;
  final String notes;
  final String observations;
  final String id;

  FollowUp({
    required this.nurseId,
    required this.date,
    required this.notes,
    required this.observations,
    required this.id,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) {
    return FollowUp(
      nurseId: json['nurseId'],
      date: json['date'],
      notes: json['notes'],
      observations: json['observations'],
      id: json['_id'],
    );
  }
}

class AdmissionRecord {
  final String id;
  final String admissionDate;
  final String reasonForAdmission;
  final String symptoms;
  final String initialDiagnosis;
  final List<dynamic> reports;
  final List<FollowUp> followUps;

  AdmissionRecord({
    required this.id,
    required this.admissionDate,
    required this.reasonForAdmission,
    required this.symptoms,
    required this.initialDiagnosis,
    required this.reports,
    required this.followUps,
  });

  factory AdmissionRecord.fromJson(Map<String, dynamic> json) {
    return AdmissionRecord(
      id: json['_id'],
      admissionDate: json['admissionDate'],
      reasonForAdmission: json['reasonForAdmission'],
      symptoms: json['symptoms'],
      initialDiagnosis: json['initialDiagnosis'],
      reports: json['reports'] ?? [],
      followUps: (json['followUps'] as List<dynamic>)
          .map((e) => FollowUp.fromJson(e))
          .toList(),
    );
  }
}

class Patient1 {
  final String id;
  final String patientId;
  final String name;
  final int age;
  final String gender;
  final String contact;
  final String address;
  final List<AdmissionRecord> admissionRecords;

  Patient1({
    required this.id,
    required this.patientId,
    required this.name,
    required this.age,
    required this.gender,
    required this.contact,
    required this.address,
    required this.admissionRecords,
  });

  factory Patient1.fromJson(Map<String, dynamic> json) {
    return Patient1(
      id: json['_id'],
      patientId: json['patientId'],
      name: json['name'],
      age: json['age'],
      gender: json['gender'],
      contact: json['contact'],
      address: json['address'],
      admissionRecords: (json['admissionRecords'] as List<dynamic>)
          .map((e) => AdmissionRecord.fromJson(e))
          .toList(),
    );
  }
}
