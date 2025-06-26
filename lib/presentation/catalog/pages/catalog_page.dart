import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_bloc.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_event.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/property_state.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/favorite_bloc.dart';
import 'package:inmobiliaria_app/presentation/catalog/explore_card.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/filter_page.dart';
import 'package:inmobiliaria_app/presentation/constant/colors.dart';
import 'package:inmobiliaria_app/presentation/maps/pages/map_view_page.dart';
import 'package:inmobiliaria_app/test_login.dart';

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
  bool _isMapView = false;
  bool _showFavorites = false;

  final TextEditingController _searchController = TextEditingController();
  bool _isRetrying = false;
  PropertyFilter _currentFilter = const PropertyFilter();

  // Lista de imágenes disponibles en assets
  final List<String> _assetImages = [
    'assets/images/property.jpg',
    'assets/images/property1.jpg',
    'assets/images/property2.jpg',
    'assets/images/product1.png',
    'assets/images/product2.png',
    'assets/images/product3.png',
    'assets/images/product4.png',
  ];

  @override
  void initState() {
    super.initState();

    // Solo para testing - simular login automático
    _initializeWithTestAuth();

    // Cargar propiedades al iniciar
    _loadProperties();
    
    // Cargar estado inicial de favoritos para mostrar correctamente los toggles
    _loadInitialFavoriteState();

    // Escuchar cambios en la búsqueda
    _searchController.addListener(() {
      context.read<PropertyBloc>().add(
        SearchProperties(_searchController.text),
      );
    });
  }
  
  void _loadInitialFavoriteState() {
    // Cargar todos los favoritos para tener el estado inicial
    context.read<FavoriteBloc>().add(LoadFavorites());
  }

  // Solo para testing - simular autenticación
  Future<void> _initializeWithTestAuth() async {
    try {
      final hasToken = await TestAuthHelper.hasToken();
      if (!hasToken) {
        await TestAuthHelper.simulateLogin();
        debugPrint('🔥 Token temporal creado para testing de favoritos');
      }
    } catch (e) {
      debugPrint('🔥 Error al simular login: $e');
    }
  }

  void _loadProperties() {
    context.read<PropertyBloc>().add(
      LoadProperties(
        realStateId: widget.realStateId,
        realStateName: widget.realStateName,
      ),
    );
  }

  // Obtener una imagen aleatoria de los assets
  String _getAssetImage(int index) {
    return _assetImages[index % _assetImages.length];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mostrar el diálogo de filtros
  Future<void> _showFilterDialog() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FilterPage(initialFilter: _currentFilter),
      ),
    );

    if (result != null && result is PropertyFilter) {
      setState(() {
        _currentFilter = result;
      });

      if (result.isActive) {
        context.read<PropertyBloc>().add(ApplyFilters(result));
      } else {
        context.read<PropertyBloc>().add(ClearFilters());
      }
    }
  }

  // Quitar filtros
  void _clearFilters() {
    setState(() {
      _currentFilter = const PropertyFilter();
    });
    _searchController.text = ''; // Limpiar también la búsqueda
    context.read<PropertyBloc>().add(ClearFilters());
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: ToggleButtons(
                isSelected: [
                  !_isMapView && !_showFavorites,
                  _isMapView && !_showFavorites,
                  _showFavorites,
                ],
                onPressed: (int index) {
                  setState(() {
                    if (index == 0) {
                      _isMapView = false;
                      _showFavorites = false;
                    } else if (index == 1) {
                      _isMapView = true;
                      _showFavorites = false;
                    } else {
                      _isMapView = false;
                      _showFavorites = true;
                    }
                  });

                  if (index == 1) {
                    // Si cambia a la vista de mapa, cargar solo propiedades con lat/lng
                    context.read<PropertyBloc>().add(
                      LoadPropertiesWithLocation(
                        realStateId: widget.realStateId,
                      ),
                    );
                  } else if (index == 2) {
                    // Si cambia a favoritos, cargar TODOS los favoritos del usuario
                    context.read<FavoriteBloc>().add(
                      LoadFavorites(), // Sin realStateId para cargar todos
                    );
                  } else {
                    // Si vuelve al catálogo, cargar todas las propiedades normales
                    _loadProperties();
                  }
                },

                borderRadius: BorderRadius.circular(16),
                selectedColor: Colors.white,
                fillColor: AppColors.primaryColor,
                color: Colors.black87,
                splashColor: AppColors.primaryColor.withOpacity(0.2),
                borderWidth: 0,
                constraints: const BoxConstraints(minHeight: 40, minWidth: 80),
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Catálogo"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Mapa"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text("Favoritos"),
                  ),
                ],
              ),
            ),
          ),

          // Barra de búsqueda y filtros
          if (!_isMapView)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Barra de búsqueda
                  Expanded(
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
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  BlocBuilder<PropertyBloc, PropertyState>(
                    builder: (context, state) {
                        final hasActiveFilters =
                          state is PropertyLoaded &&
                          state.activeFilter != null &&
                          state.activeFilter!.isActive;

                      return ElevatedButton(
                        onPressed:
                            hasActiveFilters
                                ? _clearFilters
                                : _showFilterDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              hasActiveFilters
                                  ? Colors.red.shade50
                                  : AppColors.primaryColor.withOpacity(0.1),
                          foregroundColor:
                              hasActiveFilters
                                  ? Colors.red
                                  : AppColors.primaryColor,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasActiveFilters
                                  ? Icons.filter_list_off
                                  : Icons.filter_list,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(hasActiveFilters ? 'Sin filtros' : 'Filtros'),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

          // Indicador de filtros activos
          BlocBuilder<PropertyBloc, PropertyState>(
            builder: (context, state) {
              if (state is PropertyLoaded &&
                  state.activeFilter != null &&
                  state.activeFilter!.isActive) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        size: 16,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Filtros: ${state.activeFilter.toString()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _clearFilters,
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Listado de propiedades
          Expanded(
            child: _showFavorites
                ? BlocBuilder<FavoriteBloc, FavoriteState>(
                    builder: (context, favoriteState) {
                      return _buildFavoritesContent(favoriteState);
                    },
                  )
                : BlocBuilder<PropertyBloc, PropertyState>(
                    builder: (context, state) {
                      if (_isMapView) {
                        if (state is PropertyLoaded) {
                          return PropertyMapView(
                            properties: state.filteredProperties,
                          );
                        } else if (state is PropertyLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else {
                          return const Center(
                            child: Text(
                              'No se pudieron cargar las propiedades para el mapa.',
                            ),
                          );
                        }
                      }

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
                              const Icon(
                                Icons.error_outline,
                                size: 60,
                                color: Colors.red,
                              ),
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32.0,
                                ),
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
                                      Future.delayed(
                                        const Duration(seconds: 2),
                                        () {
                                          if (mounted) {
                                            setState(() {
                                              _isRetrying = false;
                                            });
                                          }
                                        },
                                      );
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
                        final displayProperties = state.filteredProperties;

                        if (displayProperties.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.search_off,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No se encontraron propiedades',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.activeFilter != null &&
                                          state.activeFilter!.isActive
                                      ? 'Ninguna propiedad coincide con los filtros aplicados'
                                      : 'No hay propiedades disponibles en este momento',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 24),
                                if (state.activeFilter != null &&
                                    state.activeFilter!.isActive)
                                  ElevatedButton(
                                    onPressed: _clearFilters,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Quitar filtros'),
                                  ),
                              ],
                            ),
                          );
                        }
                        
                        // Cargar estado de favoritos para las propiedades visibles
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final propertyIds = displayProperties.map((p) => p.id).toList();
                          context.read<FavoriteBloc>().add(LoadFavoriteStatus(propertyIds));
                        });

                        return Column(
                          children: [
                            // Banner de aviso de datos de muestra si es error de autenticación
                            if (state.isAuthError)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.amber.shade800,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.info_outline,
                                          color: Colors.amber,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            state.authErrorMessage ??
                                                'Mostrando propiedades de ejemplo',
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Funcionalidad de inicio de sesión pendiente',
                                            ),
                                            backgroundColor: Colors.amber,
                                          ),
                                        );
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            Colors.amber.shade800,
                                        side: BorderSide(
                                          color: Colors.amber.shade800,
                                        ),
                                      ),
                                      child: const Text('Iniciar sesión'),
                                    ),
                                  ],
                                ),
                              ),

                            // Contador de resultados
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Mostrando ${displayProperties.length} propiedades',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Grid de propiedades
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        childAspectRatio: 0.85,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                      ),
                                  itemCount: displayProperties.length,
                                  itemBuilder: (context, index) {
                                    final property = displayProperties[index];

                                    // Obtener imagen desde el JSON (primera disponible)
                                    final String? imageUrl =
                                        property.imagenes != null &&
                                                property.imagenes!.isNotEmpty
                                            ? property.imagenes!.first
                                            : null;

                                    // Extraer ubicación
                                    final location =
                                        property.ubicacion?['direccion'] ??
                                        'Sin ubicación';

                                    return ExploreCard(
                                      title: property.descripcion,
                                      rating: '${property.precio}€',
                                      location: location.toString(),
                                      path:
                                          imageUrl ??
                                          _getAssetImage(
                                            index,
                                          ), // Usar una imagen de los assets como fallback
                                      isHeart: false,
                                      isNetworkImage: imageUrl != null,
                                      property: property,
                                      realStateName: widget.realStateName,
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

  Widget _buildFavoritesContent(FavoriteState favoriteState) {
    if (favoriteState is FavoriteLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando favoritos...'),
          ],
        ),
      );
    }

    if (favoriteState is FavoriteError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar favoritos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                favoriteState.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<FavoriteBloc>().add(
                  LoadFavorites(), // Sin realStateId para cargar todos
                );
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
          ],
        ),
      );
    }

    if (favoriteState is FavoriteLoaded) {
      final favorites = favoriteState.favorites;

      if (favorites.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No tienes favoritos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega propiedades a favoritos para verlas aquí',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showFavorites = false;
                  });
                  _loadProperties();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Explorar propiedades'),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Contador de resultados
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Tienes ${favorites.length} propiedades favoritas',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Grid de favoritos
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final property = favorites[index];

                  // Obtener imagen desde el JSON (primera disponible)
                  final String? imageUrl =
                      property.imagenes != null && property.imagenes!.isNotEmpty
                          ? property.imagenes!.first
                          : null;

                  // Extraer ubicación
                  final location =
                      property.ubicacion?['direccion'] ?? 'Sin ubicación';

                  return ExploreCard(
                    title: property.descripcion,
                    rating: '${property.precio}€',
                    location: location.toString(),
                    path: imageUrl ?? _getAssetImage(index),
                    isHeart: true, // Siempre true en favoritos
                    isNetworkImage: imageUrl != null,
                    property: property,
                    realStateName: widget.realStateName,
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    // Estado inicial
    return const Center(child: Text('Cargando...'));
  }
}
