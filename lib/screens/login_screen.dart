import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/MainScreen.dart';
import 'package:doctorapp/screens/assigned_patient_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                print(
                    "Attempting login with email: ${emailController.text} and password: ${passwordController.text}");

                try {
                  // Perform login and await response
                  await authController.login(
                    emailController.text,
                    passwordController.text,
                  );

                  // Navigate to AssignedPatientsScreen after a successful login
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainScreen(),
                    ),
                  );
                } catch (e) {
                  // Handle login failure (e.g., show error message)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Login failed: ${e.toString()}")),
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
