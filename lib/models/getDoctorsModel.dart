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
