import 'package:mongo_dart/mongo_dart.dart';


class UserForms {
  ObjectId? id;
  String FullName;
  String Email;
  String Password;
  String MobileNumber;
  String Gender;
  String Dateofbirth;
  String Profile;
  String UsrType;

  UserForms({
    this.id,
    required this.FullName,
    required this.Email,
    required this.Password,
    required this.MobileNumber,
    required this.Gender,
    required this.Dateofbirth,
    required this.Profile,
    required this.UsrType,
  });

  // Convert MongoDB document to Dart object
  factory UserForms.fromMap(Map<String, dynamic> map) {
    return UserForms(
      id: map['_id'],
      FullName: map['FullName'],
      Email: map['Email'],
      Password: map['Password'],
      MobileNumber: map['MobileNumber'],
      Gender: map['Gender'],
      Dateofbirth: map['Dateofbirth'],
      Profile: map['Profile'],
      UsrType: map['UsrType'],
    );
  }

  // Convert Dart object to MongoDB document
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'FullName': FullName,
      'Email': Email,
      'Password': Password,
      'MobileNumber': MobileNumber,
      'Gender': Gender,
      'Dateofbirth': Dateofbirth,
      'Profile': Profile,
      'UsrType':UsrType,
    };

    if (id != null) {
      map['_id'] = id;
    }

    return map;
  }
}