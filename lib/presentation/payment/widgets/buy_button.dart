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
          final accepted = await showDialog<bool>(
            context: context,
            builder:
                (_) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: const Color(0xFF1E1E2E), // fondo oscuro
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Términos y Condiciones',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyanAccent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 300,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: SingleChildScrollView(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[200],
                                    height: 1.6,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '1. Naturaleza del servicio\n',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'Esta plataforma actúa como intermediario digital entre el cliente y la inmobiliaria o propietario.\nTodas las operaciones están sujetas a validación posterior por parte de la empresa.\n\n',
                                    ),
                                    TextSpan(
                                      text: '2. Confirmación de pago\n',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'El pago realizado corresponde a la reserva o adquisición del inmueble seleccionado.\nEl contrato será generado automáticamente tras la confirmación del pago.\n\n',
                                    ),
                                    TextSpan(
                                      text: '3. No reembolsable\n',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'Una vez completado el pago, no se aceptan reembolsos, salvo que la propiedad ya no esté disponible.\nEn tal caso, la inmobiliaria se compromete a contactar al cliente para ofrecer alternativas o reembolso.\n\n',
                                    ),
                                    TextSpan(
                                      text: '4. Datos personales\n',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'El cliente confirma que los datos ingresados (nombre, documento, contacto) son verdaderos y exactos.\nEstos datos se utilizarán para la elaboración del contrato.\n\n',
                                    ),
                                    TextSpan(
                                      text: '5. Entrega de documentos\n',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'El contrato digital sera enviado al correo.\nLa firma física o digital será solicitada según la modalidad legal vigente.\n\n',
                                    ),
                                    TextSpan(
                                      text: '6. Limitación de disponibilidad\n',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.cyanAccent,
                                      ),
                                    ),
                                    const TextSpan(
                                      text:
                                          'La propiedad podría ya no estar disponible si se realiza una transacción simultánea.\nEn ese caso se dará prioridad al primer pago confirmado.\n',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.redAccent,
                                  side: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                child: const Text('Cancelar'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  foregroundColor: Colors.black,
                                ),
                                child: const Text('Aceptar'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
          );

          if (accepted != true) return;

          try {
            final stripeService = StripeService();

            await stripeService.payWithCard(
              amount: metadata.amount,
              metadata: metadata.toMap(),
            );

            await stripeService.registerContract(metadata);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Compra realizada y contrato registrado'),
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('❌ Error: ${e.toString()}')));
          }
        },
      ),
    );
  }
}
