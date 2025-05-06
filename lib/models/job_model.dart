// lib/models/job_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String description;
  final String postedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.description,
    required this.postedBy,
    this.createdAt,
    this.updatedAt,
  });

  // Convert Job to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'company': company,
      'location': location,
      'description': description,
      'postedBy': postedBy,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  // Create Job from Firestore document
  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      postedBy: map['postedBy'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
          ? map['createdAt']
          : (map['createdAt'] as Timestamp).toDate())
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
          ? map['updatedAt']
          : (map['updatedAt'] as Timestamp).toDate())
          : null,
    );
  }
}