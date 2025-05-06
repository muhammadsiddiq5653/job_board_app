import 'package:flutter_test/flutter_test.dart';
import 'package:job_board_app/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Job Model Tests', () {
    test('should create a Job from Map', () {
      // Arrange
      final Map<String, dynamic> jobMap = {
        'id': '1',
        'title': 'Flutter Developer',
        'company': 'Tech Solutions Inc.',
        'location': 'Remote',
        'description': 'We are looking for a Flutter developer with 2+ years of experience.',
        'postedBy': 'recruiter123',
        'createdAt': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      // Act
      final job = Job.fromMap(jobMap);

      // Assert
      expect(job.id, '1');
      expect(job.title, 'Flutter Developer');
      expect(job.company, 'Tech Solutions Inc.');
      expect(job.location, 'Remote');
      expect(job.description, 'We are looking for a Flutter developer with 2+ years of experience.');
      expect(job.postedBy, 'recruiter123');
      expect(job.createdAt, DateTime(2023, 1, 1));
    });

    test('should convert Job to Map', () {
      // Arrange
      final job = Job(
        id: '1',
        title: 'Flutter Developer',
        company: 'Tech Solutions Inc.',
        location: 'Remote',
        description: 'We are looking for a Flutter developer with 2+ years of experience.',
        postedBy: 'recruiter123',
        createdAt: DateTime(2023, 1, 1),
      );

      // Act
      final jobMap = job.toMap();

      // Assert
      expect(jobMap['title'], 'Flutter Developer');
      expect(jobMap['company'], 'Tech Solutions Inc.');
      expect(jobMap['location'], 'Remote');
      expect(jobMap['description'], 'We are looking for a Flutter developer with 2+ years of experience.');
      expect(jobMap['postedBy'], 'recruiter123');
    });
  });
}