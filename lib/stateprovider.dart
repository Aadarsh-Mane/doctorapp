import 'dart:convert';

import 'package:doctorapp/constants/Urls.dart';
import 'package:doctorapp/models/getDoctorProfile.dart';
import 'package:doctorapp/models/getLabModel.dart';
import 'package:doctorapp/models/getLabsPatient.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:doctorapp/models/getNurseProfile.dart';
import 'package:doctorapp/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AssignedLabsNotifier extends StateNotifier<List<AssignedLab>> {
  final AuthRepository authRepository;

  AssignedLabsNotifier(this.authRepository) : super([]);

  // Fetch the assigned labs from the API
  Future<void> fetchAssignedLabs() async {
    try {
      final labs = await authRepository.getAssignedLabs();
      state = labs; // Update the state with fetched data
    } catch (e) {
      throw Exception('Failed to fetch assigned labs: $e');
    }
  }
}

class DoctorProfileNotifier extends StateNotifier<DoctorProfile?> {
  final AuthRepository authRepository;

  DoctorProfileNotifier(this.authRepository) : super(null);

  // Fetch the doctor profile from the API
  Future<void> getDoctorProfile() async {
    print('Fetching doctor profile...');

    try {
      final doctorProfile = await authRepository.fetchDoctorProfile();
      print('Doctor profile fetched successfully: $doctorProfile');

      state = doctorProfile; // Update the state with fetched data
    } catch (e) {
      throw Exception('Failed to fetch doctor profile: $e');
    }
  }
}

class NurseProfileNotifier extends StateNotifier<NurseProfile?> {
  final AuthRepository authRepository;

  NurseProfileNotifier(this.authRepository) : super(null);

  // Fetch the doctor profile from the API
  Future<void> getNurseProfile() async {
    print('Fetching doctor profile...');

    try {
      final nurseProfile = await authRepository.fetchNurseProfile();
      print('Doctor profile fetched successfully: $nurseProfile');

      state = nurseProfile; // Update the state with fetched data
    } catch (e) {
      throw Exception('Failed to fetch doctor profile: $e');
    }
  }
}

// LabPatientsNotifier will fetch the data and notify listeners when it changes.
class LabPatientsNotifier extends StateNotifier<List<LabPatient>> {
  LabPatientsNotifier() : super([]);

  Future<void> fetchLabPatients() async {
    final response = await http
        .get(Uri.parse('http://192.168.0.103:3000/labs/getlabPatients'));
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final labPatientsResponse = LabPatientsResponse.fromJson(data);
      state = labPatientsResponse.labReports; // Update the state
    } else {
      throw Exception('Failed to load lab patients');
    }
  }
}

class AdmittedPatientsNotifier
    extends StateNotifier<AsyncValue<List<Patient1>>> {
  final AuthRepository authRepository;

  AdmittedPatientsNotifier(this.authRepository)
      : super(const AsyncValue.loading());

  Future<void> fetchAdmittedPatients1() async {
    try {
      final patients = await authRepository.fetchAdmittedPatients();
      print('Fetched patients: $patients'); // Log the fetched patients
      state = AsyncValue.data(patients);
    } catch (e) {
      print('Error: $e');
      // state = AsyncValue.error(e); // Update the state with the error
    }
  }
}

class FollowUpsNotifier extends StateNotifier<List<FollowUp>> {
  FollowUpsNotifier() : super([]);

  Future<void> fetchFollowUps(String admissionId) async {
    try {
      final url = '${VERCEL_URL}/nurse/followups/$admissionId';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Parse the response into a list of FollowUp objects
        final followUps = jsonList
            .map((json) => FollowUp.fromJson(json as Map<String, dynamic>))
            .toList();

        state = followUps; // Update the notifier's state
      } else {
        throw Exception('Failed to fetch follow-ups: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching follow-ups: $e');
    }
  }
}
