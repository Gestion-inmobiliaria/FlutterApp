import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/domain/entities/visit_entity.dart';

// Events
abstract class VisitEvent {}

class LoadVisits extends VisitEvent {}

class AddVisit extends VisitEvent {
  final Visit visit;
  AddVisit(this.visit);
}

class LoadVisitsByDate extends VisitEvent {
  final DateTime date;
  LoadVisitsByDate(this.date);
}

// States
abstract class VisitState {}

class VisitInitial extends VisitState {}

class VisitLoading extends VisitState {}

class VisitLoaded extends VisitState {
  final List<Visit> visits;
  final List<Visit> upcomingVisits;

  VisitLoaded({required this.visits, required this.upcomingVisits});
}

class VisitError extends VisitState {
  final String message;
  VisitError(this.message);
}

// Bloc
class VisitBloc extends Bloc<VisitEvent, VisitState> {
  List<Visit> _allVisits = [];

  VisitBloc() : super(VisitInitial()) {
    on<LoadVisits>(_onLoadVisits);
    on<AddVisit>(_onAddVisit);
    on<LoadVisitsByDate>(_onLoadVisitsByDate);
  }

  void _onLoadVisits(LoadVisits event, Emitter<VisitState> emit) {
    try {
      _allVisits = _getMockVisits();
      final now = DateTime.now();
      final upcomingVisits =
          _allVisits
              .where(
                (visit) =>
                    visit.startDate.isAfter(now) &&
                    visit.status == VisitStatus.PROGRAMADA,
              )
              .toList()
            ..sort((a, b) => a.startDate.compareTo(b.startDate));

      emit(VisitLoaded(visits: _allVisits, upcomingVisits: upcomingVisits));
    } catch (e) {
      emit(VisitError('Error al cargar visitas: $e'));
    }
  }

  void _onAddVisit(AddVisit event, Emitter<VisitState> emit) {
    try {
      _allVisits.add(event.visit);
      final now = DateTime.now();
      final upcomingVisits =
          _allVisits
              .where(
                (visit) =>
                    visit.startDate.isAfter(now) &&
                    visit.status == VisitStatus.PROGRAMADA,
              )
              .toList()
            ..sort((a, b) => a.startDate.compareTo(b.startDate));

      emit(VisitLoaded(visits: _allVisits, upcomingVisits: upcomingVisits));
    } catch (e) {
      emit(VisitError('Error al agregar visita: $e'));
    }
  }

  void _onLoadVisitsByDate(LoadVisitsByDate event, Emitter<VisitState> emit) {
    try {
      final visitsForDate =
          _allVisits.where((visit) {
            return visit.startDate.year == event.date.year &&
                visit.startDate.month == event.date.month &&
                visit.startDate.day == event.date.day;
          }).toList();

      final now = DateTime.now();
      final upcomingVisits =
          _allVisits
              .where(
                (visit) =>
                    visit.startDate.isAfter(now) &&
                    visit.status == VisitStatus.PROGRAMADA,
              )
              .toList()
            ..sort((a, b) => a.startDate.compareTo(b.startDate));

      emit(VisitLoaded(visits: visitsForDate, upcomingVisits: upcomingVisits));
    } catch (e) {
      emit(VisitError('Error al cargar visitas por fecha: $e'));
    }
  }

  List<Visit> _getMockVisits() {
    return [
      // VISITAS FUTURAS
      Visit(
        id: '1',
        title: 'Visita - Juan Pérez',
        clientName: 'Juan Pérez García',
        clientPhone: '+591 70123456',
        clientEmail: 'juan.perez@email.com',
        propertyAddress: 'Av. Arce #2354, Zona San Jorge',
        agentName: 'María García',
        startDate: DateTime(2025, 6, 27, 10, 0),
        endDate: DateTime(2025, 6, 27, 11, 0),
        type: VisitType.PRIMERA_VISITA,
        status: VisitStatus.PROGRAMADA,
        notes: 'Cliente interesado en departamento de 2 dormitorios',
        createdAt: DateTime(2025, 6, 24, 8, 0),
        updatedAt: DateTime(2025, 6, 24, 8, 0),
      ),
      Visit(
        id: '2',
        title: 'Visita - Ana López',
        clientName: 'Ana López Mendoza',
        clientPhone: '+591 70987654',
        clientEmail: 'ana.lopez@email.com',
        propertyAddress: 'Calle 21 de Calacoto #456',
        agentName: 'Carlos Rodríguez',
        startDate: DateTime(2025, 6, 28, 14, 30),
        endDate: DateTime(2025, 6, 28, 15, 30),
        type: VisitType.SEGUIMIENTO,
        status: VisitStatus.PROGRAMADA,
        notes: 'Segunda visita, cliente muy interesado',
        createdAt: DateTime(2025, 6, 24, 9, 0),
        updatedAt: DateTime(2025, 6, 24, 9, 0),
      ),
      Visit(
        id: '5',
        title: 'Visita - Roberto Silva',
        clientName: 'Roberto Silva Mamani',
        clientPhone: '+591 70333444',
        clientEmail: 'roberto.silva@email.com',
        propertyAddress: 'Zona Sur, Calle 15 #789',
        agentName: 'Laura Fernández',
        startDate: DateTime(2025, 6, 30, 16, 0),
        endDate: DateTime(2025, 6, 30, 17, 0),
        type: VisitType.CIERRE,
        status: VisitStatus.PROGRAMADA,
        notes: 'Cliente listo para firmar contrato',
        createdAt: DateTime(2025, 6, 25, 10, 0),
        updatedAt: DateTime(2025, 6, 25, 10, 0),
      ),
      Visit(
        id: '6',
        title: 'Visita - Carmen Flores',
        clientName: 'Carmen Flores Quispe',
        clientPhone: '+591 70555666',
        clientEmail: 'carmen.flores@email.com',
        propertyAddress: 'Sopocachi, Av. 20 de Octubre #321',
        agentName: 'Miguel Torres',
        startDate: DateTime(2025, 7, 2, 11, 0),
        endDate: DateTime(2025, 7, 2, 12, 0),
        type: VisitType.INSPECCION,
        status: VisitStatus.PROGRAMADA,
        notes: 'Inspección técnica de la propiedad',
        createdAt: DateTime(2025, 6, 25, 15, 0),
        updatedAt: DateTime(2025, 6, 25, 15, 0),
      ),
      // VISITAS PASADAS
      Visit(
        id: '3',
        title: 'Visita - Pedro Martín',
        clientName: 'Pedro Martín Silva',
        clientPhone: '+591 70555444',
        clientEmail: 'pedro.martin@email.com',
        propertyAddress: 'Zona Sur, Calle 15 #789',
        agentName: 'Laura Fernández',
        startDate: DateTime(2025, 6, 23, 16, 0),
        endDate: DateTime(2025, 6, 23, 17, 0),
        type: VisitType.CIERRE,
        status: VisitStatus.COMPLETADA,
        notes: 'Visita completada exitosamente, cliente decidió comprar',
        createdAt: DateTime(2025, 6, 22, 10, 0),
        updatedAt: DateTime(2025, 6, 23, 17, 0),
      ),
      Visit(
        id: '4',
        title: 'Visita - Sandra Choque',
        clientName: 'Sandra Choque Mamani',
        clientPhone: '+591 70111222',
        clientEmail: 'sandra.choque@email.com',
        propertyAddress: 'Sopocachi, Av. 20 de Octubre #321',
        agentName: 'Miguel Torres',
        startDate: DateTime(2025, 6, 22, 11, 0),
        endDate: DateTime(2025, 6, 22, 12, 0),
        type: VisitType.PRIMERA_VISITA,
        status: VisitStatus.CANCELADA,
        notes: 'Cliente canceló por motivos personales',
        createdAt: DateTime(2025, 6, 21, 15, 0),
        updatedAt: DateTime(2025, 6, 22, 10, 30),
      ),
    ];
  }
}
