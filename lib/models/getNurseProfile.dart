// lib/models/NurseProfile.dart
class NurseProfile {
  final String id;
  final String nurseName;
  final String usertype;
  final String email;

  NurseProfile({
    required this.id,
    required this.nurseName,
    required this.usertype,
    required this.email,
  });

  // Factory constructor to create a NurseProfile instance from JSON
  factory NurseProfile.fromJson(Map<String, dynamic> json) {
    return NurseProfile(
      id: json['_id'],
      nurseName: json['nurseName'],
      usertype: json['usertype'],
      email: json['email'],
    );
  }
}
