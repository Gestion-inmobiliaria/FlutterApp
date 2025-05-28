class Property {
  final String id;
  final String descripcion;
  final double precio;
  final String estado;
  final double area;
  final int? nroHabitaciones;
  final int? nroBanos;
  final int? nroEstacionamientos;
  final String? categoria;
  final String? modalidad;
  final String? sectorId;
  final String? inmobiliaria;
  final List<String>? imagenes;
  final Map<String, dynamic>? ubicacion;
  final Map<String, dynamic>? user;

  Property({
    required this.id,
    required this.descripcion,
    required this.precio,
    required this.estado,
    required this.area,
    this.nroHabitaciones,
    this.nroBanos,
    this.nroEstacionamientos,
    this.categoria,
    this.modalidad,
    this.sectorId,
    this.inmobiliaria,
    this.imagenes,
    this.ubicacion,
    this.user,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      descripcion: json['descripcion'],
      precio: double.parse(json['precio'].toString()),
      estado: json['estado'],
      area: double.parse(json['area'].toString()),
      nroHabitaciones: json['NroHabitaciones'],
      nroBanos: json['NroBanos'],
      nroEstacionamientos: json['NroEstacionamientos'],
      categoria: json['category']?['name'],
      modalidad: json['modality']?['name'],
      sectorId: json['sector']?['id'],
      inmobiliaria: json['sector']?['realState']?['name'],
      imagenes:
          json['imagenes'] != null
              ? List<String>.from(json['imagenes'].map((img) => img['url']))
              : [],
      ubicacion: json['ubicacion'],
      user: json['user'],
    );
  }
}
