class User {
  final String name;
  final String email;
  final String phone;
  final String dob;
  final double? height;
  final double? weight;
  final String? diet;
  final String? gender;
  final List<String> allergies;
  final String? profilePic;

  User({
    required this.name,
    required this.email,
    required this.phone,
    required this.dob,
    this.height,
    this.weight,
    this.diet,
    this.gender,
    required this.allergies,
    this.profilePic,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    String? dob,
    double? height,
    double? weight,
    String? diet,
    String? gender,
    List<String>? allergies,
    String? profilePic,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      diet: diet ?? this.diet,
      gender: gender ?? this.gender,
      allergies: allergies ?? this.allergies,
      profilePic: profilePic ?? this.profilePic,
    );
  }
}
