import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parsedCreatedAt;
    final createdVal = map['createdAt'];
    if (createdVal is Timestamp) {
      parsedCreatedAt = createdVal.toDate();
    } else if (createdVal is DateTime) {
      parsedCreatedAt = createdVal;
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return UserModel(
      uid: id,
      name: (map['name'] as String?)?.trim() ?? 'User',
      email: (map['email'] as String?)?.trim() ?? '',
      createdAt: parsedCreatedAt,
    );
  }
}
