import 'package:carousel_slider/carousel_slider.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:doctorapp/Doctor/DoctorAssignedLabsPatient.dart';
import 'package:doctorapp/Nurse/PatientListScreen.dart';
import 'package:doctorapp/screens/LogoutScreen.dart';
import 'package:doctorapp/Doctor/DoctorAssignedPatientScreen.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:doctorapp/Doctor/DoctorAssignedLabsPatient.dart';
import 'package:doctorapp/Nurse/PatientListScreen.dart';
import 'package:doctorapp/screens/LogoutScreen.dart';
import 'package:doctorapp/Doctor/DoctorAssignedPatientScreen.dart';
import 'package:flutter/material.dart';

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
    LogoutScreen(),
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
        title: const Text("Doctor's Dashboard"),
        centerTitle: true,
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: const Text(
              "Doctor's Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // Handle Notifications navigation
            },
          ),
          ListTile(
            leading: const Icon(Icons.report),
            title: const Text('Reports'),
            onTap: () {
              // Handle Reports navigation
            },
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
        Icon(Icons.calendar_today, size: 30, color: Colors.white),
        Icon(Icons.assessment, size: 30, color: Colors.white),
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

class HomeScreen extends StatelessWidget {
  final List<String> imgList = [
    'assets/images/span.png',
    'assets/images/spandd.png',
    'assets/images/spando.png',
  ];

  @override
  Widget build(BuildContext context) {
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
              'Welcome to the Doctor\'s Dashboard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
