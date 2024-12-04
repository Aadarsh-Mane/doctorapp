import 'package:flutter/material.dart';
import 'package:doctorapp/Doctor/DoctorMainScreen.dart';
import 'package:doctorapp/Nurse/NurseMainScreen.dart';
import 'package:doctorapp/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  // Navigate to the next screen after a delay
  _navigateToNextScreen() async {
    await Future.delayed(
        Duration(seconds: 3)); // Show splash screen for 3 seconds
    final token = await _getToken();
    final userType = await _getUserType();

    if (token != null && userType != null) {
      if (userType == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => DoctorMainScreen()),
        );
      } else if (userType == 'nurse') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NurseMainScreen()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String?> _getUserType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('usertype');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/span.png',
                height: 150), // Replace with your logo path
            SizedBox(height: 20),
            Text(
              'Spandan Hospital',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Powered by 20s Developers',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),
            Image.asset('assets/images/doctor1.png',
                height: 50), // Replace with your company logo
          ],
        ),
      ),
    );
  }
}
