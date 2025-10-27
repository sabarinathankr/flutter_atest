import 'dart:convert';
import 'package:intl/intl.dart';

class UploadPostModel {
  String title;
  String description;
  String email;
  String fullName;
  String visibility;
  String timestamp;
  String youTubeLink;

  // Constructor
  UploadPostModel({
    this.title = '',
    this.description = '',
    this.email = '',
    this.fullName = '',
    this.youTubeLink ='',
    this.visibility = 'private',
    String? timestamp, // optional parameter
  }) : timestamp = timestamp ?? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  /// Convert the object to Map for MongoDB or API request
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'email': email,
      'visibility': visibility,
      'timestamp': timestamp,
      'youTubeLink': youTubeLink,
      'fullName': fullName,
      // file can be handled separately
    };
  }

  /// Create object from Map (for fetching data)
  factory UploadPostModel.fromMap(Map<String, dynamic> map) {
    return UploadPostModel(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName']??'',
      youTubeLink : map['youTubeLink'],
      visibility: map['visibility'] ?? 'private',
      timestamp: map['timestamp'], // will use value from map if exists
    );
  }
}
