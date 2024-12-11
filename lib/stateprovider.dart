import 'package:doctorapp/models/getDoctorProfile.dart';
import 'package:doctorapp/models/getLabsPatient.dart';
import 'package:doctorapp/models/getNurseProfile.dart';
import 'package:doctorapp/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
