import 'package:doctorapp/Doctor/DoctorHomeScreen.dart';
import 'package:doctorapp/constants/app_color.dart';
import 'package:doctorapp/screens/LogoutScreen.dart';
import 'package:flutter/material.dart';
import 'package:doctorapp/screens/assigned_patient_screen.dart';
// Import your color theme

class DoctorMainScreen extends StatefulWidget {
  @override
  _DoctorMainScreenState createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen> {
  int _selectedIndex = 0; // Track the selected bottom navigation index

  List<Widget> _screens = [
    DoctorHomeScreen(),
    AssignedPatientsScreen(),
    AnotherScreen(), // Add other screens here
    AnotherScreen1(), // Add other screens here
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LogoutScreen()),
              );
            },
          ),
        ],
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
              title: Text('Home Screen'),
              onTap: () {
                Navigator.pop(context);
                _onItemTapped(0);
              },
            ),

            ListTile(
              title: Text('Assigned  Patient'),
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
            icon: Icon(Icons.list_rounded),
            label: 'Assigned Patients',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Another Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class AnotherScreen1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Another Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
