import 'package:doctorapp/Doctor/DoctorMainScreen.dart';
import 'package:doctorapp/Nurse/NurseMainScreen.dart';
import 'package:doctorapp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      home: FutureBuilder<String?>(
        future: getUserTypeAndToken(), // Fetch user type and token
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while fetching
          }

          final token = snapshot.data?.split(',')[0]; // Get token
          final userType = snapshot.data?.split(',')[1]; // Get user type

          if (token != null) {
            // User is logged in, navigate based on user type
            if (userType == 'doctor') {
              return DoctorMainScreen(); // Navigate to Doctor's main screen
            } else if (userType == 'nurse') {
              return NurseMainScreen(); // Navigate to Nurse's main screen
            }
          }

          return LoginScreen(); // Navigate to login if no token
        },
      ),
    );
  }

  Future<String?> getUserTypeAndToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userType = prefs.getString('usertype');

    return token != null && userType != null ? '$token,$userType' : null;
  }
}
