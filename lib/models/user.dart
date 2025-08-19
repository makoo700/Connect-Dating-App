class User {
  final int? id;
  final String name;
  final String email;
  final String? password; // Only stored locally
  final String? phone;
  final int age;
  final String gender;
  final String bio;
  final List<String> interests;
  final String? profileImagePath;
  final double latitude;
  final double longitude;
  final int? matchScore; // Add this property

  User({
    this.id,
    required this.name,
    required this.email,
    this.password,
    this.phone,
    required this.age,
    required this.gender,
    required this.bio,
    required this.interests,
    this.profileImagePath,
    required this.latitude,
    required this.longitude,
    this.matchScore,
  });

  // Convert User object to a Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'age': age,
      'gender': gender,
      'bio': bio,
      'interests': interests.join(','), // Store as comma-separated string
      'profile_image_path': profileImagePath,
      'latitude': latitude,
      'longitude': longitude,
      // matchScore is not stored in the database as it's calculated dynamically
    };
  }

  // Create a User object from a Map from SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      phone: map['phone'],
      age: map['age'],
      gender: map['gender'],
      bio: map['bio'],
      interests: map['interests'].split(','), // Convert back to List
      profileImagePath: map['profile_image_path'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      matchScore: null, // This is calculated dynamically, not stored
    );
  }

  // Create a copy of the User with updated fields
  User copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    int? age,
    String? gender,
    String? bio,
    List<String>? interests,
    String? profileImagePath,
    double? latitude,
    double? longitude,
    int? matchScore,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      matchScore: matchScore ?? this.matchScore,
    );
  }
}
