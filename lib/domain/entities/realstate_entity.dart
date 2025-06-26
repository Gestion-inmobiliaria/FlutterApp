class RealState {
  final String id;
  final String name;
  final String email;
  final String address;

  RealState({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
  });

  factory RealState.fromJson(Map<String, dynamic> json) {
    return RealState(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      address: json['address'] ?? '',
    );
  }
}
