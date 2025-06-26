import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/domain/entities/visit_entity.dart';
import 'package:inmobiliaria_app/presentation/visits/bloc/visitas_bloc.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendario de Visitas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          _buildCalendarGrid(),
          _buildVisitsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddVisitDialog(),
        backgroundColor: const Color(0xFF3F6CDF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = DateTime(
                  selectedDate.year,
                  selectedDate.month - 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            _getMonthYear(selectedDate),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedDate = DateTime(
                  selectedDate.year,
                  selectedDate.month + 1,
                );
              });
            },
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Días de la semana
          Row(
            children:
                ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
          // Grid de días
          _buildDaysGrid(),
        ],
      ),
    );
  }

  Widget _buildDaysGrid() {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final lastDayOfMonth = DateTime(
      selectedDate.year,
      selectedDate.month + 1,
      0,
    );
    final firstWeekday = firstDayOfMonth.weekday % 7;

    List<Widget> dayWidgets = [];

    // Días vacíos al inicio
    for (int i = 0; i < firstWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox()));
    }

    // Días del mes
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(selectedDate.year, selectedDate.month, day);
      dayWidgets.add(_buildDayWidget(date));
    }

    // Organizar en filas de 7
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Row(
          children: dayWidgets.sublist(i, (i + 7).clamp(0, dayWidgets.length)),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayWidget(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, selectedDate);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedDate = date;
          });
          context.read<VisitBloc>().add(LoadVisitsByDate(date));
        },
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? const Color(0xFF3F6CDF)
                    : isToday
                    ? const Color(0xFF3F6CDF).withOpacity(0.1)
                    : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              date.day.toString(),
              style: TextStyle(
                color:
                    isSelected
                        ? Colors.white
                        : isToday
                        ? const Color(0xFF3F6CDF)
                        : Colors.black,
                fontWeight:
                    isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisitsList() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<VisitBloc, VisitState>(
          builder: (context, state) {
            if (state is VisitLoaded) {
              final visitsForDate = state.visits;

              if (visitsForDate.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay visitas para ${_formatDate(selectedDate)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Visitas para ${_formatDate(selectedDate)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: visitsForDate.length,
                      itemBuilder: (context, index) {
                        final visit = visitsForDate[index];
                        return _buildVisitCard(visit);
                      },
                    ),
                  ),
                ],
              );
            }

            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildVisitCard(Visit visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
          ),
        ],
        border: Border(
          left: BorderSide(width: 4, color: _getStatusColor(visit.status)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_formatTime(visit.startDate)} - ${_formatTime(visit.endDate)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F6CDF),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(visit.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visit.status.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(visit.status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            visit.clientName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            visit.propertyAddress,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            'Agente: ${visit.agentName}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          if (visit.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              visit.notes,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddVisitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nueva Visita'),
          content: const Text(
            'Funcionalidad de demostración:\n\n'
            'En una implementación completa, aquí se mostraría un formulario para:\n'
            '• Seleccionar cliente\n'
            '• Elegir propiedad\n'
            '• Definir fecha y hora\n'
            '• Asignar agente\n'
            '• Agregar notas',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Agregar visita mock
                final newVisit = Visit(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: 'Nueva Visita - Demo',
                  clientName: 'Cliente Demo',
                  clientPhone: '+591 70000000',
                  clientEmail: 'demo@email.com',
                  propertyAddress: 'Propiedad Demo',
                  agentName: 'Agente Demo',
                  startDate: selectedDate.add(const Duration(hours: 10)),
                  endDate: selectedDate.add(const Duration(hours: 11)),
                  type: VisitType.PRIMERA_VISITA,
                  status: VisitStatus.PROGRAMADA,
                  notes: 'Visita de demostración',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                context.read<VisitBloc>().add(AddVisit(newVisit));
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visita demo agregada'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F6CDF),
              ),
              child: const Text('Agregar Demo'),
            ),
          ],
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthYear(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(VisitStatus status) {
    switch (status) {
      case VisitStatus.PROGRAMADA:
        return const Color(0xFF4CAF50);
      case VisitStatus.COMPLETADA:
        return const Color(0xFF2196F3);
      case VisitStatus.CANCELADA:
        return const Color(0xFFF44336);
    }
  }
}
