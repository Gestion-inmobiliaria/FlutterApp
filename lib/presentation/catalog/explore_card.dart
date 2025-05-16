import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:riserealestate/components/gap.dart';
// import 'package:riserealestate/constant/colors.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/presentation/catalog/pages/property_detail_page.dart';
import 'package:inmobiliaria_app/presentation/gap.dart';
import 'package:inmobiliaria_app/presentation/constant/colors.dart';

class ExploreCard extends StatelessWidget {
  //   Tarjeta para explorar propiedades cercanas
  // Incluye imagen, título, calificación y ubicación
  // Tiene botón de "favorito" en la esquina superior derecha
  final String title, rating, location, path;
  final bool isHeart;
  final bool isNetworkImage;
  final Property? property;
  final String realStateName;
  
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (property != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PropertyDetailPage(
                property: property!,
                imagePath: path,
                realStateName: realStateName,
                isNetworkImage: isNetworkImage,
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
                      child: isNetworkImage
                          ? Image(
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              image: NetworkImage(path),
                            )
                          : Image.asset(
                              path,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        CupertinoIcons.heart,
                        size: 20,
                        color: AppColors.whiteColor,
                      ),
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
                        title,
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
                              rating,
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
                                  location,
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
