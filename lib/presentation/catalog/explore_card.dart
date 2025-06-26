import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:riserealestate/components/gap.dart';
// import 'package:riserealestate/constant/colors.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/property_detail_page.dart';
import 'package:inmobiliaria_app/presentation/gap.dart';
import 'package:inmobiliaria_app/presentation/constant/colors.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/favorite_bloc.dart';
import 'package:inmobiliaria_app/service_locator.dart';

class ExploreCard extends StatefulWidget {
  //   Tarjeta para explorar propiedades cercanas
  // Incluye imagen, título, calificación y ubicación
  // Tiene botón de "favorito" en la esquina superior derecha
  final String title, rating, location, path;
  final bool isHeart;
  final bool isNetworkImage;
  final Property? property;
  final String realStateName;
  
  // Lista de imágenes disponibles en assets para usar como fallback
  static const List<String> _assetImages = [
    'assets/images/property.jpg',
    'assets/images/property1.jpg',
    'assets/images/property2.jpg',
    'assets/images/product1.png',
    'assets/images/product2.png',
    'assets/images/product3.png',
    'assets/images/product4.png',
  ];
  
  const ExploreCard({
    Key? key,
    required this.location,
    required this.title,
    required this.rating,
    required this.path,
    required this.isHeart,
    this.isNetworkImage = true,
    this.property,
    this.realStateName = '',
  }) : super(key: key);

  @override
  State<ExploreCard> createState() => _ExploreCardState();
}

class _ExploreCardState extends State<ExploreCard> {
  @override
  void initState() {
    super.initState();
    
    // Verificar el estado inicial de favorito si tenemos una propiedad
    if (widget.property != null) {
      // Usar el Bloc del contexto padre después de que el widget esté construido
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          try {
            final favoriteBloc = context.read<FavoriteBloc>();
            favoriteBloc.add(CheckFavoriteStatus(widget.property!.id));
          } catch (e) {
            debugPrint('Error accessing FavoriteBloc: $e');
          }
        }
      });
    }
  }

  // Obtener una imagen de los assets basada en el hash del título
  String _getFallbackImage() {
    // Usar el hash del título para seleccionar una imagen consistente para la misma propiedad
    final int hashCode = widget.title.hashCode.abs();
    return ExploreCard._assetImages[hashCode % ExploreCard._assetImages.length];
  }

  void _toggleFavorite() {
    if (widget.property != null) {
      try {
        final favoriteBloc = context.read<FavoriteBloc>();
        final currentState = favoriteBloc.state;
        bool isCurrentlyFavorite = false;
        
        if (currentState is FavoriteLoaded) {
          isCurrentlyFavorite = currentState.favoriteStatus[widget.property!.id] ?? false;
        }
        
        favoriteBloc.add(ToggleFavorite(widget.property!.id, isCurrentlyFavorite));
      } catch (e) {
        debugPrint('Error toggling favorite: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al actualizar favoritos')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
              onTap: () {
        if (widget.property != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailPage(
                property: widget.property!,
                imagePath: widget.path,
                realStateName: widget.realStateName,
                isNetworkImage: widget.isNetworkImage,
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: AppColors.inputBackground,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen con corazón
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15),
                      ),
                      child: widget.isNetworkImage
                          ? Image(
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              image: NetworkImage(widget.path),
                              errorBuilder: (context, error, stackTrace) {
                                // Si hay error al cargar la imagen de red, usar una imagen de assets
                                return Image.asset(
                                  _getFallbackImage(),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                            )
                          : Image.asset(
                              widget.path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                // Si hay error al cargar la imagen de assets, usar otra imagen de assets
                                return Image.asset(
                                  ExploreCard._assetImages[0], // Usar la primera imagen como última opción
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                );
                              },
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: BlocBuilder<FavoriteBloc, FavoriteState>(
                      builder: (context, state) {
                        bool isFavorite = false;
                        
                        if (state is FavoriteLoaded && widget.property != null) {
                          isFavorite = state.favoriteStatus[widget.property!.id] ?? false;
                        }
                        
                        return GestureDetector(
                          onTap: _toggleFavorite,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor, // Siempre azul
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              isFavorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                              size: 20,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Información de la propiedad
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Precio y ubicación
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Precio con icono
                        Row(
                          children: [
                            const Icon(Icons.euro, color: Colors.amber, size: 14),
                            const SizedBox(width: 2),
                            Text(
                              widget.rating,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        
                        // Ubicación con icono
                        Expanded(
                          child: Row(
                            children: [
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.location_on,
                                color: AppColors.textPrimary,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  widget.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
