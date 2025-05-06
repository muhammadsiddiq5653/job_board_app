import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../services/job_service.dart';

class JobProvider with ChangeNotifier {
  final JobService _jobService = JobService();
  List<Job> _jobs = [];
  Job? _selectedJob;
  bool _isLoading = false;

  List<Job> get jobs => _jobs;
  Job? get selectedJob => _selectedJob;
  bool get isLoading => _isLoading;

  // Fetch all jobs from Firestore
  Future<void> fetchJobs() async {
    _isLoading = true;
    notifyListeners();

    try {
      _jobs = await _jobService.getAllJobs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching jobs: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a specific job by ID from Firestore
  Future<void> fetchJobById(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedJob = await _jobService.getJobById(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching job: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new job to Firestore
  Future<bool> addJob(Job job) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _jobService.addJob(job);
      if (success) {
        await fetchJobs(); // Refresh job list
      } else {
        _isLoading = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error adding job: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update an existing job in Firestore
  Future<bool> updateJob(Job job) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _jobService.updateJob(job);
      if (success) {
        // Update the selected job and refresh job list
        _selectedJob = job;
        await fetchJobs();
      } else {
        _isLoading = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error updating job: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a job from Firestore
  Future<bool> deleteJob(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _jobService.deleteJob(id);
      if (success) {
        // Clear selected job if it was deleted
        if (_selectedJob?.id == id) {
          _selectedJob = null;
        }
        // Refresh job list
        await fetchJobs();
      } else {
        _isLoading = false;
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error deleting job: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Select a job to view details
  void selectJob(Job job) {
    _selectedJob = job;
    notifyListeners();
  }

  // Add demo jobs if none exist
  Future<void> addDemoJobs(String recruiterId) async {
    try {
      await _jobService.addDemoJobs(recruiterId);
      await fetchJobs(); // Refresh job list
    } catch (e) {
      print('Error adding demo jobs: $e');
    }
  }
}