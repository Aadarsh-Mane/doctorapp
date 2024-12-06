// lib/models/NurseProfile.dart
class NurseProfile {
  final String id;
  final String doctorName;
  final String usertype;
  final String email;

  NurseProfile({
    required this.id,
    required this.doctorName,
    required this.usertype,
    required this.email,
  });

  // Factory constructor to create a NurseProfile instance from JSON
  factory NurseProfile.fromJson(Map<String, dynamic> json) {
    return NurseProfile(
      id: json['_id'],
      doctorName: json['doctorName'],
      usertype: json['usertype'],
      email: json['email'],
    );
  }
}
