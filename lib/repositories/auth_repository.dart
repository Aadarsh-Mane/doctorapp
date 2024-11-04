// lib/repositories/auth_repository.dart
import 'dart:convert';
import 'package:doctorapp/models/getDoctorProfile.dart';
import 'package:doctorapp/models/getPatientModel.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  Future<String> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.0.104:3000/users/signin'),
        headers: {
          'Content-Type':
              'application/json', // Set the content type to application/json
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print("Login response status code: ${response.statusCode}");
      print("Login response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        if (!responseBody.containsKey('token')) {
          throw Exception("Token not found in response");
        }

        final token = responseBody['token'];
        await storeToken(token);
        return token;
      } else {
        throw Exception('Failed to login. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Login error: $e");
      rethrow; // Keep this to propagate error up for debugging purposes
    }
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

  Future<List<Patient>> fetchAssignedPatients() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Token not found in SharedPreferences');
    }

    try {
      final response = await http.get(
        Uri.parse('http://192.168.0.104:3000/doctors/getAssignedPatients'),
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
        Uri.parse('http://192.168.0.104:3000/doctors/getDoctorProfile'),
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
}
