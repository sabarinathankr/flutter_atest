

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:typed_data';


import '../Login.dart';
import '../Register.dart';
import '../models/sales_data.dart';
import '../utils/shared_preference.dart';
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

class _UserDashboardTabState extends State<UserDashboardTab> {
  bool _isLoginVisible = true;
  bool _isLogoutVisible = false;
  String Username = "User";
  Uint8List? Profilepic;

  List<String> menuItems = ['Option 1', 'Option 2', 'Option 3'];
  List<bool> toggleStates = [false, true, false];
  List<SalesData> data = [
    SalesData('Mon', 35),
    SalesData('Tue', 28),
    SalesData('Wed', 34),
    SalesData('Thu', 32),
    SalesData('Fri', 40),
  ];

  int userTtlContrib = 23;

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
          const SizedBox(height: 24),
          _buildQuickActions(isTablet, isLargeScreen),
          const SizedBox(height: 32),
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
        constraints:
        BoxConstraints(maxWidth: isTablet ? 600 : double.infinity),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyApp1("isregister")),
                  );
                },
                icon: const Icon(Icons.app_registration),
                label: const Text('Register'),
                style: _buttonStyle(isTablet),
              ),
            ),
            const SizedBox(width: 16),
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
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 20 : 16,
                    ),
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
            const SizedBox(width: 16),
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

  // QUICK ACTIONS GRID
  Widget _buildQuickActions(bool isTablet, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isLargeScreen ? 3 : (isTablet ? 2 : 2),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isTablet ? 1.3 : 1.1,
          children: [
            _buildActionCard('Analytics', Icons.analytics, Colors.teal, () {
              _showAnalyticsBottomSheet(isTablet);
            }, isTablet),
            _buildActionCard('Settings', Icons.settings, Colors.teal, () {
              _showSettingsBottomSheet(isTablet);
            }, isTablet),
            _buildActionCard('Support', Icons.contact_support, Colors.green, () {
              _showSupportBottomSheet(isTablet);
            }, isTablet),
          ],
        ),
      ],
    );
  }

  // HELPERS
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

  Widget _buildActionCard(String title, IconData icon, Color color,
      VoidCallback onPressed, bool isTablet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isTablet ? 20.0 : 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: isTablet ? 32 : 24),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _pickImage() {
    // Implement your image picker
  }

  void _showAnalyticsBottomSheet(bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContainer(
        title: 'Analytics',
        child: SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          primaryYAxis: NumericAxis(),
          series: <CartesianSeries<SalesData, String>>[
            ColumnSeries<SalesData, String>(
              dataSource: data,
              xValueMapper: (SalesData sales, _) => sales.year,
              yValueMapper: (SalesData sales, _) => sales.sales,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            )
          ],
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContainer(
        title: 'Admin Settings',
        child: Card(
          child: Column(
            children: List.generate(
              menuItems.length,
                  (index) => ListTile(
                title: Text(
                  menuItems[index],
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                ),
                trailing: Switch(
                  value: toggleStates[index],
                  onChanged: (bool newValue) {
                    setState(() {
                      toggleStates[index] = newValue;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showSupportBottomSheet(bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BottomSheetContainer(
        title: 'Send Notification',
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: const [
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text('Account Settings'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notifications'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.security),
              title: Text('Security'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help & Support'),
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple reusable bottom sheet container widget
class _BottomSheetContainer extends StatelessWidget {
  final String title;
  final Widget child;

  const _BottomSheetContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title,
                style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

