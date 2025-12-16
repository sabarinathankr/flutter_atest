import 'package:flutter/material.dart';
import 'db_exceptions.dart';
import '../main.dart'; // for navigatorKey

class GlobalErrorHandler {
  static bool _isDialogOpen = false;

  static void handle(Object error) {
    if (_isDialogOpen) return;

    if (error is DbNoInternetException) {
      _show(
        "No Internet Connection",
        "Please check your network settings.",
        Icons.wifi_off,
      );
    } else if (error is DbAuthException) {
      _show(
        "Service Unavailable",
        "We are under maintenance.\nPlease try again later.",
        Icons.error_outline,
      );
    } else {
      _show(
        "Something went wrong",
        "Please try again after some time.",
        Icons.warning,
      );
    }
  }

  static void _show(String title, String desc, IconData icon) {
    _isDialogOpen = true;

    showGeneralDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.6),
      pageBuilder: (_, __, ___) {
        return WillPopScope(
          onWillPop: () async {
            _isDialogOpen = false; // ✅ reset flag
            Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop();
            return false; // ❌ prevent default pop
          },
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
}
