class OrderSuccess {
  final String id;
  final int amount;
  final String currency;
  final String status;

  OrderSuccess({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
  });

  factory OrderSuccess.fromJson(Map<String, dynamic> json) {
    return OrderSuccess(
      id: json['id'],
      amount: json['amount'],
      currency: json['currency'],
      status: json['status'],
    );
  }
}
