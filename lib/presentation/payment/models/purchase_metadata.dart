class PurchaseMetadata {
  final String propertyId;
  final String clientName;
  final String clientDocument;
  final String agentName;
  final String agentDocument;
  final String paymentMethod;
  final int amount;

  PurchaseMetadata({
    required this.propertyId,
    required this.clientName,
    required this.clientDocument,
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
      'agentName': agentName,
      'agentDocument': agentDocument,
      'paymentMethod': paymentMethod,
      'amount': amount.toString(),
    };
  }
}
