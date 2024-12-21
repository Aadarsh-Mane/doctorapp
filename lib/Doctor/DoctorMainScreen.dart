import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctorapp/Doctor/DoctorAdmittedPatientScreen.dart';
import 'package:doctorapp/Doctor/DoctorAssignedLabsPatient.dart';
import 'package:doctorapp/Doctor/DoctorListScreen.dart';
import 'package:doctorapp/Nurse/PatientListScreen.dart';
import 'package:doctorapp/constants/Urls.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/DoctorProfileScreen.dart';
import 'package:doctorapp/Doctor/DoctorAssignedPatientScreen.dart';
import 'package:doctorapp/service/NotificationService.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animations/animations.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorMainScreen extends StatefulWidget {
  @override
  _DoctorMainScreenState createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    AssignedPatientsScreen(),
    AssignedLabsScreen(),
    DoctorProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // final notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    // notificationService.initializeFCM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Doctor's Dashboard"),
      ),
      drawer: const DoctorDrawer(),
      body: SafeArea(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: DoctorBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class DoctorDrawer extends StatelessWidget {
  const DoctorDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black, // Black drawer background
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.transparent, // Cyan background for the header
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20)), // Rounded top corners
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/spanddd.jpeg'),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Powered By\n20's Developers",
                  style: TextStyle(
                    color: Colors
                        .white, // White text in the header for better contrast
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  context,
                  Icons.assignment_turned_in_sharp,
                  'Assigned Labs',
                  AssignedLabsScreen(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.assignment_turned_in_sharp,
                  'Assigned Patients',
                  AssignedPatientsScreen(),
                ),
                _buildDrawerItem(
                  context,
                  Icons.assignment_turned_in_sharp,
                  'Admitted Patients',
                  AdmittedPatientsScreen(),
                ),
                // _buildDrawerItem(
                //   context,
                //   Icons.assignment_turned_in_sharp,
                //   'Doctors',
                //   AdmittedPatientsScreen(),
                // ),
                // _buildDrawerItem(
                //   context,
                //   Icons.notifications,
                //   'Notifications',
                //   const Scaffold(
                //     body: Center(child: Text('Notifications Screen')),
                //   ),
                // ),
                // _buildDrawerItem(
                //   context,
                //   Icons.report,
                //   'Reports',
                //   const Scaffold(
                //     body: Center(child: Text('Reports Screen')),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, Widget screen) {
    return OpenContainer(
      closedBuilder: (context, openContainer) => ListTile(
        leading: Icon(icon, color: Colors.cyan), // Cyan icon color
        title: Text(
          title,
          style: TextStyle(
            color: Colors.cyan, // Cyan text color
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: openContainer,
        tileColor: Colors.black, // Background color for the tile
      ),
      openBuilder: (context, closeContainer) => screen,
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}

class DoctorBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const DoctorBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index: selectedIndex,
      height: 60.0,
      items: const <Widget>[
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.assignment_ind_outlined, size: 30, color: Colors.white),
        Icon(Icons.local_bar_sharp, size: 30, color: Colors.white),
        Icon(Icons.logout, size: 30, color: Colors.white),
      ],
      color: Colors.blue,
      buttonBackgroundColor: Colors.black,
      backgroundColor: Colors.grey.shade100,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      onTap: onItemTapped,
    );
  }
}
// Adjust the import path

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> imgList = [
    'assets/images/tam.png',
    'assets/images/spandd.png',
    'assets/images/spando.png',
  ];

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

    return SingleChildScrollView(
      child: Column(
        children: [
          // Carousel for images
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              viewportFraction: 0.8,
              autoPlayInterval: const Duration(seconds: 3),
            ),
            items: imgList.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(color: Colors.grey, blurRadius: 5.0)
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    item,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              );
            }).toList(),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Welcome to the Tambe Hospital',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Doctor profile section
          doctorProfile == null
              ? const CircularProgressIndicator() // Show loading while fetching
              : doctorProfile != null
                  ? Card(
                      color: Colors.black,
                      elevation: 8,
                      margin: const EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  AssetImage('assets/images/doctor1.png'),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Doctor : ${doctorProfile!.doctorName}",
                                  style: const TextStyle(
                                    color: Colors.cyan,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Email : ${doctorProfile.email}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.cyan,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(),
          Divider(),
          // Add the cards for other doctors below the profile
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Our Doctors',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Divider(),
          FutureBuilder<List<Doctor>>(
            future: fetchDoctors(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No doctors available'));
              } else {
                final doctors = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    shrinkWrap:
                        true, // To make it scrollable inside SingleChildScrollView
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Two columns
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75, // Adjust to fit the card
                    ),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        shadowColor: Colors.black.withOpacity(0.2),
                        color: Colors.black,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image with a circular border for the doctor's photo
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  'assets/images/doctor1.png', // Placeholder image
                                  height: 100, // Fixed height for the image
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Doctor Name with bold styling and text overflow handling
                              Text(
                                doctor.doctorName,
                                style: const TextStyle(
                                  color: Colors.cyan,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              // Specialization text (if available)
                              // Text(
                              //   doctor.specialization,  // Assuming this is a valid field
                              //   style: const TextStyle(
                              //     fontSize: 14,
                              //     color: Colors.grey,
                              //   ),
                              // ),
                              const SizedBox(height: 4),
                              // Email text with a smaller font size and black color
                              Text(
                                'Email: ${doctor.email}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.cyan,
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Wrap the button in a `Flexible` widget to prevent overflow
                              Flexible(
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Navigate to the doctor's profile page
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.deepPurple, // Button color
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                  ),
                                  child: const Text(
                                    'View Profile',
                                    style: TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<List<Doctor>> fetchDoctors() async {
    final response =
        await http.get(Uri.parse('${VERCEL_URL}/reception/listDoctors'));
    print(response.body);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data.containsKey('doctors')) {
        List<dynamic> doctorsJson = data['doctors'];
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Doctors key not found in response');
      }
    } else {
      throw Exception('Failed to load doctors');
    }
  }
}
