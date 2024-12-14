import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart'; // For animation

class DoctorProfileScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<DoctorProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger the fetch when the screen is first loaded
    Future.microtask(() {
      ref.read(doctorProfileProvider.notifier).getDoctorProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final doctorProfile = ref.watch(doctorProfileProvider);
    final authController = ref.read(authControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        onPressed: () async {
          await authController.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
        child: Icon(Icons.logout),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with name (floating style)
              CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/images/doctor1.png'),
              ).animate().fadeIn(duration: Duration(milliseconds: 700)),
              const SizedBox(height: 16),
              Text(
                "Dr. ${doctorProfile!.doctorName}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: 800)),
              const SizedBox(height: 10),

              // Profile Information Section with fade-in animation
              Card(
                color: Colors.black,
                elevation: 10,
                shadowColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.email, "Email", doctorProfile.email),
                      const Divider(),
                      _buildInfoRow(Icons.healing, "Specialty", "Surgeon"),
                      const Divider(),
                      _buildInfoRow(
                          Icons.access_time, "Experience", "10 Years"),
                      const Divider(),
                      _buildInfoRow(Icons.phone, "Phone", "91 9167787316"),
                      const Divider(),
                      _buildInfoRow(Icons.local_hospital, "Department", "OPD"),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: Duration(milliseconds: 1000)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for creating information rows
  Widget _buildInfoRow(IconData icon, String title, String subtitle) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.cyan,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16, color: Colors.cyan),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.cyan),
      ),
    );
  }
}
// class LogoutScreen extends ConsumerWidget {
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authController = ref.read(authControllerProvider.notifier);

//     return Scaffold(
//       appBar: AppBar(title: Text("Logout")),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             await authController.logout();
//             // Navigate back to LoginScreen and clear navigation history
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(builder: (context) => LoginScreen()),
//               (route) => false,
//             );
//           },
//           child: Text("Logout"),
//         ),
//       ),
//     );
//   }

