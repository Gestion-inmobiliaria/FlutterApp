import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:inmobiliaria_app/presentation/payment/models/purchase_metadata.dart';

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

  String buildContractHtml(PurchaseMetadata metadata) {
    final now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    return '''
<html>
  <body style="font-family: Arial, sans-serif; color: #222; line-height: 1.6; padding: 20px;">
    <h2 style="color: #00bcd4;">Contrato de Adquisición de Inmueble</h2>

    <h3>Datos del Cliente</h3>
    <p><strong>Nombre:</strong> ${metadata.clientName}</p>
    <p><strong>Documento:</strong> ${metadata.clientDocument}</p>
    ${metadata.clientPhone != null ? '<p><strong>Teléfono:</strong> ${metadata.clientPhone}</p>' : ''}
    ${metadata.clientEmail != null ? '<p><strong>Correo:</strong> ${metadata.clientEmail}</p>' : ''}

    <h3>Datos del Agente</h3>
    <p><strong>Nombre:</strong> ${metadata.agentName}</p>
    <p><strong>Documento:</strong> ${metadata.agentDocument}</p>

    <h3>Datos de la Transacción</h3>
    <p><strong>ID de Propiedad:</strong> ${metadata.propertyId}</p>
    <p><strong>Monto:</strong> \$${metadata.amount}</p>
    <p><strong>Fecha de Contrato:</strong> $today</p>

    <h3>Términos y Condiciones</h3>
    <ol>
      <li>Esta plataforma actúa como intermediario entre el cliente y la inmobiliaria.</li>
      <li>El pago realizado corresponde a la reserva o adquisición del inmueble seleccionado.</li>
      <li>No se aceptan reembolsos salvo que la propiedad ya no esté disponible.</li>
      <li>Los datos del cliente serán utilizados para la elaboración del contrato.</li>
      <li>El contrato digital será enviado al correo proporcionado.</li>
      <li>La disponibilidad está sujeta a transacciones simultáneas.</li>
    </ol>

    <br>
    <p><em>Este contrato fue generado automáticamente. No requiere firma física para validación preliminar.</em></p>
  </body>
</html>
''';
  }

  Future<void> registerContract(PurchaseMetadata metadata) async {
    final token = await _storage.read(key: 'jwt');
    if (token == null) throw Exception('Token JWT no encontrado');

    final url = Uri.parse('$_baseUrl/api/contracts');
    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 365));

    final htmlContent = buildContractHtml(metadata);

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "contractNumber": 123,
        "type": "VENTA",
        "status": "VIGENTE",
        "amount": metadata.amount,
        "startDate": now.toIso8601String(),
        "endDate": endDate.toIso8601String(),
        "clientName": metadata.clientName,
        "clientDocument": metadata.clientDocument,
        "clientPhone": metadata.clientPhone ?? '',
        "clientEmail": metadata.clientEmail ?? '',
        "agentName": metadata.agentName,
        "agentDocument": metadata.agentDocument,
        "contractContent": htmlContent,
        "contractFormat": "html",
        "propertyId": metadata.propertyId,
        "paymentMethodId": await _resolvePaymentMethodId(
          metadata.paymentMethod,
          token,
        ),
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Error al registrar el contrato: ${response.body}');
    }
  }

  Future<String> _resolvePaymentMethodId(
    String paymentMethodName,
    String token,
  ) async {
    final url = Uri.parse(
      '$_baseUrl/api/payment-method?attr=name&value=$paymentMethodName',
    );

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded['data'] != null && decoded['data'].isNotEmpty) {
        return decoded['data'][0]['id']; // suponiendo estructura estándar
      }
    }

    throw Exception('No se encontró el método de pago: $paymentMethodName');
  }
}
