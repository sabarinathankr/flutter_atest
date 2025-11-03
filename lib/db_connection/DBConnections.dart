import 'package:ate/DataFile.dart' hide UserForms;
import 'package:ate/models/upload_post_model.dart';
import 'package:ate/utils/app_constants.dart';
import 'package:ate/utils/shared_preference.dart';
import 'package:flutter/cupertino.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import '../main.dart';
import '../models/user_forms.dart';



class DbConnections
{
  bool resultype=false;
  String connectionstrion() {
    String Connection="mongodb+srv://atestrazorpay:OucgJLTdGOHrpWwq@cluster0.a1okps9.mongodb.net/AtestCollections?retryWrites=true&w=majority&appName=Cluster0";
    return Connection;
  }

  Future<String?> loginData(String username, String password, BuildContext context) async {
    try {
      // Ensure Flutter is initialized (just in case)
      WidgetsFlutterBinding.ensureInitialized();

      // Connect to DB
      final db = await Db.create(connectionstrion());
      await db.open();
      var collection = db.collection("UserForms");

      // Query for user
      var result = await collection.find({
        'Email': username,
        'Password': password,
      }).toList();

      await db.close(); // Close DB

      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid credentials'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      // Save user locally
      var userDoc = result.first;
      print("SharedPreferences_userDoc: $userDoc");
      try {
        // final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('userData', jsonEncode(userDoc))
        await SharedPreferenceHelper.setString(AppConstants.userData, jsonEncode(userDoc));


      } catch (spError) {
        print("SharedPreferences error: $spError");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local storage error'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      String userType = userDoc['UsrType'] ?? "";

      if (userType.isNotEmpty) {
        final dialog = AwesomeDialog(
          context: context,
          animType: AnimType.leftSlide,
          dialogType: DialogType.noHeader,
          showCloseIcon: false,
          dismissOnTouchOutside: false,
          customHeader: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          title: 'Success',
          desc: 'User login successful!',
        );

        dialog.show();

        Future.delayed(Duration(seconds: 2), () {
          dialog.dismiss();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyApp()), (Route<dynamic> route) => false,
          );
        });

        return userType;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User type not defined.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }


  Future<void> uploadPost(UploadPostModel uploadPostModel,  void Function(bool isSuccess, String msg) onSuccess) async{
    final db = await Db.create(connectionstrion());
    await db.open();
    var collection = db.collection("AdminPost");
    var result = await collection.insertOne(uploadPostModel.toMap());

    if (result.isSuccess) {
      print('success');
      onSuccess(true, 'Upload successful');
    } else {
      print('error');
      onSuccess(false, result.errmsg ?? 'Unknown error occurred');
    }

  }
  Future<void> getAllPost(UploadPostModel uploadPostModel,  void Function(bool isSuccess) onSuccess) async{
    final db = await Db.create(connectionstrion());
    await db.open();
    var collection = db.collection("AdminPost");
    var result = await collection.insertOne(uploadPostModel.toMap());

    if (result.isSuccess) {
      print('success');
      onSuccess(true);
    } else {
      print('error');
      onSuccess(false);
    }
  }


  /// Fetch all posts
  Future<List<UploadPostModel>> getAllPosts() async {
    final db = await Db.create(connectionstrion());
    await db.open();
    var collection = db.collection("AdminPost");

    try {
      final documents = await collection.find().toList();
      // Convert each document into UploadPostModel
      List<UploadPostModel> posts = documents.map((doc) => UploadPostModel.fromMap(doc)).toList();
      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    } finally {
      await db.close();
    }
  }

  /// Fetch all transactions
  Future<List<UserTransactions>> getAllTransactions(int year, int month) async {
    final db = await Db.create(connectionstrion());
    await db.open();
    var collection = db.collection("UserTransactions");

    try {
      final email = await SharedPreferenceHelper.getPreferenceEmail();

      // Define month range
      var startDate = DateTime(year, month, 1);
      var endDate = DateTime(year, month + 1, 1);

      // Fetch all transactions for this user
      var documents = await collection.find(
          where.eq('username', email)
      ).toList();

      // Filter in Dart since createdAt is stored as a string
      var monthlyData = documents.where((doc) {
        if (doc['createdAt'] == null) return false;

        var createdAt = DateTime.tryParse(doc['createdAt']);
        if (createdAt == null) return false;

        return createdAt.isAfter(startDate.subtract(const Duration(milliseconds: 1))) &&
            createdAt.isBefore(endDate);
      }).toList();

      // ✅ Convert filtered documents into UserTransactions objects
      List<UserTransactions> posts = monthlyData
          .map((doc) => UserTransactions.fromMap(doc))
          .toList();

      print('Success: ${posts.length} transactions found');
      return posts;
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    } finally {
      await db.close();
    }
  }




  InsertData(UserForms ufs,BuildContext context) async
  {
    final db = await Db.create(connectionstrion());
    await db.open();
    var collection = db.collection("UserForms");
    var result = await collection.insertOne(ufs.toMap());

    if (result.isSuccess) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(ufs.toMap()));
      print(prefs);
      // Show success dialog
      final dialog = AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.noHeader, // Prevent default header
        showCloseIcon: false,
        dismissOnTouchOutside: false,
        customHeader: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 80,
        ),
        title: 'Success',
        desc: 'User registered successfully!',
      );

      dialog.show();

      Future.delayed(Duration(seconds: 2), () {
        dialog.dismiss(); // Close the dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
      });

      print('User inserted with ID: ${result.id}');

      // Can store Map, List, etc.
    } else {
      // Show error snackbar
      final dialog = AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.noHeader, // Prevent default header
        showCloseIcon: false,
        dismissOnTouchOutside: false,
        customHeader: Icon(
          Icons.cancel,
          color: Colors.red,
          size: 80,
        ),
        title: 'Failed',
        desc: 'User registered Failed!',
      );

      dialog.show();

      Future.delayed(Duration(seconds: 2), () {
        dialog.dismiss(); // Close the dialog

      });
      print('Failed to insert user');
    }


    await db.close();
    return(resultype);
  }
  Future<void> RemoveUser(String username) async {
    Db? db;
    db = await Db.create(connectionstrion());
    await db.open();
    var collection = db.collection("UserForms");
    var result = await collection.deleteOne(where.eq('Email', username));
    if(result.isSuccess) {
      print("Deleted");
    }
    await db.close();
  }

  // Change your ShowUser method to specify return type
  Future<List<String>> ShowUser() async {
    Db? db;
    try {
      db = await Db.create(connectionstrion());
      await db.open();
      var collection = db.collection("UserForms");

      var result = await collection.find(where.fields(['FullName']).excludeFields(['_id'])).toList();

      print('Raw result: $result');
      print('Result type: ${result.runtimeType}');

      // Check if result is empty
      if (result.isEmpty) {
        print('No documents found');
        return <String>[];
      }

      // Extract FullName values from the documents
      List<String> stringList = result.map((doc) {
        if (doc is Map) {
          // Extract the FullName field value
          String fullName = doc['FullName']?.toString() ?? '';
          print('Extracted FullName: $fullName');
          return fullName;
        }
        return '';
      }).where((name) => name.isNotEmpty).toList(); // Filter out empty names

      print('Final stringList: $stringList');
      return stringList;

    } catch (e) {
      print('Error in ShowUser: $e');
      return <String>[];
    } finally {
      try {
        await db?.close();
      } catch (e) {
        print('Error closing database: $e');
      }
    }
  }
  Future<String> getSessionEmail() async{
    String email="";
    final dataString =await SharedPreferenceHelper.getString(AppConstants.userData);



    if (dataString != null) {
      final data = jsonDecode(dataString);
      email=data['Email'].toString();
      return email;
    }

    return email;
  }

  Future<Map<String, List<String>>> TransactionDetails() async {
    Db? db;
    try {
      db = await Db.create(connectionstrion());
      await db.open();
      var collection = db.collection("UserTransactions");
      String sessionemail= await getSessionEmail();
      var result = await collection.find(
          where.eq('username', sessionemail)
      ).toList();


      print('Raw result: $result');
      print('Result type: ${result.runtimeType}');

      // Check if result is empty
      if (result.isEmpty) {
        print('No documents found');
        return {
          'amounts': [],
          'transactionIds': [],
        };
      }

      // Extract FullName values from the documents
      List<String> stringtransactionList = result.map((doc) {
        if (doc is Map) {
          // Extract the FullName field value
          String amount = doc['transactionAmount']?.toString() ?? '';
          return "RS "+amount;
        }
        return '';
      }).where((name) => name.isNotEmpty).toList(); // Filter out empty names

      List<String> transactionid = result.map((doc) {
        if (doc is Map) {
          // Extract the FullName field value
          String transactionid = doc['transactionId']?.toString() ?? '';
          return transactionid;
        }
        return '';
      }).where((name) => name.isNotEmpty).toList();

      List<String> Transactiondate = result.map((doc) {
        if (doc is Map) {
          // Extract the FullName field value
          String Transactiondate = doc['transactionDate']?.toString() ?? '';
          return Transactiondate;
        }
        return '';
      }).where((name) => name.isNotEmpty).toList();

      List<String> Transactiontime = result.map((doc) {
        if (doc is Map) {
          // Extract the FullName field value
          String Transactiontime = doc['transactionTime']?.toString() ?? '';
          return Transactiontime;
        }
        return '';
      }).where((name) => name.isNotEmpty).toList();

      print('Final stringList: $stringtransactionList');
      return {'amounts': stringtransactionList, 'transactionIds': transactionid,'Transactiondate':Transactiondate,'Transactiontime':Transactiontime};

    } catch (e) {
      print('Error in ShowUser: $e');
      return {
        'amounts': [],
        'transactionIds': [],
      };
    } finally {
      try {
        await db?.close();
      } catch (e) {
        print('Error closing database: $e');
      }
    }
  }

}