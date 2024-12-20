import 'package:doctorapp/Doctor/DoctorMainScreen.dart';
import 'package:doctorapp/Nurse/NurseMainScreen.dart';
import 'package:doctorapp/SplashScreen.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/login_screen.dart';
import 'package:doctorapp/stateprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the AuthController provider globally
final authControllerProvider =
    StateNotifierProvider<AuthController, bool>((ref) {
  return AuthController(ref);
});

void main() async {
  // await Firebase.initializeApp(); // Initialize Firebase
  runApp(ProviderScope(child: MyApp()));
}

// class MyApp extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Watch the authController to determine login state
//     final isLoggedIn = ref.watch(authControllerProvider);

//     return MaterialApp(
//       title: 'Your App Title',
//       home: isLoggedIn
//           ? AuthenticatedNavigation(ref) // Navigate based on user type
//           : LoginScreen(), // Navigate to login if not authenticated
//     );
//   }
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Your App Title',
      home: SplashScreen(), // Set SplashScreen as the first screen
    );
  }
}

Widget AuthenticatedNavigation(WidgetRef ref) {
  return FutureBuilder<String?>(
    future: getUserType(), // Fetch user type directly from SharedPreferences
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(
            child: CircularProgressIndicator()); // Show loading indicator
      }

      final userType = snapshot.data; // Get the userType
      print("User type: $userType");

      if (userType == 'doctor') {
        return DoctorMainScreen(); // Navigate to Doctor's main screen
      } else if (userType == 'nurse') {
        return NurseMainScreen(); // Navigate to Nurse's main screen
      }

      return LoginScreen(); // Fallback to LoginScreen if no userType found
    },
  );
}

Future<String?> getUserType() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('usertype'); // Fetch userType from SharedPreferences
}
