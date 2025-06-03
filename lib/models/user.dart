class User {
  final String name;
  final String email;
  final String dob;
  final String phone;
  final List<String> allergies;
  final String? profilePic;
  final double? height;
  final double? weight;

  User({
    required this.name,
    required this.email,
    required this.dob,
    required this.phone,
    required this.allergies,
    this.profilePic,
    this.height,
    this.weight,
  });

  User copyWith({
    String? name,
    String? email,
    String? dob,
    String? phone,
    List<String>? allergies,
    String? profilePic,
    double? height,
    double? weight,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      dob: dob ?? this.dob,
      phone: phone ?? this.phone,
      allergies: allergies ?? this.allergies,
      profilePic: profilePic ?? this.profilePic,
      height: height ?? this.height,
      weight: weight ?? this.weight,
    );
  }
}
