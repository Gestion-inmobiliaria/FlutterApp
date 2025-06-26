import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/data/sources/property_remote_datasource.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_bloc.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/catalog_page.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_bloc.dart';
import 'package:inmobiliaria_app/presentation/home/bloc/realstate_state.dart';

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Inmobiliarias disponibles',
            style: TextStyle(
              color: Color(0xFF070C19),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.5,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<RealStateBloc, RealStateState>(
            builder: (context, state) {
              if (state is RealStateLoaded) {
                final items = state.realStates;

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      children: const [
                        SizedBox(height: 40),
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 12),
                        Text('No se encontraron inmobiliarias'),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildRecommendationCard(
                      context: context,
                      realStateId: item.id,
                      company: item.name,
                      location: item.address ?? 'Sin dirección',
                      role: 'Ver inmuebles disponibles',
                      level: 'Popular',
                      type: 'Activa',
                      mode: 'Online',
                    );
                  },
                );
              }

              if (state is RealStateLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required String realStateId,
    required String company,
    required String location,
    required String role,
    required String level,
    required String type,
    required String mode,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFECF0FC),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0716264E),
            blurRadius: 20,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.25,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCFDAF7),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF18ACFE), Color(0xFF0163E0)],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF070C19),
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8F9298),
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_vert),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            role,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF070C19),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [_jobTag(level), _jobTag(type), _jobTag(mode)]),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ViewPropertiesButton(
                realStateId: realStateId,
                realStateName: company,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _jobTag(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF8F9298),
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _ViewPropertiesButton extends StatefulWidget {
  final String realStateId;
  final String realStateName;

  const _ViewPropertiesButton({
    required this.realStateId,
    required this.realStateName,
  });

  @override
  State<_ViewPropertiesButton> createState() => _ViewPropertiesButtonState();
}

class _ViewPropertiesButtonState extends State<_ViewPropertiesButton> {
  bool _isLoading = false;

  void _navigateToPropertiesCatalog() async {
    // Evitar múltiples clics mientras se procesa
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 300)); // Simular carga

      if (!mounted) return;

      // Navegar a la página de catálogo
      Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (context) => BlocProvider(
                create:
                    (context) => PropertyBloc(
                      propertyDatasource: PropertyRemoteDatasource(),
                    ),
                child: CatalogPage(
                  realStateId: widget.realStateId,
                  realStateName: widget.realStateName,
                ),
              ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Mostrar un snackbar en caso de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar propiedades: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Asegurarse de restaurar el estado si el widget sigue montado
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _navigateToPropertiesCatalog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF3F6CDF),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Text(
                  'Ver Inmuebles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                ),
      ),
    );
  }
}
