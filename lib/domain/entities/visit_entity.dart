class Visit {
  final String id;
  final String title;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String propertyAddress;
  final String agentName;
  final DateTime startDate;
  final DateTime endDate;
  final VisitType type;
  final VisitStatus status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visit({
    required this.id,
    required this.title,
    required this.clientName,
    required this.clientPhone,
    required this.clientEmail,
    required this.propertyAddress,
    required this.agentName,
    required this.startDate,
    required this.endDate,
    required this.type,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}

enum VisitType { PRIMERA_VISITA, SEGUIMIENTO, CIERRE, INSPECCION }

enum VisitStatus { PROGRAMADA, COMPLETADA, CANCELADA }

extension VisitTypeExtension on VisitType {
  String get displayName {
    switch (this) {
      case VisitType.PRIMERA_VISITA:
        return 'Primera Visita';
      case VisitType.SEGUIMIENTO:
        return 'Seguimiento';
      case VisitType.CIERRE:
        return 'Cierre';
      case VisitType.INSPECCION:
        return 'Inspección';
    }
  }
}

extension VisitStatusExtension on VisitStatus {
  String get displayName {
    switch (this) {
      case VisitStatus.PROGRAMADA:
        return 'Programada';
      case VisitStatus.COMPLETADA:
        return 'Completada';
      case VisitStatus.CANCELADA:
        return 'Cancelada';
    }
  }
}
