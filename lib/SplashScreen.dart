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
  double _opacityHospital = 0.0;
  double _opacityLogo = 0.0;
  double _opacityPoweredBy = 0.0;
  double _opacityCompanyLogo = 0.0;

  @override
  void initState() {
    super.initState();
    _animateSplash();
  }

  // Sequential fade-in animation for each widget
  _animateSplash() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _opacityHospital = 1.0;
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _opacityLogo = 1.0;
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _opacityPoweredBy = 1.0;
    });

    await Future.delayed(Duration(seconds: 1));
    setState(() {
      _opacityCompanyLogo = 1.0;
    });

    // After the animation, navigate to the next screen
    await Future.delayed(Duration(seconds: 2)); // Wait a bit before navigating
    _navigateToNextScreen();
  }

  // Navigate to the next screen after the splash
  _navigateToNextScreen() async {
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
      body: Stack(
        children: [
          // Main content at the center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _opacityHospital,
                  duration: Duration(seconds: 1),
                  child: Image.asset(
                    'assets/images/spp.png', // Replace with your logo path
                    height: 150,
                  ),
                ),
                SizedBox(height: 50),
                AnimatedOpacity(
                  opacity: _opacityHospital,
                  duration: Duration(seconds: 1),
                  child: Text(
                    'Spandan Hospital',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),

          // Footer at the bottom with "Powered by" and company logo
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(20.0), // Adjust padding as needed
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: _opacityPoweredBy,
                    duration: Duration(seconds: 1),
                    child: Text(
                      'Powered by 20s Developers',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  AnimatedOpacity(
                    opacity: _opacityCompanyLogo,
                    duration: Duration(seconds: 1),
                    child: Image.asset(
                      'assets/images/ss.png', // Replace with your company logo
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
