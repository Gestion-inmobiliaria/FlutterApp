import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  final _baseUrl = dotenv.env['URL_BACKEND']!;
  final _storage = const FlutterSecureStorage();

  Future<void> payWithCard({
    required int amount,
    required Map<String, String> metadata,
  }) async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) throw Exception('Token JWT no encontrado');

    final url = Uri.parse('$_baseUrl/api/stripe/create-payment-intent');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'amount': amount, 'metadata': metadata}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al obtener clientSecret de Stripe');
    }

    final clientSecret = jsonDecode(response.body)['clientSecret'];

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Tu Inmobiliaria',
        style: ThemeMode.light,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }
}
