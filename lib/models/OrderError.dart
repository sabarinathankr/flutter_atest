class OrderError {
  final String code;
  final String description;
  final String field;

  OrderError({
    required this.code,
    required this.description,
    required this.field,
  });

  factory OrderError.fromJson(Map<String, dynamic> json) {
    return OrderError(
      code: json['code'],
      description: json['description'],
      field: json['field'] ?? '',
    );
  }
}
