class User {
  final int id;
  final String firstName;
  final String lastName;
  final String age;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.age,
  });

  User copy({
    int? id,
    String? firstName,
    String? lastName,
    String? age,
  }) =>
      User(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        age: age ?? this.age,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          age == other.age &&
          id == other.id;

  @override
  int get hashCode =>
      firstName.hashCode ^ lastName.hashCode ^ age.hashCode ^ id.hashCode;
}
