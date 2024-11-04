import 'package:doctorapp/models/getDoctorProfile.dart';
import 'package:doctorapp/models/getPatientModel.dart';
import 'package:doctorapp/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthController extends StateNotifier<bool> {
  AuthController(this.ref) : super(false);

  final Ref ref;

  Future<void> login(String email, String password) async {
    final authRepository = ref.read(authRepositoryProvider);
    try {
      final token = await authRepository.login(email, password);
      if (token != null) {
        state = true;
      }
    } catch (e) {
      state = false;
    }
  }

  Future<void> logout() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.clearToken();
    state = false;
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(ref),
);

final assignedPatientsProvider = FutureProvider<List<Patient>>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);
  return await authRepository.fetchAssignedPatients();
});
final fetchDoctorProfile = FutureProvider<DoctorProfile>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);
  return await authRepository.fetchDoctorProfile();
});
