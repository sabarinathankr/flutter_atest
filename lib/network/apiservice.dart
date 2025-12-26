import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/OrderError.dart';
import '../models/OrderSuccess.dart';

class RazorpayApiService {

  static const String _baseUrl = 'https://api.razorpay.com/v1/orders';

  static Future<dynamic> createOrder({
    required int amount,
    required String currency,
    required String receipt,
  }) async {

    final String keyId = 'rzp_live_Rv5HbFP3hL361H';
    final String keySecret = '5li3LAYUP6KW8gfAe5R7yfRm';

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('$keyId:$keySecret'))}';

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': basicAuth,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "amount": amount*100,
        "currency": currency,
        "receipt": receipt,
        "partial_payment": false,
      }),
    );

    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // ✅ Success
    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderSuccess.fromJson(responseData);
    }

    // ❌ Failure
    if (responseData.containsKey('error')) {
      return OrderError.fromJson(responseData['error']);
    }

    throw Exception('Unexpected response');
  }
}
