class PurchaseMetadata {
  final String propertyId;
  final String clientName;
  final String clientDocument;
  final String agentName;
  final String? clientPhone; // opcional
  final String? clientEmail; // opcional
  final String agentDocument;
  final String paymentMethod;
  final int amount;

  PurchaseMetadata({
    required this.propertyId,
    required this.clientName,
    required this.clientDocument,
    this.clientPhone,
    this.clientEmail,
    required this.agentName,
    required this.agentDocument,
    required this.paymentMethod,
    required this.amount,
  });

  Map<String, String> toMap() {
    return {
      'propertyId': propertyId,
      'clientName': clientName,
      'clientDocument': clientDocument,
      'clientPhone': clientPhone ?? '',
      'clientEmail': clientEmail ?? '',
      'agentName': agentName,
      'agentDocument': agentDocument,
      'paymentMethod': paymentMethod,
      'amount': amount.toString(),
    };
  }
}
