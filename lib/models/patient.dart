import 'package:uuid/uuid.dart';

class Patient {
  final String id;
  String name;
  int age;
  String gender;
  String diagnosis;
  String ward;
  DateTime createdAt;
  DateTime updatedAt;

  Patient({
    String? id,
    required this.name,
    required this.age,
    required this.gender,
    this.diagnosis = '',
    this.ward = '',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'diagnosis': diagnosis,
      'ward': ward,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      gender: map['gender'] as String,
      diagnosis: map['diagnosis'] as String? ?? '',
      ward: map['ward'] as String? ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Patient copyWith({
    String? name,
    int? age,
    String? gender,
    String? diagnosis,
    String? ward,
  }) {
    return Patient(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      diagnosis: diagnosis ?? this.diagnosis,
      ward: ward ?? this.ward,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
