import 'package:doctorapp/Doctor/DoctorMainScreen.dart';
import 'package:doctorapp/Nurse/NurseMainScreen.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String selectedUsertype =
      'nurse'; // Default to nurse, could be 'doctor' as well

  @override
  Widget build(BuildContext context) {
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select user type
            DropdownButton<String>(
              value: selectedUsertype,
              items: <String>['doctor', 'nurse'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedUsertype =
                      newValue!; // This will trigger a rebuild and update the selected user type
                });
              },
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  await authController.login(
                    emailController.text,
                    passwordController.text,
                    selectedUsertype,
                  );

                  // Check and navigate based on usertype
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
                        content: Text("Login failed: Invalid credentials")),
                  );
                }
              },
              child: Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
