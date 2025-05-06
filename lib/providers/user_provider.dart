import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isRecruiter => _currentUser?.role == UserRole.recruiter;

  // Sign in using Firebase Authentication
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await authService.signIn(email, password);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to handle specific errors in the UI
    }
  }

  // Sign up using Firebase Authentication
  Future<bool> signUp(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await authService.signUp(email, password, role);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to handle specific errors in the UI
    }
  }

  // Sign out from Firebase Authentication
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await authService.signOut();
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Check if a user is currently signed in on app start
  Future<void> checkCurrentUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = authService.currentUser;
      if (user != null) {
        // Get user data from Firestore
        final isUserRecruiter = await authService.isRecruiter(user.uid);
        _currentUser = UserModel(
          id: user.uid,
          username: user.email ?? '',
          password: '',
          role: isUserRecruiter ? UserRole.recruiter : UserRole.jobseeker,
        );
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}