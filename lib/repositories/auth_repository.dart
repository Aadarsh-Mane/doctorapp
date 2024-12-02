// lib/repositories/auth_repository.dart
import 'dart:convert';
import 'package:doctorapp/models/getDoctorProfile.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:doctorapp/models/getPatientModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.103:3000/users/signin'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        final usertype = responseBody['user']['usertype'];

        await storeToken(token);
        await storeUsertype(usertype);
        return token;
      } else if (response.statusCode == 401) {
        print("Invalid credentials provided");
        return null;
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
  }

  Future<String?> loginNurse(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://192.168.0.103:3000/nurse/signin'), // Different URL for nurse
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final token = responseBody['token'];
        final usertype = responseBody['user']['usertype'];

        await storeToken(token);
        await storeUsertype(usertype);
        return token;
      } else if (response.statusCode == 401) {
        print("Invalid credentials provided");
        return null;
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Login error: $e");
      rethrow;
    }
  }

  Future<void> storeUsertype(String usertype) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usertype', usertype);
  }

  Future<String?> getUsertype() async {
    final prefs = await SharedPreferences.getInstance();
    final usertype = prefs.getString('usertype');
    print("Retrieved usertype from SharedPreferences: $usertype");
    return usertype;
  }

  Future<void> storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    print(
        "Token stored: $token"); // Add this line to verify the token is stored
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    print("Retrieved token from SharedPreferences: $token");
    return token;
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<void> clearUsertype() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs
        .remove('usertype'); // Remove the usertype from SharedPreferences
    print("Usertype cleared");
  }

  Future<List<Patient>> fetchAssignedPatients() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.103:3000/doctors/getAssignedPatients'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Fetch patients response status code: ${response.statusCode}");
      print("Fetch patients response body: ${response.body}");

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body)['patients'];
        return data.map((json) => Patient.fromJson(json)).toList();
      } else {
        throw Exception(
            'Failed to fetch patients. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching assigned patients: $e");
      rethrow;
    }
  }

  Future<DoctorProfile> fetchDoctorProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }
    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.103:3000/doctors/getDoctorProfile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      print(
          "Fetch doctor profile response status code: ${response.statusCode}");
      print("Fetch doctor profile response body: ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return DoctorProfile.fromJson(
            data['doctorProfile']); // Parse single object
      } else {
        throw Exception(
            'Failed to fetch doctorProfile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetching doctorProfile: $e");
      rethrow;
    }
  }

  Future<List<Patient1>> fetchPatients() async {
    try {
      final response = await http
          .get(Uri.parse('http://192.168.0.103:3000/reception/listPatients'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final patients = (data['patients'] as List)
            .map((patientJson) => Patient1.fromJson(patientJson))
            .toList();
        return patients;
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
