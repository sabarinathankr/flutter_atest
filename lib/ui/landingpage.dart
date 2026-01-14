import 'dart:convert';

import 'package:ate/ui/adminpage.dart';
import 'package:ate/ui/payment_page.dart';
import 'package:ate/ui/postpage.dart';
import 'package:ate/ui/setting_page.dart';
import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import '../utils/shared_preference.dart';
import 'CustomAppBar.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  bool _hideadmin = true;
  TabController? _tabController;

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
      _tabController = TabController(length: newHideAdmin ? 3 : 4, vsync: this);
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
          setStateCallback: setState,
        ),
    ];

    return Scaffold(
      appBar: CustomAppBar(
        tabController: _tabController,
        tabs: tabs,
      ),
      body: TabBarView(
        controller: _tabController,
        children:views,
      ),
    );

  }
}
