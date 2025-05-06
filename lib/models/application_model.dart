import 'package:cloud_firestore/cloud_firestore.dart';

enum ApplicationStatus { pending, reviewed, interviewed, accepted, rejected }

class JobApplication {
  final String id;
  final String jobId;
  final String userId;
  final String userName;
  final String jobTitle;
  final String companyName;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;

  JobApplication({
    required this.id,
    required this.jobId,
    required this.userId,
    required this.userName,
    required this.jobTitle,
    required this.companyName,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
  });

  // Convert JobApplication to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'userId': userId,
      'userName': userName,
      'jobTitle': jobTitle,
      'companyName': companyName,
      'status': status.toString().split('.').last,
      'appliedAt': appliedAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }

  // Create JobApplication from Firestore document
  factory JobApplication.fromMap(Map<String, dynamic> map, String docId) {
    ApplicationStatus getStatus(String status) {
      switch (status.toLowerCase()) {
        case 'reviewed':
          return ApplicationStatus.reviewed;
        case 'interviewed':
          return ApplicationStatus.interviewed;
        case 'accepted':
          return ApplicationStatus.accepted;
        case 'rejected':
          return ApplicationStatus.rejected;
        case 'pending':
        default:
          return ApplicationStatus.pending;
      }
    }

    return JobApplication(
      id: docId,
      jobId: map['jobId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      companyName: map['companyName'] ?? '',
      status: getStatus(map['status'] ?? 'pending'),
      appliedAt: map['appliedAt'] != null
          ? (map['appliedAt'] is DateTime
              ? map['appliedAt']
              : (map['appliedAt'] as Timestamp).toDate())
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is DateTime
              ? map['updatedAt']
              : (map['updatedAt'] as Timestamp).toDate())
          : null,
    );
  }
}
