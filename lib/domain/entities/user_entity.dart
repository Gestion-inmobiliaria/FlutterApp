class UserEntity {
  final String id;
  final String? ci;
  final String name;
  final String email;
  final String? password;
  final String? phone;
  final String? address;
  final String? gender;

  const UserEntity({
    required this.id,
    this.ci,
    required this.name,
    required this.email,
    this.password,
    this.phone,
    this.address,
    this.gender,
  });

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      id: json['id'],
      ci: json['ci']?.toString(),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      address: json['address'],
      gender: json['gender'],
    );
  }
}
