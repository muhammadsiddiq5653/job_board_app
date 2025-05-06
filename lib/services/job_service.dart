import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final CollectionReference _jobsCollection = FirebaseFirestore.instance.collection('jobs');

  // Get all jobs
  Future<List<Job>> getAllJobs() async {
    try {
      final snapshot = await _jobsCollection.orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Job.fromMap({
          'id': doc.id,
          ...data,
        });
      }).toList();
    } catch (e) {
      print('Error getting jobs: $e');
      return [];
    }
  }

  // Get job by id
  Future<Job?> getJobById(String id) async {
    try {
      final doc = await _jobsCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Job.fromMap({
          'id': doc.id,
          ...data,
        });
      }
      return null;
    } catch (e) {
      print('Error getting job: $e');
      return null;
    }
  }

  // Add a new job
  Future<bool> addJob(Job job) async {
    try {
      await _jobsCollection.add({
        'title': job.title,
        'company': job.company,
        'location': job.location,
        'description': job.description,
        'postedBy': job.postedBy,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding job: $e');
      return false;
    }
  }

  // Update a job
  Future<bool> updateJob(Job job) async {
    try {
      await _jobsCollection.doc(job.id).update({
        'title': job.title,
        'company': job.company,
        'location': job.location,
        'description': job.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating job: $e');
      return false;
    }
  }

  // Delete a job
  Future<bool> deleteJob(String id) async {
    try {
      await _jobsCollection.doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting job: $e');
      return false;
    }
  }

  // Add demo jobs if none exist
  Future<void> addDemoJobs(String recruiterId) async {
    try {
      // Check if jobs collection is empty
      final snapshot = await _jobsCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        // Add demo jobs
        final demoJobs = [
          {
            'title': 'Flutter Developer',
            'company': 'Tech Solutions Inc.',
            'location': 'Remote',
            'description': 'We are looking for a Flutter developer with 2+ years of experience to join our team.',
            'postedBy': recruiterId,
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'title': 'Full Stack Developer',
            'company': 'Web Experts Ltd.',
            'location': 'New York, NY',
            'description': 'Full stack developer with experience in React and Node.js needed for our growing team.',
            'postedBy': recruiterId,
            'createdAt': FieldValue.serverTimestamp(),
          },
          {
            'title': 'Mobile App Designer',
            'company': 'Creative Apps',
            'location': 'San Francisco, CA',
            'description': 'Looking for a creative designer to help design beautiful mobile interfaces.',
            'postedBy': recruiterId,
            'createdAt': FieldValue.serverTimestamp(),
          },
        ];

        // Add each demo job to Firestore
        for (var job in demoJobs) {
          await _jobsCollection.add(job);
        }
      }
    } catch (e) {
      print('Error adding demo jobs: $e');
    }
  }
}