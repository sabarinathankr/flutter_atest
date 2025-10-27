import 'package:mongo_dart/mongo_dart.dart';

class UserTransactions{
  ObjectId? id;
  String Username;
  String TransactionAmount;
  String Transactionid;

  String Transactionmode;
  String TransactionStatus;
  UserTransactions({
    this.id,
    required this.Username,
    required this.TransactionAmount,
    required this.Transactionid,

    required this.Transactionmode,
    required this.TransactionStatus,

  });
  factory UserTransactions.fromMap(Map<String, dynamic> map) {

    return UserTransactions(
        id: map['_id'],
        Username: map['Username'],
        TransactionAmount: map['TransactionAmount'],
        Transactionid: map['Transactionid'],

        Transactionmode: map['Transactionmode'], TransactionStatus:map['TransactionStatus']

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
      'username': Username,
      'transactionAmount': TransactionAmount,
      'transactionId': Transactionid,
      'transactionDate': formattedDate,
      'transactionTime': timeOnly,
      'transactionMode': Transactionmode,
      'transactionStatus': TransactionStatus,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}