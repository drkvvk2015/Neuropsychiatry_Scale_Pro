import 'package:intl/intl.dart';

class Patient {
  final String id;
  final String name;
  final int age;
  final String gender;
  final String? phone;
  final String? address;
  final String? diagnosis;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? photoUrl;

  Patient({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    this.phone,
    this.address,
    this.diagnosis,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.photoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'gender': gender,
      'phone': phone,
      'address': address,
      'diagnosis': diagnosis,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      gender: map['gender'],
      phone: map['phone'],
      address: map['address'],
      diagnosis: map['diagnosis'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      photoUrl: map['photoUrl'],
    );
  }

  Patient copyWith({
    String? id,
    String? name,
    int? age,
    String? gender,
    String? phone,
    String? address,
    String? diagnosis,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? photoUrl,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      diagnosis: diagnosis ?? this.diagnosis,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  String get formattedCreatedAt => DateFormat('dd MMM yyyy').format(createdAt);
}