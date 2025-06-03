class User {
  final String name;
  final String email;
  final String dob;
  final String phone;
  final String address;
  final List<String> allergies;
  final String? profilePic;

  User({
    required this.name,
    required this.email,
    required this.dob,
    required this.phone,
    required this.address,
    required this.allergies,
    this.profilePic,
  });

  User copyWith({
    String? name,
    String? email,
    String? dob,
    String? phone,
    String? address,
    List<String>? allergies,
    String? profilePic,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      allergies: allergies ?? this.allergies,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}
