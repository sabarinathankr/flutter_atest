import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';

void main() => runApp(UPIPAY());

class UPIPAY extends StatelessWidget {
  const UPIPAY({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Pay to ATEST'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Screen(),
      ),
    );
  }
}

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  String? _upiAddrError;
  String? _lastTransactionResult;
  final _amountController = TextEditingController();
  bool _isLoading = false;
  List<ApplicationMeta>? _apps;

  @override
  void initState() {
    super.initState();
    _amountController.text = "100";
    _loadUpiApps();
  }

  Future<void> _loadUpiApps() async {
    try {
      final apps = await UpiPay.getInstalledUpiApplications(
          statusType: UpiApplicationDiscoveryAppStatusType.all);
      setState(() {
        _apps = apps;
      });
      if (kDebugMode) {
        print("Found ${apps.length} UPI apps:");
        for (var app in apps) {
          print("- ${app.upiApplication.getAppName()}");
        }
      }
    } catch (e) {
      print("Error loading UPI apps: $e");
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _generateAmount() {
    setState(() {
      _amountController.text = "1";
    });
  }

  Future<void> _onTap(ApplicationMeta app) async {
    // Validate amount
    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null ||
        double.parse(_amountController.text) <= 0) {
      setState(() {
        _upiAddrError = "Please enter a valid amount";
      });
      return;
    }

    // Validate UPI address
    final err = _validateUpiAddress("anbuthaneellamsethu@indianbk");
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }

    setState(() {
      _upiAddrError = null;
      _isLoading = true;
      _lastTransactionResult = null;
    });

    try {
      final transactionRef = 'TXN${DateTime.now().millisecondsSinceEpoch}';
      if (kDebugMode) {
        print("Starting transaction with app: ${app.upiApplication.getAppName()}");
        print("Transaction ref: $transactionRef");
      }

      final result = await UpiPay.initiateTransaction(
        amount: double.parse(_amountController.text).toStringAsFixed(2),
        app: app.upiApplication,
        receiverName: 'ANBU THANE ELLAM SETHU TRUST',
        receiverUpiAddress: "anbuthaneellamsethu@indianbk",
        transactionRef: transactionRef,
        transactionNote: 'Donation',
        // Remove merchantCode initially to test
      );

      // Handle the result
      setState(() {
        _lastTransactionResult = '''
Status: ${result.status}

Response Code: ${result.responseCode ?? 'N/A'}
Approval Ref: ${result.approvalRefNo ?? 'N/A'}

        '''.trim();
      });

      // Print detailed result for debugging
      if (kDebugMode) {
        print("=== Transaction Result ===");
        print("Status: ${result.status}");

        print("Response Code: ${result.responseCode}");
        print("Approval Ref: ${result.approvalRefNo}");

        print("Raw Response: ${result.rawResponse}");
      }

    } catch (e) {
      setState(() {
        _lastTransactionResult = "Error: $e";
      });
      if (kDebugMode) {
        print("Transaction error: $e");
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: <Widget>[
          _amount(),
          if (_upiAddrError != null) _errorWidget(),
          if (_lastTransactionResult != null) _resultWidget(),
          SizedBox(height: 20),
          _receiverInfo(),
          if (Platform.isIOS) _submitButton(),
          Platform.isAndroid ? _androidApps() : _iosApps(),
        ],
      ),
    );
  }

  Widget _receiverInfo() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text('Receiver: ANBU THANE ELLAM SETHU TRUST'),
            Text('UPI ID: anbuthaneellamsethu@indianbk'),
            Text('Note: Donation'),
          ],
        ),
      ),
    );
  }

  Widget _errorWidget() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _upiAddrError!,
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }

  Widget _resultWidget() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last Transaction Result:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _lastTransactionResult!,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _amount() {
    return Container(
      margin: EdgeInsets.only(top: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount to Donate (₹)',
                prefixText: '₹ ',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _generateAmount,
              tooltip: 'Set ₹1',
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: MaterialButton(
              onPressed: _isLoading || _apps == null || _apps!.isEmpty
                  ? null
                  : () async => await _onTap(_apps![0]),
              color: Theme.of(context).colorScheme.secondary,
              height: 48,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              child: _isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Initiate Transaction',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _androidApps() {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text(
              'Pay Using (${_apps?.length ?? 0} apps found)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_apps == null)
            Center(child: CircularProgressIndicator())
          else if (_apps!.isEmpty)
            Container(
              padding: EdgeInsets.all(20),
              child: Text(
                'No UPI apps found on this device',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            _appsGrid(_apps!),
        ],
      ),
    );
  }

  Widget _iosApps() {
    return Container(
      margin: EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 24),
            child: Text(
              'One of these will be invoked automatically by your phone to make a payment',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 12),
            child: Text(
              'Detected Installed Apps',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (_apps != null) _discoverableAppsGrid(),
          Container(
            margin: EdgeInsets.only(top: 12, bottom: 12),
            child: Text(
              'Other Supported Apps (Cannot detect)',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (_apps != null) _nonDiscoverableAppsGrid(),
        ],
      ),
    );
  }

  GridView _discoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    for (var e in _apps!) {
      if (e.upiApplication.discoveryCustomScheme != null) {
        metaList.add(e);
      }
    }
    return _appsGrid(metaList);
  }

  GridView _nonDiscoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    for (var e in _apps!) {
      if (e.upiApplication.discoveryCustomScheme == null) {
        metaList.add(e);
      }
    }
    return _appsGrid(metaList);
  }

  GridView _appsGrid(List<ApplicationMeta> apps) {
    apps.sort((a, b) => a.upiApplication
        .getAppName()
        .toLowerCase()
        .compareTo(b.upiApplication.getAppName().toLowerCase()));

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.0,
      physics: NeverScrollableScrollPhysics(),
      children: apps
          .map(
            (it) => Card(
          elevation: 2,
          child: InkWell(
            onTap: Platform.isAndroid && !_isLoading
                ? () async => await _onTap(it)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: it.iconImage(40),
                  ),
                  SizedBox(height: 4),
                  Text(
                    it.upiApplication.getAppName(),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}

String? _validateUpiAddress(String value) {
  if (value.isEmpty) {
    return 'UPI VPA is required.';
  }
  if (!value.contains('@') || value.split('@').length != 2) {
    return 'Invalid UPI VPA format';
  }
  final parts = value.split('@');
  if (parts[0].isEmpty || parts[1].isEmpty) {
    return 'Invalid UPI VPA format';
  }
  return null;
}