import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:ate/db_connection/DBConnections.dart';
import 'package:ate/models/user_transactions.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

class Razorpaybl {
  late BuildContext context;

  int GlobalAmount = 0;

  void openCheckout(String amount, int Contact, String emailid,
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
      'prefill': {'contact': Contact, 'email': emailid},
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
    final dataString = prefs.getString('userData');
    if (dataString != null) {
      final data = jsonDecode(dataString);
      UserTransactions ufs = UserTransactions(
        Username: data['Email'] ?? '',
        // Handle potential null value
        TransactionAmount: GlobalAmount.toString(),
        // Get amount from response if available
        Transactionid: response.code?.toString() ?? '',

        // Use proper timestamp
        Transactionmode: response.message?.toString() ?? '',
        TransactionStatus: "Failed",
      );
      await saveTransactionToDatabase(
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
    final dataString = prefs.getString('userData');
    if (dataString != null) {
      final data = jsonDecode(dataString);
      UserTransactions ufs = UserTransactions(
        Username: data['Email'] ?? '',

        TransactionAmount: GlobalAmount.toString(),

        Transactionid: response.paymentId?.toString() ?? '',

        Transactionmode: response.signature.toString(),
        TransactionStatus: "success",

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
      DbConnections dbConnections = DbConnections();
      db = await Db.create(dbConnections
          .connectionstrion());
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