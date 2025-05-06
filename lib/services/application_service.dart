import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';

class ApplicationService {
  final CollectionReference _applicationsCollection =
      FirebaseFirestore.instance.collection('applications');
  final CollectionReference _jobsCollection =
      FirebaseFirestore.instance.collection('jobs');
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // Apply for a job
  Future<bool> applyForJob(String jobId, String userId) async {
    try {
      // Check if the user has already applied for this job
      final existingApplications = await _applicationsCollection
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existingApplications.docs.isNotEmpty) {
        // User has already applied for this job
        print('User has already applied for this job');
        return false;
      }

      // Get job details
      final jobDoc = await _jobsCollection.doc(jobId).get();
      if (!jobDoc.exists) {
        print('Job not found');
        return false;
      }

      // Get user details
      final userDoc = await _usersCollection.doc(userId).get();
      if (!userDoc.exists) {
        print('User not found');
        return false;
      }

      final jobData = jobDoc.data() as Map<String, dynamic>;
      final userData = userDoc.data() as Map<String, dynamic>;

      // Create the application
      final application = {
        'jobId': jobId,
        'userId': userId,
        'userName': userData['username'] ?? 'Unknown User',
        'jobTitle': jobData['title'] ?? 'Unknown Job',
        'companyName': jobData['company'] ?? 'Unknown Company',
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      await _applicationsCollection.add(application);
      print('Job application submitted successfully');
      return true;
    } catch (e) {
      print('Error applying for job: $e');
      return false;
    }
  }

  // Get all applications for a user
  Future<List<JobApplication>> getUserApplications(String userId) async {
    try {
      final snapshot = await _applicationsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('appliedAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return JobApplication.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      print('Error getting user applications: $e');
      return [];
    }
  }

  // Check if user has applied for a specific job
  Future<bool> hasUserApplied(String jobId, String userId) async {
    try {
      final snapshot = await _applicationsCollection
          .where('jobId', isEqualTo: jobId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking application status: $e');
      return false;
    }
  }

  // Get applications count for a job
  Future<int> getApplicationsCount(String jobId) async {
    try {
      final snapshot =
          await _applicationsCollection.where('jobId', isEqualTo: jobId).get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting applications count: $e');
      return 0;
    }
  }
}
