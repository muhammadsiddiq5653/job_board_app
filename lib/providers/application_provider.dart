import 'package:flutter/foundation.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';

class ApplicationProvider with ChangeNotifier {
  final ApplicationService _applicationService = ApplicationService();
  List<JobApplication> _userApplications = [];
  bool _isLoading = false;
  bool _hasApplied = false;

  List<JobApplication> get userApplications => _userApplications;
  bool get isLoading => _isLoading;
  bool get hasApplied => _hasApplied;

  // Apply for a job
  Future<bool> applyForJob(String jobId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final success = await _applicationService.applyForJob(jobId, userId);

      if (success) {
        _hasApplied = true;
        await getUserApplications(userId);
      }

      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      print('Error in ApplicationProvider.applyForJob: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get all applications for a user
  Future<void> getUserApplications(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _userApplications = await _applicationService.getUserApplications(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in ApplicationProvider.getUserApplications: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if user has applied for a specific job
  Future<void> checkApplicationStatus(String jobId, String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _hasApplied = await _applicationService.hasUserApplied(jobId, userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error in ApplicationProvider.checkApplicationStatus: $e');
      _isLoading = false;
      notifyListeners();
    }
  }
}
