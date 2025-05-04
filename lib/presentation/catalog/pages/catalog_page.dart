import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_bloc.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_event.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_state.dart';
import 'package:inmobiliaria_app/presentation/catalog/explore_card.dart';
import 'package:inmobiliaria_app/presentation/constant/colors.dart';

class CatalogPage extends StatefulWidget {
  final String realStateId;
  final String realStateName;

  const CatalogPage({
    Key? key,
    required this.realStateId,
    required this.realStateName,
  }) : super(key: key);

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    // Cargar propiedades al iniciar
    _loadProperties();

    // Escuchar cambios en la búsqueda
    _searchController.addListener(() {
      context.read<PropertyBloc>().add(SearchProperties(_searchController.text));
    });
  }

  void _loadProperties() {
    context.read<PropertyBloc>().add(LoadProperties(
          realStateId: widget.realStateId,
          realStateName: widget.realStateName,
        ));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.realStateName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar propiedades...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.inputBackground,
              ),
            ),
          ),
          
          // Listado de propiedades
          Expanded(
            child: BlocBuilder<PropertyBloc, PropertyState>(
              builder: (context, state) {
                if (state is PropertyLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Cargando propiedades...'),
                      ],
                    ),
                  );
                }
                
                if (state is PropertyError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Error al cargar propiedades',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _isRetrying
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isRetrying = true;
                                  });
                                  _loadProperties();
                                  Future.delayed(const Duration(seconds: 2), () {
                                    if (mounted) {
                                      setState(() {
                                        _isRetrying = false;
                                      });
                                    }
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Reintentar'),
                              ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Volver'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (state is PropertyLoaded) {
                  final properties = state.properties;
                  
                  if (properties.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_work_outlined, size: 60, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No hay propiedades disponibles',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Esta inmobiliaria no tiene propiedades en este momento',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    children: [
                      // Banner de aviso de datos de muestra si es error de autenticación
                      if (state.isAuthError)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade800, width: 1),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      state.authErrorMessage ?? 'Mostrando propiedades de ejemplo',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton(
                                onPressed: () {
                                  // Aquí navegaríamos a la página de login
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Funcionalidad de inicio de sesión pendiente'),
                                      backgroundColor: Colors.amber,
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.amber.shade800,
                                  side: BorderSide(color: Colors.amber.shade800),
                                ),
                                child: const Text('Iniciar sesión'),
                              ),
                            ],
                          ),
                        ),
                      
                      // Grid de propiedades
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: properties.length,
                            itemBuilder: (context, index) {
                              final property = properties[index];
                              final imageUrl = property.imagenes != null && property.imagenes!.isNotEmpty
                                  ? property.imagenes!.first
                                  : 'https://via.placeholder.com/300x200?text=Sin+Imagen';
                              
                              // Extraer información de ubicación
                              final location = property.ubicacion?['direccion'] ?? 'Sin ubicación';
                              
                              return ExploreCard(
                                title: property.descripcion,
                                rating: '${property.precio}€',
                                location: location.toString(),
                                path: imageUrl,
                                isHeart: false,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
} 