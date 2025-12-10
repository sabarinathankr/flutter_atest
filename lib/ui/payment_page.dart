import 'dart:convert';
import 'dart:io';
import 'package:alphabet_navigation/alphabet_navigation.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';

import '../DataFile.dart';
import '../db_connection/DBConnections.dart';
import '../utils/app_constants.dart';
import '../utils/shared_preference.dart';

class PaymentsTab extends StatefulWidget {
  final Size screenSize;
  final bool isTablet;

  const PaymentsTab({
    super.key,
    required this.screenSize,
    this.isTablet = false,
  });

  @override
  State<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends State<PaymentsTab>   with WidgetsBindingObserver{
  bool isLoading = true;
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  List<UserTransactions> transactionList = [];
  final TextEditingController _amountController = TextEditingController();
  Set<int> expandedTiles = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getTransactionHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // This triggers when app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      getTransactionHistory(); // 👈 Call your method here
    }
  }


  Future<void> getTransactionHistory() async {
    setState(() => isLoading = true);

    DbConnections dbConnections = DbConnections();
    List<UserTransactions> list =
    await dbConnections.getAllTransactions(selectedYear, selectedMonth);

    setState(() {
      transactionList = list;
      isLoading = false;
    });
  }

  // -------------------------------
  // 🔹 Download Single Transaction PDF
  // -------------------------------
  Future<void> downloadTransactionPDF(UserTransactions txn) async {
    final pdf = pw.Document();

    final String statusText =
    txn.transactionStatus == "1" ? "Success" : "Failed";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text("Transaction Receipt",
                    style: pw.TextStyle(
                        fontSize: 22, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 16),
                pw.Text("Username: ${txn.username}"),
                pw.Text("Transaction ID: ${txn.transactionId}"),
                pw.Text("Amount: ₹${txn.transactionAmount}"),
                pw.Text("Created Time: ${txn.createdAt ?? '-'}"),
                pw.Text("Status: $statusText"),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/${txn.transactionId}.pdf");
    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }

  // -------------------------------
  // 🔹 Export All Transactions
  // -------------------------------
  void exportAllTransactions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Export Transactions"),
        content: const Text("Choose export format:"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              generatePDFFile();
            },
            child: const Text("PDF"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              generateExcelFile();
            },
            child: const Text("Excel"),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // 🔹 Generate PDF (All)
  // -------------------------------
  Future<void> generatePDFFile() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text("Transaction Report",
              style:
              pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: [
              "Username",
              "Transaction ID",
              "Amount (₹)",
              "Created Time",
              "Status"
            ],
            data: transactionList.map((txn) {
              final statusText =
              txn.transactionStatus == "1" ? "Success" : "Failed";
              return [
                txn.username,
                txn.transactionId,
                txn.transactionAmount,
                txn.createdAt ?? "-",
                statusText,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/All_Transactions.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  // -------------------------------
  // 🔹 Generate Excel (All)
  // -------------------------------
  Future<void> generateExcelFile() async {
    var excel = Excel.createExcel();
    Sheet sheet = excel['Transactions'];

    sheet.appendRow([
      "Username",
      "Transaction ID",
      "Amount (₹)",
      "Created Time",
      "Status"
    ]);

    for (var txn in transactionList) {
      final statusText =
      txn.transactionStatus == "1" ? "Success" : "Failed";
      sheet.appendRow([
        txn.username,
        txn.transactionId,
        txn.transactionAmount,
        txn.createdAt ?? "-",
        statusText,
      ]);
    }

    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/All_Transactions.xlsx";
    final fileBytes = excel.encode();
    final file = File(filePath);
    await file.writeAsBytes(fileBytes!);

    await OpenFilex.open(file.path);
  }

  Future<void> _openFilterDialog() async {
    int tempYear = selectedYear;
    int tempMonth = selectedMonth;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Month & Year"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Year picker
              DropdownButton<int>(
                value: tempYear,
                items: List.generate(6, (index) {
                  int year = DateTime.now().year - 2 + index;
                  return DropdownMenuItem(value: year, child: Text(year.toString()));
                }),
                onChanged: (value) {
                  if (value != null) {
                    tempYear = value;
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 10),
              // Month picker
              DropdownButton<int>(
                value: tempMonth,
                items: List.generate(12, (index) {
                  int month = index + 1;
                  return DropdownMenuItem(value: month, child: Text(month.toString()));
                }),
                onChanged: (value) {
                  if (value != null) {
                    tempMonth = value;
                    setState(() {});
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedYear = tempYear;
                  selectedMonth = tempMonth;
                  transactionList.clear();
                });
                Navigator.pop(context);
                getTransactionHistory(); // 🔄 Refresh list with new filters
              },
              child: const Text("Apply"),
            ),
          ],
        );
      },
    );
  }


  // -------------------------------
  // 🔹 UI BUILD
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    final isTablet = widget.isTablet;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterDialog,
            tooltip: "Filter by Month & Year",
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: exportAllTransactions,
            tooltip: "Export Transactions",
          ),
        ],
      ),

      // 🔹 BODY WITH PAY NOW AT BOTTOM
        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())     // 🔵 LOADING
                  : transactionList.isEmpty
                  ? const Center(                                      // 🔴 NO DATA
                child: Text(
                  "No transactions found",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
                  : ListView.builder(                                  // 🟢 SHOW LIST
                itemCount: transactionList.length,
                itemBuilder: (context, index) {
                  final txn = transactionList[index];
                  final statusText =
                  txn.transactionStatus == "1" ? "Success" : "Failed";

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: ExpansionTile(
                      title: Text(
                        "${txn.username}\nAmount: ₹${txn.transactionAmount}",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text("Status: $statusText\nTime: ${txn.createdAt ?? ''}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                        onPressed: () => downloadTransactionPDF(txn),
                      ),
                      children: [
                        _buildDetailRow("Transaction ID", txn.transactionId),
                        _buildDetailRow("Created Time", txn.createdAt ?? "-"),
                        _buildDetailRow("Amount", "₹${txn.transactionAmount}"),
                        _buildDetailRow("Status", txn.transactionStatus),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Pay Now section
            SafeArea(child: _buildPayNowSection(isTablet)),
          ],
        )

    );
  }

  // -------------------------------
  // 🔹 PAY NOW HANDLER
  // -------------------------------
  Future<void> _handlePayNow() async {
    final dataString = await SharedPreferenceHelper.getString(AppConstants.userData);

    if (dataString == null) {
      // show login warning...
      return;
    }

    setState(() => isLoading = true);   // 🔵 start loading

    final data = jsonDecode(dataString);

    Razorpaybl().openCheckout(
        _amountController.text,
        int.parse(data['MobileNumber']),
        data['Email'],
        data['FullName'],

            (bool success) async {   // 👈 CALLBACK HERE
          if (success) {
            print("Payment successful → Refreshing list");
            await getTransactionHistory();
          } else {
            print("Payment failed → Still refresh list");
            await getTransactionHistory();
          }

          setState(() => isLoading = false); // 🔴 stop loader
        }
    );
  }


  // -------------------------------
  // 🔹 PAY NOW UI SECTION
  // -------------------------------
  Widget _buildPayNowSection(bool isTablet) {
    return Container(
      constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _amountController,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.currency_rupee),
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _handlePayNow,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Pay Now'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isTablet ? 20 : 16,
                horizontal: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              "$label:",
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
}
