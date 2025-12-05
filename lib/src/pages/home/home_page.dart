import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:leanflutter/src/pages/home/attendance/attendance.dart';
import 'package:leanflutter/src/pages/home/attendance/attendance_report_page.dart';
import 'package:leanflutter/src/pages/home/home_bottom_nav.dart';
import 'package:leanflutter/src/pages/home/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, dynamic>? userData;
  int _currentIndex = 0;
  
  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rawUser = prefs.getString("user");

    if (rawUser != null) {
      setState(() {
        userData = jsonDecode(rawUser);
      });
    }
  }
  
  List<Widget> get _pages => [
    AttendanceScreen(),
    AttendancePrintPage(),
    // Center(child: Text("หน้าแรก", style: TextStyle(fontSize: 28))),
    Center(child: Text("report", style: TextStyle(fontSize: 28))),
    Center(child: Text("การแจ้งเตือน", style: TextStyle(fontSize: 28))),
    ProfilePage(userData: userData),
    
  ];


  @override
  Widget build(BuildContext context) {
    final firstname = userData?["firstname"]?? ""; 
    return Scaffold(
      drawer: HomeDrawer(
        userData: userData,
        onMenuTap: (index) {
          setState(() {
            _currentIndex = index; // 👈 เปลี่ยนหน้า
          });
        },
      ),

      appBar: AppBar(
        title:  Text(firstname),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),

      body: userData == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Color(0xFFFFD700)),
              ),
            )
          : _pages[_currentIndex],

      bottomNavigationBar: HomeBottomNav(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState(() {
      _currentIndex = index;
    });
  },
),
    );
  }
}
