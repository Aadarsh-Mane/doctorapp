import 'package:carousel_slider/carousel_slider.dart';
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

  // Screens for the bottom navigation bar (3 screens)
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(), // HomeScreen containing the banner slider
    AssignedPatientsScreen(),
    LogoutScreen(),
    // const Center(child: Text("Schedule Screen")),
    // const Center(child: Text("Patient Info Screen")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Doctor's Dashboard")),
      drawer: DoctorDrawer(), // Custom drawer for better organization
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: DoctorBottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class DoctorDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('''Doctor's Menu''',
                style: TextStyle(color: Colors.white)),
            decoration: BoxDecoration(color: Colors.blue),
          ),
          ListTile(
            title: Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PatientListScreen()),
              );
            },
          ),
          ListTile(
            title: Text('Notifications'),
            onTap: () {
              // Handle Notifications navigation
            },
          ),
          ListTile(
            title: Text('Reports'),
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

  const DoctorBottomNavBar(
      {Key? key, required this.selectedIndex, required this.onItemTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'Assigned Patients',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.logout),
          label: 'Logout',
        ),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  // List of images for the carousel
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
          // Banner Slider
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              viewportFraction: 0.8,
              autoPlayInterval: Duration(seconds: 3),
            ),
            items: imgList.map((item) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5.0)],
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
          // Additional Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Welcome to the Doctor\'s Dashboard'),
          ),
        ],
      ),
    );
  }
}