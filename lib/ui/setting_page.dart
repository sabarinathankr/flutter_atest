import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:typed_data';

import '../Login.dart';
import '../Register.dart';
import '../models/sales_data.dart';
import '../utils/shared_preference.dart';
import '../utils/app_constants.dart'; // 👈 Make sure AppConstants.userData is defined here
import 'landingpage.dart'; // for SfCartesianChart

class UserDashboardTab extends StatefulWidget {
  final Size screenSize;
  final bool isTablet;
  final bool isLargeScreen;

  const UserDashboardTab({
    super.key,
    required this.screenSize,
    this.isTablet = false,
    this.isLargeScreen = false,
  });

  @override
  State<UserDashboardTab> createState() => _UserDashboardTabState();
}

class _UserDashboardTabState extends State<UserDashboardTab>
    with WidgetsBindingObserver {
  bool _isLoginVisible = true;
  bool _isLogoutVisible = false;
  String Username = "User";
  Uint8List? Profilepic;
  int userTtlContrib = 23;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus(); // 👈 Check login state at start
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detect app resume/pause
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint("App Resumed");
      _onResumeAction();
    } else if (state == AppLifecycleState.paused) {
      debugPrint("App Paused");
    } else if (state == AppLifecycleState.inactive) {
      debugPrint("App Inactive");
    } else if (state == AppLifecycleState.detached) {
      debugPrint("App Detached");
    }
  }

  void _onResumeAction() {
    // Check login state again when app resumes
    _checkLoginStatus();
  }

  // 👇 Check login status and update buttons
  Future<void> _checkLoginStatus() async {
    final dataString =
    await SharedPreferenceHelper.getString(AppConstants.userData);
    if (dataString != null && dataString.isNotEmpty) {
      final data = jsonDecode(dataString);
      setState(() {
        _isLoginVisible = false;
        _isLogoutVisible = true;
        Username = data['FullName'];
        Profilepic = base64Decode(data['Profile']);
      });
    } else {
      setState(() {
        _isLoginVisible = true;
        _isLogoutVisible = false;
        Username = "User";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = widget.isTablet;
    final isLargeScreen = widget.isLargeScreen;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isTablet),
          const SizedBox(height: 24),
          _buildAuthSection(isTablet),
          const SizedBox(height: 24),
          _buildProfileSection(isTablet),
          const SizedBox(height: 24),
          _buildStatsGrid(isTablet, isLargeScreen),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Dashboard',
            style: TextStyle(
              fontSize: isTablet ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back! Here\'s what\'s happening today.',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  // AUTH BUTTONS SECTION
  Widget _buildAuthSection(bool isTablet) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
        child: Row(
          children: [
            // REGISTER
            if (_isLoginVisible)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterPage()),
                    );
                  },
                  icon: const Icon(Icons.app_registration),
                  label: const Text('Register'),
                  style: _buttonStyle(isTablet),
                ),
              ),
            if (_isLoginVisible) const SizedBox(width: 16),

            // LOGIN
            if (_isLoginVisible)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  icon: const Icon(Icons.login_outlined),
                  label: const Text('Login'),
                  style: _buttonStyle(isTablet),
                ),
              ),

            // LOGOUT
            if (_isLogoutVisible)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await SharedPreferenceHelper.clear();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Logging off')),
                    );
                    setState(() {
                      Username = "User";
                      _isLoginVisible = true;
                      _isLogoutVisible = false;
                    });
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LandingPage()),
                          (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lime,
                    foregroundColor: Colors.black,
                    padding:
                    EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // PROFILE SECTION
  Widget _buildProfileSection(bool isTablet) {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: isTablet ? 80 : 60,
            backgroundImage: (Profilepic != null && Profilepic!.isNotEmpty)
                ? MemoryImage(Profilepic!)
                : null,
            child: (Profilepic == null || Profilepic!.isEmpty)
                ? Icon(Icons.camera_alt, size: isTablet ? 50 : 40)
                : null,
          ),
        ),
        const SizedBox(height: 24),
        Text(Username, style: TextStyle(fontSize: isTablet ? 18 : 25)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Edit Profile feature coming soon!')),
              );
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: _buttonStyle(isTablet),
          ),
        ),
      ],
    );
  }

  // STATS GRID
  Widget _buildStatsGrid(bool isTablet, bool isLargeScreen) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isLargeScreen ? 4 : (isTablet ? 2 : 2),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: isTablet ? 1.5 : 1.2,
      children: [
        _buildStatCard('Total Contribution', userTtlContrib.toString(),
            Icons.currency_rupee, Colors.orange, '+23%', isTablet),
        _buildStatCard('Favourite', '0', Icons.article, Colors.green,
            '+8%', isTablet),
        _buildStatCard('Notifications', '0', Icons.notifications,
            Colors.purple, '+5%', isTablet),
      ],
    );
  }

  // BUTTON STYLE HELPER
  ButtonStyle _buttonStyle(bool isTablet) {
    return ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: TextStyle(
        fontSize: isTablet ? 20 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color,
      String change, bool isTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: isTablet ? 32 : 24),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: isTablet ? 12 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() {
    // Implement your image picker
  }
}
