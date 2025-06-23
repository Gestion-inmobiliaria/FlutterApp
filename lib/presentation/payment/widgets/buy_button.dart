import 'package:flutter/material.dart';
import 'package:inmobiliaria_app/presentation/payment/services/stripe_service.dart';
import 'package:inmobiliaria_app/presentation/payment/models/purchase_metadata.dart';

class BuyButton extends StatelessWidget {
  final PurchaseMetadata metadata;

  const BuyButton({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.shopping_cart, color: Colors.blue, size: 24),
        title: const Text(
          'Comprar inmueble',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
        ),
        subtitle: const Text(
          'Pagar mediante Stripe',
          style: TextStyle(color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.blue,
          size: 16,
        ),
        onTap: () async {
          try {
            await StripeService().payWithCard(
              amount: metadata.amount,
              metadata: metadata.toMap(),
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Pago exitoso')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error en el pago: ${e.toString()}')),
            );
          }
        },
      ),
    );
  }
}
