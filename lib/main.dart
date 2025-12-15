import 'dart:io';
import 'package:ate/models/announcementModel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_connection/DBConnections.dart';
import 'ui/landingpage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDialogOpen = false;

  @override
  void initState() {
    super.initState();
    checkAnnouncement();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen for connectivity changes
      Connectivity().onConnectivityChanged.listen((_) async {
        bool online = await hasInternet();

        if (!online) {
          _showAppStuckDialog("No Internet Connection",
              "Please check your network settings.", Icons.wifi_off);
        } else {
          _hideNetworkDialog();
        }
      });

      // Initial check
      checkInitialNetwork();
    });
  }

  Future<void> checkInitialNetwork() async {
    bool online = await hasInternet();
    if (!online) {
      _showAppStuckDialog("No Internet Connection",
          "Please check your network settings.", Icons.wifi_off);
    }
  }

  void checkAnnouncement() async {
    DbConnections dbConnections = DbConnections();
    List<AnnouncementModel> announcements =
        await dbConnections.checkAnnouncements();

    if (announcements != null && announcements.isNotEmpty) {
      AnnouncementModel announcement = announcements[0];
      if(announcement.isDisplay == true){
        _showAppStuckDialog(announcement.tittle, announcement.description, Icons.info);
      }
    }

  }

  void _showAppStuckDialog(String title, String description, IconData icon) {
    if (isDialogOpen) return;
    isDialogOpen = true;

    showGeneralDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,

      // 👇 Background dim (optional)
      barrierColor: Colors.white.withOpacity(0.6),

      transitionDuration: const Duration(milliseconds: 200),

      pageBuilder: (context, anim1, anim2) {
        return Material(
          // 👇 Full-screen background is now WHITE
          color: Colors.white,

          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.blue, size: 90),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }

  /// ✅ Automatically closes when internet returns
  void _hideNetworkDialog() {
    if (!isDialogOpen) return;
    isDialogOpen = false;

    Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const LandingPage(),
    );
  }
}

/// ✔ REAL INTERNET CHECK (Not just WiFi/Data)
Future<bool> hasInternet() async {
  try {
    final result = await InternetAddress.lookup("google.com")
        .timeout(const Duration(seconds: 2));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (_) {
    return false;
  }
}
