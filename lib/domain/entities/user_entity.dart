class UserEntity {
  final int ci;
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? address;
  final String? gender;

  const UserEntity({
    required this.ci,
    required this.name,
    required this.email,
    required this.password,
    this.phone,
    this.address,
    this.gender,
  });
}
