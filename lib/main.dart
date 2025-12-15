import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Listen for connectivity changes
      Connectivity().onConnectivityChanged.listen((_) async {
        bool online = await hasInternet();

        if (!online) {
          _showNetworkDialog();
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
      _showNetworkDialog();
    }
  }

  /// 🚫 FULL-SCREEN NON-DISMISSIBLE NETWORK ERROR SCREEN
  void _showNetworkDialog() {
    if (isDialogOpen) return;
    isDialogOpen = true;

    showGeneralDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      barrierColor: Colors.black87,     // dark background
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Material(
          color: Colors.black.withOpacity(0.85), // full overlay
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.wifi_off, color: Colors.white, size: 90),
                SizedBox(height: 20),
                Text(
                  "No Internet Connection",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Please check your network settings.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                CircularProgressIndicator(color: Colors.white),
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
