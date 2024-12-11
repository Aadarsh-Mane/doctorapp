import 'package:doctorapp/Doctor/DoctorMainScreen.dart';
import 'package:doctorapp/Nurse/NurseMainScreen.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/LogoutScreen.dart';
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
                // User type dropdown with improved animations and style
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 300),
                  child: DropdownButtonFormField<String>(
                    key: ValueKey<String>(selectedUsertype),
                    value: selectedUsertype,
                    decoration: InputDecoration(
                      labelText: "Select User Type",
                      labelStyle: TextStyle(color: Colors.teal.shade700),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                    style: TextStyle(fontSize: 16, color: Colors.teal),
                    items: ['doctor', 'nurse'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value[0].toUpperCase() + value.substring(1),
                          style: TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        selectedUsertype = newValue!;
                      });
                    },
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.teal,
                    ),
                    iconSize: 30,
                  ),
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
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LogoutScreen(),
                    ),
                  ),
                  child: Text('Lab login'),
                ),
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
