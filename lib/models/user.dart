class User {
  String name;
  String email;
  String dob;
  String phone;
  String address;
  List<String> allergies;
  String? profileImagePath;

  User({
    required this.name,
    required this.email,
    required this.dob,
    required this.phone,
    required this.address,
    required this.allergies,
    this.profileImagePath,
  });

  User copyWith({
    String? name,
    String? email,
    String? dob,
    String? phone,
    String? address,
    List<String>? allergies,
    String? profileImagePath,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      allergies: allergies ?? this.allergies,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}
