import 'package:doctorapp/models/getDoctorProfile.dart';
import 'package:doctorapp/models/getNewPatientModel.dart';
import 'package:doctorapp/models/getPatientModel.dart';
import 'package:doctorapp/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

class AuthController extends StateNotifier<bool> {
  AuthController(this.ref) : super(false);

  final Ref ref;

  Future<void> login(String email, String password, String usertype) async {
    final authRepository = ref.read(authRepositoryProvider);
    String? token;

    if (usertype == 'nurse') {
      token = await authRepository.loginNurse(email, password);
    } else {
      token = await authRepository.login(email, password);
    }

    if (token != null) {
      state = true;
    }
  }

  Future<void> logout() async {
    final authRepository = ref.read(authRepositoryProvider);
    await authRepository.clearToken();
    state = false;
  }

  Future<String?> checkLoginStatus() async {
    final authRepository = ref.read(authRepositoryProvider);
    final token = await authRepository.getToken();
    if (token != null) {
      state = true;
    }
    return token;
  }

  Future<String?> getUsertype() async {
    final authRepository = ref.read(authRepositoryProvider);
    return await authRepository.getUsertype();
  }
}

final patientListProvider = FutureProvider<List<Patient1>>((ref) async {
  final authRepository = ref.read(authRepositoryProvider);
  return authRepository.fetchPatients();
});

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
