import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LogoutScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text("Logout")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await authController.logout();
            // Navigate back to LoginScreen and clear navigation history
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false,
            );
          },
          child: Text("Logout"),
        ),
      ),
    );
  }
}