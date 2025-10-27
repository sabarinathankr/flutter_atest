import 'dart:convert';

import 'package:ate/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceHelper{
  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<String> getPreferenceEmail() async{
    String email="";
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(AppConstants.userData);

    if (dataString != null) {
      final data = jsonDecode(dataString);
      email=data['Email'].toString();
      return email;
    }
    return email;
  }

  static Future<String> getPreferenceFullName() async{
    String name="";
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(AppConstants.userData);

    if (dataString != null) {
      final data = jsonDecode(dataString);
      name=data['FullName'].toString();
      return name;
    }
    return name;
  }

}