import 'package:doctorapp/constants/app_color.dart';
import 'package:doctorapp/screens/HomeScreen.dart';
import 'package:doctorapp/Doctor/DoctorAssignedPatientScreen.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Track the selected bottom navigation index

  List<Widget> _screens = [
    HomeScreen(),
    AssignedPatientsScreen(),
    // AnotherScreen(), // Add other screens here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDF5FE),
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Color.fromARGB(20, 164, 189, 220),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.lightBlueTop,
              AppColors.lightBlueBottom,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _screens[_selectedIndex], // Show selected screen
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.lightBlueTop,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Assigned Patients'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),
            ListTile(
              title: Text('Another Screen'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(1);
              },
            ),
            // Add more ListTiles for other screens
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'Patients',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.medical_information),
          //   label: 'Patients',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
