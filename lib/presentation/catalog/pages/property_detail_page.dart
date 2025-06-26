import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inmobiliaria_app/domain/entities/property_entity.dart';
import 'package:inmobiliaria_app/domain/providers/auth_provider.dart';
import 'package:inmobiliaria_app/presentation/constant/colors.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:inmobiliaria_app/presentation/payment/models/purchase_metadata.dart';
import 'package:inmobiliaria_app/presentation/payment/widgets/buy_button.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:inmobiliaria_app/presentation/maps/providers/tile_cache_provider.dart';
import 'package:inmobiliaria_app/domain/providers/property_provider.dart';
import 'package:inmobiliaria_app/domain/entities/user_entity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:inmobiliaria_app/presentation/catalog/bloc/favorite_bloc.dart';
import 'package:inmobiliaria_app/service_locator.dart';
// import 'package:permission_handler/permission_handler.dart';

class PropertyDetailPage extends ConsumerStatefulWidget {
  final Property property;
  final String imagePath;
  final String realStateName;
  final bool isNetworkImage;

  const PropertyDetailPage({
    Key? key,
    required this.property,
    required this.imagePath,
    required this.realStateName,
    this.isNetworkImage = false,
  }) : super(key: key);

  @override
  ConsumerState<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends ConsumerState<PropertyDetailPage> {
  final MapController _mapController = MapController();
  LatLng? _propertyLocation;

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

  @override
  void initState() {
    super.initState();
    _loadPropertyLocation();

    // Verificar el estado inicial de favorito después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final favoriteBloc = context.read<FavoriteBloc>();
          favoriteBloc.add(CheckFavoriteStatus(widget.property.id));
        } catch (e) {
          debugPrint('Error accessing FavoriteBloc: $e');
        }
      }
    });
  }

  void _loadPropertyLocation() {
    if (widget.property.ubicacion != null &&
        widget.property.ubicacion!['latitud'] != null &&
        widget.property.ubicacion!['longitud'] != null) {
      try {
        final lat = double.parse(widget.property.ubicacion!['latitud']);
        final lng = double.parse(widget.property.ubicacion!['longitud']);
        setState(() {
          _propertyLocation = LatLng(lat, lng);
        });
      } catch (e) {
        debugPrint('Error al parsear coordenadas: $e');
      }
    }
  }

  String _getIconForProperty() {
    final name = widget.realStateName.toLowerCase();

    if (name.contains('remax')) return 'assets/icons/remax.png';
    if (name.contains('century') || name.contains('c21'))
      return 'assets/icons/c21.png';

    return 'assets/icons/default.png';
  }

  // Obtener una imagen de los assets basada en el hash de la descripción
  String _getFallbackImage() {
    // Usar el hash de la descripción para seleccionar una imagen consistente para la misma propiedad
    final int hashCode = widget.property.descripcion.hashCode.abs();
    return _assetImages[hashCode % _assetImages.length];
  }

  void _toggleFavorite() {
    try {
      final favoriteBloc = context.read<FavoriteBloc>();
      final currentState = favoriteBloc.state;
      bool isCurrentlyFavorite = false;

      if (currentState is FavoriteLoaded) {
        isCurrentlyFavorite =
            currentState.favoriteStatus[widget.property.id] ?? false;
      }

      favoriteBloc.add(ToggleFavorite(widget.property.id, isCurrentlyFavorite));
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar favoritos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final user = ref.watch(authProvider);

        if (user == null) return const Text('Usuario no autenticado');

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // Imagen principal con botón de regreso
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // Imagen del inmueble
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child:
                              widget.isNetworkImage
                                  ? Image.network(
                                    widget.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Si hay error al cargar la imagen de red, usar una imagen de assets
                                      return Image.asset(
                                        _getFallbackImage(),
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  )
                                  : Image.asset(
                                    widget.imagePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Si hay error al cargar la imagen de assets, usar otra imagen de assets
                                      return Image.asset(
                                        _assetImages[0], // Usar la primera imagen como última opción
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                        ),
                        // Gradiente para mejorar la visibilidad de los botones
                        Container(
                          height: 300,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  actions: [
                    // Botón de favoritos
                Builder(
                  builder: (context) {
                    try {
                      context.read<FavoriteBloc>();
                      
                      return Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: BlocBuilder<FavoriteBloc, FavoriteState>(
                          builder: (context, state) {
                            bool isFavorite = false;

                            if (state is FavoriteLoaded) {
                              isFavorite =
                                  state.favoriteStatus[widget.property.id] ?? false;
                            }

                            return IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: Colors.red,
                              ),
                              onPressed: _toggleFavorite,
                            );
                          },
                        ),
                      );
                    } catch (e) {
                      // Si no hay FavoriteBloc disponible, mostrar botón deshabilitado
                      return Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Favoritos no disponibles'),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                  ],
                ),

                // Contenido principal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de la inmobiliaria
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryColor,
                              radius: 20,
                              child: Text(
                                widget.realStateName.isNotEmpty
                                    ? widget.realStateName[0].toUpperCase()
                                    : 'I',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                widget.realStateName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Título y precio
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Descripción
                            Expanded(
                              child: Text(
                                widget.property.descripcion,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Precio
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${widget.property.precio.toStringAsFixed(0)}€',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                // Estado
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        widget.property.estado == 'disponible'
                                            ? Colors.green.shade100
                                            : Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    widget.property.estado.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          widget.property.estado == 'disponible'
                                              ? Colors.green.shade800
                                              : Colors.amber.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Características principales
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildFeature(
                              Icons.square_foot,
                              '${widget.property.area.toStringAsFixed(0)}m²',
                              'Área',
                            ),
                            _buildFeature(
                              Icons.bed,
                              '${widget.property.nroHabitaciones ?? 0}',
                              'Habitaciones',
                            ),
                            _buildFeature(
                              Icons.bathtub_outlined,
                              '${widget.property.nroBanos ?? 0}',
                              'Baños',
                            ),
                            _buildFeature(
                              Icons.directions_car,
                              '${widget.property.nroEstacionamientos ?? 0}',
                              'Estacionamientos',
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Sección de ubicación
                        const Text(
                          'Ubicación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: 200,
                            width: double.infinity,
                            child:
                                _propertyLocation != null
                                    ? _buildMap()
                                    : Container(
                                      color: Colors.grey.shade300,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.location_off,
                                              size: 50,
                                              color: Colors.grey.shade600,
                                            ),
                                            const Text(
                                              'Ubicación no disponible',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Sección de descripción completa
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.property.descripcion,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                        ),

                        // Detalles adicionales
                        if (widget.property.categoria != null ||
                            widget.property.modalidad != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              const Text(
                                'Categoría y Modalidad',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _buildDetailRow(
                                'Categoría:',
                                widget.property.categoria ?? 'No especificada',
                              ),
                              const SizedBox(height: 8),
                              _buildDetailRow(
                                'Modalidad:',
                                widget.property.modalidad ?? 'No especificada',
                              ),
                            ],
                          ),

                        // Sección de contacto
                        const SizedBox(height: 24),
                        const Text(
                          'Contacto del Agente',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Información del agente
                        Consumer(
                          builder: (context, ref, child) {
                            final agentAsync = ref.watch(
                              propertyAgentProvider(widget.property.id),
                            );

                            return agentAsync.when(
                              data: (agent) {
                                // Determinar la imagen de perfil según el género
                                String profileImage =
                                    'assets/images/profile.png';
                                if (agent.gender?.toLowerCase() == 'femenino' ||
                                    agent.gender?.toLowerCase() == 'female') {
                                  profileImage = 'assets/images/profile1.png';
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Información básica del agente
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundImage: AssetImage(
                                            profileImage,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                agent.name,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              if (agent.phone != null)
                                                Text(
                                                  agent.phone!,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              Text(
                                                agent.email,
                                                style: TextStyle(
                                                  color: Colors.grey.shade700,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 16),

                                    // Botón de WhatsApp
                                    if (agent.phone != null)
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.green.shade200,
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: ListTile(
                                          leading: const FaIcon(
                                            FontAwesomeIcons.whatsapp,
                                            color: Colors.green,
                                            size: 24,
                                          ),
                                          title: const Text(
                                            'Contactar por WhatsApp',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                          subtitle: const Text(
                                            'Enviar mensaje con detalles',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          onTap:
                                              () => _showCustomMessageDialog(
                                                agent.phone!,
                                                widget.property.descripcion,
                                              ),
                                        ),
                                      ),

                                    // Botón de correo electrónico
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.blue.shade200,
                                        ),
                                      ),
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      child: ListTile(
                                        leading: const Icon(
                                          Icons.email,
                                          color: Colors.blue,
                                          size: 24,
                                        ),
                                        title: const Text(
                                          'Enviar correo electrónico',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: const Text(
                                          'Contactar al agente por email',
                                          style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: Colors.blue,
                                          size: 16,
                                        ),
                                        onTap: () => _launchEmail(agent.email),
                                      ),
                                    ),

                                    // Botón de llamada
                                    if (agent.phone != null)
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade50,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.orange.shade200,
                                          ),
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: ListTile(
                                          leading: const Icon(
                                            Icons.phone,
                                            color: Colors.orange,
                                            size: 24,
                                          ),
                                          title: const Text(
                                            'Llamar por teléfono',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.orange,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          subtitle: Text(
                                            agent.phone!,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          trailing: const Icon(
                                            Icons.arrow_forward_ios,
                                            color: Colors.orange,
                                            size: 16,
                                          ),
                                          onTap:
                                              () => _launchPhone(agent.phone!),
                                        ),
                                      ),

                                    BuyButton(
                                      metadata: PurchaseMetadata(
                                        propertyId: widget.property.id,
                                        clientName: user.name,
                                        clientDocument: '12345678',
                                        clientPhone: user.phone,
                                        clientEmail: user.email,
                                        agentName: agent.name,
                                        agentDocument: agent.ci ?? 'SIN_CI',
                                        paymentMethod: 'TARJETA',
                                        amount: widget.property.precio.toInt(),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              loading:
                                  () => const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                              error:
                                  (error, stackTrace) => Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        'No se pudo cargar la información del agente',
                                        style: TextStyle(
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ),
                            );
                          },
                        ),

                        // const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAgentContactModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildAgentContactSheet(context),
    );
  }

  Widget _buildAgentContactSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Consumer(
          builder: (context, ref, child) {
            final agentAsync = ref.watch(
              propertyAgentProvider(widget.property.id),
            );

            return agentAsync.when(
              data:
                  (agent) => _buildAgentInfo(context, agent, scrollController),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stackTrace) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No se pudo cargar la información del agente',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgentInfo(
    BuildContext context,
    UserEntity agent,
    ScrollController scrollController,
  ) {
    // Determinar la imagen de perfil según el género
    String profileImage = 'assets/images/profile.png'; // Por defecto masculino
    if (agent.gender?.toLowerCase() == 'femenino' ||
        agent.gender?.toLowerCase() == 'female') {
      profileImage = 'assets/images/profile1.png';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        controller: scrollController,
        children: [
          // Barra de arrastre
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título
          const Text(
            'Información del Agente',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Foto de perfil
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(profileImage),
            ),
          ),
          const SizedBox(height: 16),

          // Nombre del agente
          Text(
            agent.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Correo electrónico
          ListTile(
            leading: const Icon(Icons.email, color: AppColors.primaryColor),
            title: const Text('Correo electrónico'),
            subtitle: Text(agent.email),
            onTap: () => _launchEmail(agent.email),
          ),

          // Teléfono
          if (agent.phone != null)
            ListTile(
              leading: const Icon(Icons.phone, color: AppColors.primaryColor),
              title: const Text('Teléfono'),
              subtitle: Text(agent.phone!),
              onTap: () => _launchPhone(agent.phone!),
            ),

          // WhatsApp
          if (agent.phone != null)
            Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.green,
                      size: 28,
                    ),
                    title: const Text(
                      'Contactar por WhatsApp',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    subtitle: const Text(
                      'Enviar mensaje con detalles de la propiedad',
                      style: TextStyle(color: Colors.black87),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.green,
                    ),
                    onTap:
                        () => _showCustomMessageDialog(
                          agent.phone!,
                          widget.property.descripcion,
                        ),
                  ),
                ),
              ],
            ),

          // Dirección
          if (agent.address != null)
            ListTile(
              leading: const Icon(
                Icons.location_on,
                color: AppColors.primaryColor,
              ),
              title: const Text('Dirección'),
              subtitle: Text(agent.address!),
            ),

          const SizedBox(height: 20),

          // Botón de cerrar
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query:
          'subject=Consulta sobre propiedad ${widget.property.id}&body=Hola, estoy interesado/a en obtener más información sobre la propiedad con ID: ${widget.property.id}.\n\nDetalles de la propiedad:\nPrecio: ${widget.property.precio.toStringAsFixed(0)}€\nÁrea: ${widget.property.area.toStringAsFixed(0)}m²\nHabitaciones: ${widget.property.nroHabitaciones ?? "No especificado"}\n\nQuedo atento a su respuesta.\n\nSaludos cordiales.',
    );

    // if (await canLaunchUrl(emailUri)) {
    //   await launchUrl(emailUri);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('No se pudo abrir el correo electrónico')),
    //   );
    // }

    try {
      debugPrint('Intentando abrir directamente: $emailUri');
      // En algunos dispositivos (especialmente Xiaomi/MIUI), canLaunchUrl puede fallar
      // aunque la URL sea válida, así que intentamos lanzarla directamente
      await launchUrl(emailUri);
    } catch (e) {
      debugPrint('Error al abrir el gmail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el servicio de gmail')),
      );
    }
  }

  void _launchPhone(String phone) async {
    // Limpiar el número de teléfono de caracteres no deseados
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Crear la URI con el formato correcto
    final Uri phoneUri = Uri.parse('tel:$cleanPhone');

    try {
      debugPrint('Intentando abrir directamente: $phoneUri');
      // En algunos dispositivos (especialmente Xiaomi/MIUI), canLaunchUrl puede fallar
      // aunque la URL sea válida, así que intentamos lanzarla directamente
      await launchUrl(phoneUri);
    } catch (e) {
      debugPrint('Error al abrir el marcador: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el marcador telefónico')),
      );
    }
  }

  void _showCustomMessageDialog(String phone, String propertyDesc) {
    final defaultMessage =
        """Hola, estoy interesado/a en la siguiente propiedad:

*${widget.property.descripcion}*
💰 Precio: ${widget.property.precio.toStringAsFixed(0)}€
📏 Área: ${widget.property.area.toStringAsFixed(0)}m²
🛏️ Habitaciones: ${widget.property.nroHabitaciones ?? 'No especificado'}
🚿 Baños: ${widget.property.nroBanos ?? 'No especificado'}
🏢 Categoría: ${widget.property.categoria ?? 'No especificada'}
📝 Modalidad: ${widget.property.modalidad ?? 'No especificada'}
🏘️ Inmobiliaria: ${widget.realStateName}

Me gustaría recibir más información. Gracias.""";

    final messageController = TextEditingController(text: defaultMessage);

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.whatsapp,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Contactar por WhatsApp',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Puedes personalizar el mensaje:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: messageController,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                          hintText: 'Escribe tu mensaje aquí',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 16),
                      label: const Text('Enviar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _launchWhatsAppWithCustomMessage(
                          phone,
                          messageController.text,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _launchWhatsAppWithCustomMessage(
    String phone,
    String customMessage,
  ) async {
    String formattedPhone = phone;
    if (!formattedPhone.startsWith('+')) {
      formattedPhone = '+$formattedPhone';
    }

    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$formattedPhone?text=${Uri.encodeComponent(customMessage)}',
    );

    try {
      debugPrint('Intentando abrir directamente: $whatsappUri');
      // En algunos dispositivos (especialmente Xiaomi/MIUI), canLaunchUrl puede fallar
      // aunque la URL sea válida, así que intentamos lanzarla directamente
      await launchUrl(whatsappUri);
    } catch (e) {
      debugPrint('Error al abrir Whatsapp: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo abrir el Whatsapp')));
    }

    // if (await canLaunchUrl(whatsappUri)) {
    //   await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('No se pudo abrir WhatsApp')),
    //   );
    // }
  }

  Widget _buildFeature(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildMap() {
    final asyncStore = ref.watch(tileCacheProvider);
    return asyncStore.when(
      data: (store) {
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _propertyLocation!,
                initialZoom: 15.0,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  tileProvider: CachedTileProvider(
                    store: store,
                    maxStale: const Duration(days: 365),
                  ),
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: _propertyLocation!,
                      child: Image.asset(
                        _getIconForProperty(),
                        width: 30,
                        height: 30,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Botón para centrar el mapa
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.center_focus_strong),
                  onPressed: () {
                    if (_propertyLocation != null) {
                      _mapController.move(_propertyLocation!, 15.0);
                    }
                  },
                ),
              ),
            ),
            // Dirección como overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black.withOpacity(0.6),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.property.ubicacion?['direccion'] ??
                            'Dirección no disponible',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  // Método original mantenido para compatibilidad
  void _launchWhatsApp(String phone, String propertyDesc) async {
    // Crear un mensaje más detallado con la información de la propiedad
    final message = """Hola, estoy interesado/a en la siguiente propiedad:

*${widget.property.descripcion}*
💰 Precio: ${widget.property.precio.toStringAsFixed(0)}€
📏 Área: ${widget.property.area.toStringAsFixed(0)}m²
🛏️ Habitaciones: ${widget.property.nroHabitaciones ?? 'No especificado'}
🚿 Baños: ${widget.property.nroBanos ?? 'No especificado'}
🏢 Categoría: ${widget.property.categoria ?? 'No especificada'}
📝 Modalidad: ${widget.property.modalidad ?? 'No especificada'}
🏘️ Inmobiliaria: ${widget.realStateName}

Me gustaría recibir más información. Gracias.""";

    _launchWhatsAppWithCustomMessage(phone, message);
  }
}
