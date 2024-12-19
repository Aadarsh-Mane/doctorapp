class PatientHistory {
  final String? id;
  final String? patientId;
  final String? name;
  final String? gender;
  final String? contact;
  final List<History>? history;
  final int? v;

  PatientHistory({
    this.id,
    this.patientId,
    this.name,
    this.gender,
    this.contact,
    this.history,
    this.v,
  });

  factory PatientHistory.fromJson(Map<String, dynamic> json) => PatientHistory(
        id: json["_id"],
        patientId: json["patientId"],
        name: json["name"],
        gender: json["gender"],
        contact: json["contact"],
        history: json["history"] == null
            ? null
            : List<History>.from(
                json["history"].map((x) => History.fromJson(x))),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "patientId": patientId,
        "name": name,
        "gender": gender,
        "contact": contact,
        "history": history == null
            ? null
            : List<dynamic>.from(history!.map((x) => x.toJson())),
        "__v": v,
      };
}

class History {
  final Doctor? doctor;
  final String? admissionId;
  final DateTime? admissionDate;
  final DateTime? dischargeDate;
  final String? reasonForAdmission;
  final List<String>? doctorPrescription;
  final String? symptoms;
  final String? initialDiagnosis;
  final List<String>? reports;
  final List<FollowUp>? followUps;
  final List<LabReport>? labReports;
  final String? id;

  History({
    this.doctor,
    this.admissionId,
    this.admissionDate,
    this.dischargeDate,
    this.reasonForAdmission,
    this.doctorPrescription,
    this.symptoms,
    this.initialDiagnosis,
    this.reports,
    this.followUps,
    this.labReports,
    this.id,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        doctor: json["doctor"] == null ? null : Doctor.fromJson(json["doctor"]),
        admissionId: json["admissionId"],
        admissionDate: json["admissionDate"] == null
            ? null
            : DateTime.parse(json["admissionDate"]),
        dischargeDate: json["dischargeDate"] == null
            ? null
            : DateTime.parse(json["dischargeDate"]),
        reasonForAdmission: json["reasonForAdmission"],
        doctorPrescription: json["doctorPrescrption"] == null
            ? null
            : List<String>.from(json["doctorPrescrption"].map((x) => x)),
        symptoms: json["symptoms"],
        initialDiagnosis: json["initialDiagnosis"],
        reports: json["reports"] == null
            ? null
            : List<String>.from(json["reports"].map((x) => x)),
        followUps: json["followUps"] == null
            ? null
            : List<FollowUp>.from(
                json["followUps"].map((x) => FollowUp.fromJson(x))),
        labReports: json["labReports"] == null
            ? null
            : List<LabReport>.from(
                json["labReports"].map((x) => LabReport.fromJson(x))),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "doctor": doctor?.toJson(),
        "admissionId": admissionId,
        "admissionDate": admissionDate?.toIso8601String(),
        "dischargeDate": dischargeDate?.toIso8601String(),
        "reasonForAdmission": reasonForAdmission,
        "doctorPrescrption": doctorPrescription == null
            ? null
            : List<dynamic>.from(doctorPrescription!.map((x) => x)),
        "symptoms": symptoms,
        "initialDiagnosis": initialDiagnosis,
        "reports":
            reports == null ? null : List<dynamic>.from(reports!.map((x) => x)),
        "followUps": followUps == null
            ? null
            : List<dynamic>.from(followUps!.map((x) => x.toJson())),
        "labReports": labReports == null
            ? null
            : List<dynamic>.from(labReports!.map((x) => x.toJson())),
        "_id": id,
      };
}

class Doctor {
  final DoctorId? id;
  final String? name;

  Doctor({
    this.id,
    this.name,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json["id"] == null ? null : DoctorId.fromJson(json["id"]),
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id?.toJson(),
        "name": name,
      };
}

class DoctorId {
  final String? id;

  DoctorId({
    this.id,
  });

  factory DoctorId.fromJson(Map<String, dynamic> json) => DoctorId(
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
      };
}

class FollowUp {
  final String? nurseId;
  final String? date;
  final String? notes;
  final String? observations;
  final String? id;

  FollowUp({
    this.nurseId,
    this.date,
    this.notes,
    this.observations,
    this.id,
  });

  factory FollowUp.fromJson(Map<String, dynamic> json) => FollowUp(
        nurseId: json["nurseId"],
        date: json["date"],
        notes: json["notes"],
        observations: json["observations"],
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "nurseId": nurseId,
        "date": date,
        "notes": notes,
        "observations": observations,
        "_id": id,
      };
}

class LabReport {
  final String? labTestNameGivenByDoctor;
  final List<Report>? reports;
  final String? id;

  LabReport({
    this.labTestNameGivenByDoctor,
    this.reports,
    this.id,
  });

  factory LabReport.fromJson(Map<String, dynamic> json) => LabReport(
        labTestNameGivenByDoctor: json["labTestNameGivenByDoctor"],
        reports: json["reports"] == null
            ? null
            : List<Report>.from(json["reports"].map((x) => Report.fromJson(x))),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "labTestNameGivenByDoctor": labTestNameGivenByDoctor,
        "reports": reports == null
            ? null
            : List<dynamic>.from(reports!.map((x) => x.toJson())),
        "_id": id,
      };
}

class Report {
  final String? labTestName;
  final String? reportUrl;
  final String? labType;
  final DateTime? uploadedAt;
  final String? id;

  Report({
    this.labTestName,
    this.reportUrl,
    this.labType,
    this.uploadedAt,
    this.id,
  });

  factory Report.fromJson(Map<String, dynamic> json) => Report(
        labTestName: json["labTestName"],
        reportUrl: json["reportUrl"],
        labType: json["labType"],
        uploadedAt: json["uploadedAt"] == null
            ? null
            : DateTime.parse(json["uploadedAt"]),
        id: json["_id"],
      );

  Map<String, dynamic> toJson() => {
        "labTestName": labTestName,
        "reportUrl": reportUrl,
        "labType": labType,
        "uploadedAt": uploadedAt?.toIso8601String(),
        "_id": id,
      };
}
