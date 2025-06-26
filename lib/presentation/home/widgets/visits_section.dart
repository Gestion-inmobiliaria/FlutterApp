import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/domain/entities/visit_entity.dart';
import 'package:inmobiliaria_app/presentation/visits/bloc/visitas_bloc.dart';
import 'package:inmobiliaria_app/presentation/visits/pages/calendar_page.dart';

class VisitsSection extends StatelessWidget {
  const VisitsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Próximas Visitas',
                style: TextStyle(
                  color: Color(0xFF070C19),
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  fontFamily: 'Inter',
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => BlocProvider.value(
                            value: context.read<VisitBloc>(),
                            child: const CalendarPage(),
                          ),
                    ),
                  );
                },
                child: const Text(
                  'Ver calendario',
                  style: TextStyle(
                    color: Color(0xFF3F6CDF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<VisitBloc, VisitState>(
            builder: (context, state) {
              if (state is VisitLoaded) {
                final upcomingVisits = state.upcomingVisits.take(3).toList();

                if (upcomingVisits.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children:
                      upcomingVisits
                          .map((visit) => _buildVisitCard(visit))
                          .toList(),
                );
              }

              if (state is VisitLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return _buildEmptyState();
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => BlocProvider.value(
                          value: context.read<VisitBloc>(),
                          child: const CalendarPage(),
                        ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F6CDF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Agendar Nueva Visita',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFECF0FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(Icons.calendar_month, size: 48, color: Color(0xFF3F6CDF)),
          SizedBox(height: 12),
          Text(
            'No hay visitas programadas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF070C19),
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Agenda tu primera visita',
            style: TextStyle(fontSize: 14, color: Color(0xFF8F9298)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(Visit visit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECF0FC),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(width: 4, color: _getStatusColor(visit.type)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  visit.clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF070C19),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(visit.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  visit.type.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _getStatusColor(visit.type),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  visit.propertyAddress,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                '${_formatDate(visit.startDate)} - ${_formatTime(visit.startDate)}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(VisitType type) {
    switch (type) {
      case VisitType.PRIMERA_VISITA:
        return const Color(0xFF4CAF50);
      case VisitType.SEGUIMIENTO:
        return const Color(0xFF2196F3);
      case VisitType.CIERRE:
        return const Color(0xFFFF9800);
      case VisitType.INSPECCION:
        return const Color(0xFF9C27B0);
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
