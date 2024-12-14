import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:doctorapp/repositories/auth_repository.dart';

class AssignedPatientsNotifier
    extends StateNotifier<AsyncValue<List<Patient1>>> {
  final AuthRepository authRepository;

  AssignedPatientsNotifier(this.authRepository)
      : super(const AsyncValue.loading());

  // Fetch assigned patients
  Future<void> fetchAssignedPatients() async {
    try {
      state = const AsyncValue.loading(); // Show loading state
      final patients = await authRepository.getAssignedPatients();
      state = AsyncValue.data(patients); // Set fetched data
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Set error state
    }
  }

  // Refresh assigned patients (same as fetch but allows external trigger)
  Future<void> refreshPatients() async {
    await fetchAssignedPatients();
  }

  void removePatient(Patient1 patient) {
    state.whenData((patients) {
      final updatedPatients = List<Patient1>.from(patients)
        ..removeWhere((item) => item.id == patient.id); // Remove the patient
      state = AsyncValue.data(updatedPatients); // Update the state
    });
  }
}

class AdmittedPatientsNotifier
    extends StateNotifier<AsyncValue<List<Patient1>>> {
  final AuthRepository authRepository;

  AdmittedPatientsNotifier(this.authRepository)
      : super(const AsyncValue.loading());

  // Fetch assigned patients
  Future<void> fetchAdmittedPatients() async {
    try {
      state = const AsyncValue.loading(); // Show loading state
      final patients = await authRepository.getAdmittedPatients();
      state = AsyncValue.data(patients); // Set fetched data
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // Set error state
    }
  }

  // Refresh assigned patients (same as fetch but allows external trigger)
  Future<void> refreshPatients() async {
    await fetchAdmittedPatients();
  }

  void removePatient(Patient1 patient) {
    state.whenData((patients) {
      final updatedPatients = List<Patient1>.from(patients)
        ..removeWhere((item) => item.id == patient.id); // Remove the patient
      state = AsyncValue.data(updatedPatients); // Update the state
    });
  }
}
