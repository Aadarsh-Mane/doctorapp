import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctorapp/Doctor/DoctorAssignedLabsPatient.dart';
import 'package:doctorapp/Nurse/AttendanceScreen.dart';
import 'package:doctorapp/Nurse/PatientListScreen.dart';
import 'package:doctorapp/providers/auth_providers.dart';
import 'package:doctorapp/screens/DoctorProfileScreen.dart';
import 'package:doctorapp/screens/NurseProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:animations/animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NurseMainScreen extends StatefulWidget {
  @override
  _NurseMainScreenState createState() => _NurseMainScreenState();
}

class _NurseMainScreenState extends State<NurseMainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    PatientListScreen(),
    AttendanceScreen(),
    // AssignedLabsScreen(),
    NurseProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nurse's Dashboard"),
      ),
      drawer: const NurseDrawer(),
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

class NurseDrawer extends StatelessWidget {
  const NurseDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 40,
                    backgroundImage: AssetImage(
                        'assets/images/spanddd.jpeg'), // Adjusted image size
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Powered By\n20's Developers",
                  style: TextStyle(color: Colors.black, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                OpenContainer(
                  closedBuilder: (context, openContainer) => ListTile(
                    leading: const Icon(Icons.assignment_turned_in_sharp),
                    title: const Text('Attendance'),
                    onTap: openContainer,
                  ),
                  openBuilder: (context, closeContainer) => AttendanceScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
                OpenContainer(
                  closedBuilder: (context, openContainer) => ListTile(
                    leading: const Icon(Icons.assignment_turned_in_sharp),
                    title: const Text('All Patients'),
                    onTap: openContainer,
                  ),
                  openBuilder: (context, closeContainer) => PatientListScreen(),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
                OpenContainer(
                  closedBuilder: (context, openContainer) => ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifications'),
                    onTap: openContainer,
                  ),
                  openBuilder: (context, closeContainer) => const Scaffold(
                    body: Center(child: Text('Notifications Screen')),
                  ),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
                OpenContainer(
                  closedBuilder: (context, openContainer) => ListTile(
                    leading: const Icon(Icons.report),
                    title: const Text('Reports'),
                    onTap: openContainer,
                  ),
                  openBuilder: (context, closeContainer) => const Scaffold(
                    body: Center(child: Text('Reports Screen')),
                  ),
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              ],
            ),
          ),
        ],
      ),
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

class HomeScreen extends ConsumerStatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final List<String> imgList = [
    'assets/images/span.png',
    'assets/images/spandd.png',
    'assets/images/spando.png',
  ];

  @override
  void initState() {
    super.initState();
    // Trigger the fetch when the screen is first loaded
    Future.microtask(() {
      ref.read(nurseProfileProvider.notifier).getNurseProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final nurseProfile = ref.watch(nurseProfileProvider);

    return SingleChildScrollView(
      child: Column(
        children: [
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
              'Welcome to the Spandan Hospital',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          // Check if doctorProfile is null or not
          nurseProfile == null
              ? const CircularProgressIndicator() // Show loading while fetching
              : nurseProfile != null
                  ? Card(
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
                                  "Welcome Nurse : ${nurseProfile!.nurseName}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Email : ${nurseProfile.email}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
