import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id':           id,
        'name':         name,
        'email':        email,
        'passwordHash': passwordHash,
        'createdAt':    createdAt.toIso8601String(),
      };

  factory User.fromMap(Map<String, dynamic> map) => User(
        id:           map['id'] as String,
        name:         map['name'] as String,
        email:        map['email'] as String,
        passwordHash: map['passwordHash'] as String,
        createdAt:    DateTime.parse(map['createdAt'] as String),
      );

  User copyWith({String? name, String? email}) => User(
        id:           id,
        name:         name ?? this.name,
        email:        email ?? this.email,
        passwordHash: passwordHash,
        createdAt:    createdAt,
      );

  @override
  List<Object?> get props => [id, name, email, createdAt];
}
