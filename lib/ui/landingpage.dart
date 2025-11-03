import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:alphabet_navigation/alphabet_navigation.dart';
import 'package:ate/Register.dart';
import 'package:ate/ui/adminpage.dart';
import 'package:ate/ui/payment_page.dart';
import 'package:ate/ui/postpage.dart';
import 'package:ate/ui/setting_page.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../DataFile.dart';
import '../Login.dart';
import '../models/comment.dart';
import '../models/post_data.dart';
import '../models/sales_data.dart';
import '../utils/app_constants.dart';
import '../utils/shared_preference.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  bool _hideadmin = true;
  TabController? _tabController;

  final List<SalesData> data = [
    SalesData('Jan', 35),
    SalesData('Feb', 28),
    SalesData('Mar', 34),
    SalesData('Apr', 32),
    SalesData('May', 40),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initView();
  }

  Future<void> _initView() async {
    final dataString =
    await SharedPreferenceHelper.getString(AppConstants.userData);

    final newHideAdmin = !(dataString != null &&
        jsonDecode(dataString)['UsrType'].toString() == "Admin");

    if (newHideAdmin != _hideadmin) {
      _tabController?.dispose();
      _tabController =
          TabController(length: newHideAdmin ? 3 : 4, vsync: this);
    }

    setState(() {
      _hideadmin = newHideAdmin;
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_tabController == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLargeScreen = screenSize.width > 1200;

    // ✅ Tabs & views must match exactly
    final tabs = <Tab>[
      const Tab(icon: Icon(Icons.rss_feed_outlined, size: 28)),
      const Tab(icon: Icon(Icons.payment, size: 28)),
      const Tab(icon: Icon(Icons.settings, size: 28)),
      if (!_hideadmin)
        const Tab(icon: Icon(Icons.admin_panel_settings_sharp, size: 28)),
    ];

    final views = <Widget>[
      EnhancedPostTab(isTablet: isTablet),
      PaymentsTab(screenSize: screenSize, isTablet: isTablet),
      UserDashboardTab(
        screenSize: screenSize,
        isTablet: isTablet,
        isLargeScreen: isLargeScreen,
      ),
      if (!_hideadmin)
        AdminDashboard(
          data: data,
          setStateCallback: setState,
        ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text(
          'ATEST',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.white),
        ),
        centerTitle: false,
        elevation: 3,
        backgroundColor: Colors.blue.shade700,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IgnorePointer(
              ignoring: false, // ✅ allow taps!
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                overlayColor:
                WidgetStateProperty.all(Colors.transparent), // no ripple
                dividerColor: Colors.transparent,
                labelColor: Colors.blue.shade700,
                unselectedLabelColor: Colors.grey.shade500,
                tabs: tabs,
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: views,
      ),
    );
  }
}





