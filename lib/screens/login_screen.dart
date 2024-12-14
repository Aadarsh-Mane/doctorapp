import 'package:doctorapp/Doctor/DoctorMainScreen.dart';
import 'package:doctorapp/Labs/LabScreen.dart';
import 'package:doctorapp/Nurse/NurseMainScreen.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/DoctorProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedUsertype = 'nurse'; // Default to nurse

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider.notifier);
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isPortrait ? 24.0 : 48.0,
              vertical: isPortrait ? 40.0 : 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular image above the login form
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue[100],
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/spp.png', // Replace with hospital logo
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Welcome text
                Text(
                  "Welcome to Spandan Hospital",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isPortrait ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Please login to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isPortrait ? 16 : 18,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 30),
                // User type selection with radio buttons
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select User Type",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedRadioButton(
                          label: "Doctor",
                          value: 'doctor',
                          groupValue: selectedUsertype,
                          onChanged: (value) {
                            setState(() {
                              selectedUsertype = value;
                            });
                          },
                        ),
                        AnimatedRadioButton(
                          label: "Nurse",
                          value: 'nurse',
                          groupValue: selectedUsertype,
                          onChanged: (value) {
                            setState(() {
                              selectedUsertype = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Email field with animation on focus
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Password field with focus effect
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.teal, width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 30),
                // Login button with hover effect
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await authController.login(
                        emailController.text,
                        passwordController.text,
                        selectedUsertype,
                      );

                      // Navigate based on user type
                      final usertype = await authController.getUsertype();
                      if (usertype == 'doctor') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DoctorMainScreen()),
                        );
                      } else if (usertype == 'nurse') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NurseMainScreen()),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Login failed: Invalid credentials"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.teal.shade700,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 8,
                  ),
                  child: Text(
                    "Login",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 40),
                // Footer with branding
                Column(
                  children: [
                    Text(
                      "Powered by",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.developer_mode,
                          color: Colors.blue[800],
                          size: 28,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "20s Developers",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedRadioButton extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const AnimatedRadioButton({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.white : Colors.grey.shade600,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
