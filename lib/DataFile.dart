import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:ate/utils/app_constants.dart';

import 'main.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
class blanddb
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

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userData', jsonEncode(userDoc));
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
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


  InsertData(UserForms ufs,BuildContext context) async
  {
    final db = await Db.create(connectionstrion());
    await db.open();
    var collection = db.collection("UserForms");
    var result = await collection.insertOne(ufs.toMap());

    if (result.isSuccess) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.userData, jsonEncode(ufs.toMap()));
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
    String Email="";
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString('userData');

    if (dataString != null) {
      final data = jsonDecode(dataString);
      Email=data['Email'].toString();
      return Email;
    }

    return Email;
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

class UserTransactions{
  ObjectId? id;
  String username;
  String transactionAmount;
  String transactionId;
  String createdAt;

  String transactionMode;
  String transactionStatus;
  UserTransactions({
    this.id,
    required this.username,
    required this.transactionAmount,
    required this.transactionId,
required this. createdAt,
    required this.transactionMode,
    required this.transactionStatus,
  });
  factory UserTransactions.fromMap(Map<String, dynamic> map) {

    return UserTransactions(
      id: map['_id'],
      username: map['username'],
        transactionAmount: map['transactionAmount'],
      transactionId: map['transactionId'],
        createdAt: map['createdAt'],
      transactionMode: map['transactionMode'],
        transactionStatus:map['transactionAmount']

    );
  }


  Map<String, dynamic> toMap() {
    final DateTime now = DateTime.now();
    List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
// DateTime.weekday returns 1 for Monday, so adjust index
    String dayAbbreviation = weekdays[(now.weekday % 7)]; // Sunday becomes index 0
    String monthAbbreviation = months[(now.month % 12)];
    String formattedDate = "$dayAbbreviation   $monthAbbreviation   ${now.year}";
    String timeOnly = "${now.hour.toString().padLeft(2, '0')}:"
        "${now.minute.toString().padLeft(2, '0')}:"
        "${now.second.toString().padLeft(2, '0')}";
    return {
      'username': username,
      'transactionAmount': transactionAmount,
      'transactionId': transactionId,
      'transactionDate': formattedDate,
      'transactionTime': timeOnly,
      'transactionMode': transactionMode,
      'transactionStatus': transactionStatus,
      'createdAt': createdAt,
    };
  }
}


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


class Razorpaybl {
  late BuildContext context;
  int GlobalAmount = 0;

  void openCheckout(String amount, int mobileNumber, String emailid,
      String Name) async {
    GlobalAmount = int.parse(amount);
    Razorpay razorpay = Razorpay();
    var options = {
      'key': 'rzp_live_RGb6Xk82bK2ItR',
      'amount': amount,
      'name': 'Anbu Thane Ellam Sethu Trust',
      'description': 'Donation Amount',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {'contact': mobileNumber, 'email': emailid},
      'external': {
        'wallets': ['paytm']
      }
    };

    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(AppConstants.userData);
    if (dataString != null) {
      final data = jsonDecode(dataString);
      UserTransactions ufs = UserTransactions(
        username: data['Email'].toString(),
        // Handle potential null value
        transactionAmount: GlobalAmount.toString(),
        // Get amount from response if available
        transactionId: response.code?.toString() ?? '',
        createdAt: DateTime.now().toIso8601String(),
        // Use proper timestamp
        transactionMode: response.message?.toString() ?? '',
        transactionStatus: "Failed",
      );
      bool isback = await saveTransactionToDatabase(
          ufs, response as PaymentSuccessResponse);
      final dialog = AwesomeDialog(
        context: context,
        animType: AnimType.leftSlide,
        dialogType: DialogType.noHeader,
        // Prevent default header
        showCloseIcon: false,
        dismissOnTouchOutside: false,
        customHeader: Icon(
          Icons.error,
          color: Colors.red,
          size: 80,
        ),
        title: 'Failed',
        desc: 'Payment Failed!',
      );

      dialog.show();
      Future.delayed(Duration(seconds: 2), () {
        dialog.dismiss(); // Close the dialog

      });
    }
  }


  void handlePaymentSuccessResponse(PaymentSuccessResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final dataString = prefs.getString(AppConstants.userData);
    if (dataString != null) {
      final data = jsonDecode(dataString);
      UserTransactions ufs = UserTransactions(
        username: data['Email'].toString(),
        transactionAmount: GlobalAmount.toString(),

        transactionId: response.paymentId?.toString() ?? '',
          createdAt: DateTime.now().toIso8601String(),
        transactionMode: response.signature.toString(),
        transactionStatus: "success",

      );
      bool result = await saveTransactionToDatabase(ufs, response);

    }
  }

  Future<bool> saveTransactionToDatabase(UserTransactions transaction,
      PaymentSuccessResponse response) async {
    // Validate inputs
    if (transaction == null || response == null) {
      print(
          "Error: Invalid input parameters - transaction or response is null");
      return false;
    }

    Db? db;
    try {
      blanddb bldb = blanddb(); // Remove 'new' keyword (optional in modern Dart)
      db = await Db.create(bldb
          .connectionstrion()); // Fixed typo: connectionstrion -> connectionString
      await db.open();

      var collection = db.collection("UserTransactions");
      var result = await collection.insertOne(transaction.toMap());

      if (result.isSuccess) {
        print("Transaction saved successfully - Payment ID: ${response
            .paymentId}");
        return true;
      } else {
        print("Failed to save transaction - Payment ID: ${response.paymentId}");
        return false;
      }
    } catch (e) {
      print("Database error while saving transaction: $e");
      return false;
    } finally {
      // Ensure database connection is properly closed
      try {
        await db?.close();
      } catch (e) {
        print("Error closing database connection: $e");
      }
    }
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Continue"),
      onPressed: () {},
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<Map<String, dynamic>?> fetchPaymentDetails(String paymentId) async {
    try {
      final String basicAuth =
          'Basic ${base64Encode(
          utf8.encode('$keyId:rzp_test_R754PXB5l89CS1'))}';

      final response = await http.get(
        Uri.parse('https://api.razorpay.com/v1/payments/paymentId'),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        log('Error fetching payment: ${response.body}');
        return null;
      }
    } catch (e) {
      log('Exception in fetchPaymentDetails: $e');
      return null;
    }
  }
}