import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { recruiter, jobseeker }

class UserModel {
  final String id;
  final String username;
  final String password; // This will be empty for security
  final UserRole role;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    this.createdAt,
  });

  // Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      // We never store password in Firestore
      'role': role.toString().split('.').last,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  // Create UserModel from Firestore document
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      password: '', // Never store or retrieve password
      role: map['role'] == 'recruiter' ? UserRole.recruiter : UserRole.jobseeker,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
          ? map['createdAt']
          : (map['createdAt'] as Timestamp).toDate())
          : null,
    );
  }
}