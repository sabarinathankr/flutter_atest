import 'dart:async';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const AppBootstrap(), // 👈 move logic here
    );
  }
}


class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool isDialogOpen = false;
  late final StreamSubscription _connectivitySub;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkInitialNetwork();
      _listenConnectivity();
    });
  }

  void _listenConnectivity() {
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((_) async {
          final online = await hasInternet();

          if (!online) {
            _showDialog(
              "No Internet Connection",
              "Please check your network settings.",
              Icons.wifi_off,
            );
          } else {
            _hideDialog();
          }
        });
  }

  Future<void> _checkInitialNetwork() async {
    final online = await hasInternet();
    if (!online) {
      _showDialog(
        "No Internet Connection",
        "Please check your network settings.",
        Icons.wifi_off,
      );
    }
  }

  void _showDialog(String title, String desc, IconData icon) {
    if (isDialogOpen) return;
    isDialogOpen = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.6),
      pageBuilder: (_, __, ___) {
        return WillPopScope(
          onWillPop: () async => false, // ✅ block back
          child: Material(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 90, color: Colors.blue),
                  const SizedBox(height: 20),
                  Text(title,
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(desc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _hideDialog() {
    if (!isDialogOpen) return;
    isDialogOpen = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void dispose() {
    _connectivitySub.cancel(); // ✅ VERY IMPORTANT
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const LandingPage();
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
