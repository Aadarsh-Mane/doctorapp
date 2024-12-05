import 'package:doctorapp/models/getLabsPatient.dart';
import 'package:doctorapp/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userTokenProvider = StateProvider<String?>((ref) => null);
final userTypeProvider = StateProvider<String?>((ref) => null);

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
