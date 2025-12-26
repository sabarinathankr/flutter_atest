import 'dart:io';

import 'package:ate/ui/widgets/CreatePostWidget.dart';
import 'package:ate/ui/widgets/statcard.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../DataFile.dart';
import '../db_connection/DBConnections.dart';
import '../models/sales_data.dart';



class AdminDashboard extends StatefulWidget {
  final Function setStateCallback;

  const AdminDashboard({
    super.key,
    required this.setStateCallback,
  });

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with WidgetsBindingObserver {
  List<dynamic> dynamicList = [];
  bool isLoading = false;
  int userCount =0;
  int totalRevenue =0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getUserCount();
    getTotalRevenue();
  }

  Future<void> getTotalRevenue() async {
    setState(() => isLoading = true);
    DbConnections dbConnections = DbConnections();
    List<UserTransactions> list =
    await dbConnections.getTotalRevenue();
    if(list.isNotEmpty){
      for (var item in list) {
        totalRevenue = totalRevenue + int.parse(item.transactionAmount);
      }

    }
    setState(() {
      totalRevenue = totalRevenue;
      isLoading = false;
    });
  }

  Future<void> getUserCount() async {
    setState(() => isLoading = true);

    DbConnections dbConnections = DbConnections();
     userCount =
    await dbConnections.getUserCount();

    setState(() {
      userCount =userCount;
      isLoading = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 1024;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== Header =====
          Container(
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
                  'Admin Dashboard',
                  style: TextStyle(
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome back! Here\'s what\'s happening today.',
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // ===== Quick Stats =====
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 4 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.5 : 1.2,
            children: [
              StatCard(
                  title: 'Total Users',
                  value: userCount.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                  change: '+12%',
                  isTablet: false),
             /* StatCard(
                title: 'Active Posts',
                value: '0',
                icon: Icons.article,
                color: Colors.green,
                change: '+8%',
                isTablet: false,
              ),*/
              StatCard(
                  title: 'Revenue',
                  value: totalRevenue.toString(),
                  icon: Icons.currency_rupee,
                  color: Colors.orange,
                  change: '+23%',
                  isTablet: false),
             /* StatCard(
                  title: 'Notifications',
                  value: '0',
                  icon: Icons.notifications,
                  color: Colors.purple,
                  change: '+5%',
                  isTablet: false),*/
            ],
          ),
          SizedBox(height: 24),

          // ===== Quick Actions =====
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isLargeScreen ? 3 : (isTablet ? 2 : 2),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.3 : 1.1,
            children: [
              _buildActionCard('Create Post', Icons.post_add, Colors.blue,
                  _openCreatePostSheet, isTablet)

              ,

             /* _buildActionCard('Highlight', Icons.highlight, Colors.orange,
                  _openHighlightSheet, isTablet),
              _buildActionCard('Send Notify', Icons.notifications, Colors.green,
                  _openNotifySheet, isTablet),
              _buildActionCard('UserMgmt', Icons.people_alt, Colors.purple,
                  _openUserMgmtSheet, isTablet),
              _buildActionCard('Analytics', Icons.analytics, Colors.teal,
                  _openAnalyticsSheet, isTablet),
              _buildActionCard('Settings', Icons.settings, Colors.grey,
                  _openSettingsSheet, isTablet),*/
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===== Action Card Builder =====
  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isTablet,
  ) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: isTablet ? 40 : 28),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Modal Sheets (stubs) =====
  void _openCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: const CreatePostWidget(),
      ),
    );

  }

  void _openHighlightSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Center(child: Text('Highlight Settings')),
    );
  }

  void _openNotifySheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Center(child: Text('Send Notification UI')),
    );
  }

  void _openUserMgmtSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Center(child: Text('User Management UI')),
    );
  }

  void _openAnalyticsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Center(child: Text('Analytics Chart UI')),
    );
  }

  void _openSettingsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const Center(child: Text('Admin Settings UI')),
    );
  }
}
