import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Sign in with Firebase Authentication
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Get user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromMap({
            'id': userCredential.user!.uid,
            'username': userDoc['username'] ?? email,
            'password': '', // Don't store password
            'role': userDoc['role'] ?? 'jobseeker',
          });
        } else {
          // User exists in Auth but not in Firestore
          // Create a default user document
          final newUser = UserModel(
            id: userCredential.user!.uid,
            username: email,
            password: '', // Don't store password
            role: UserRole.jobseeker, // Default role
          );

          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(newUser.toMap());

          return newUser;
        }
      }
      return null;
    } catch (e) {
      print('Error signing in: $e');
      return null;
    }
  }

  // Sign up a new user
  Future<UserModel?> signUp(String email, String password, UserRole role) async {
    try {
      // Create user in Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Create user document in Firestore
        final newUser = UserModel(
          id: userCredential.user!.uid,
          username: email,
          password: '', // Don't store password
          role: role,
        );

        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(newUser.toMap());

        return newUser;
      }
      return null;
    } catch (e) {
      print('Error signing up: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Check if user is a recruiter
  Future<bool> isRecruiter(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc['role'] == 'recruiter';
    } catch (e) {
      print('Error checking user role: $e');
      return false;
    }
  }

  // Add demo users if they don't exist
  Future<void> addDemoUsers() async {
    try {
      // Check if demo users already exist
      final recruiterEmail = 'recruiter@test.com';
      final jobseekerEmail = 'jobseeker@test.com';
      final password = 'password123';

      try {
        // Try to sign in with recruiter credentials
        await _auth.signInWithEmailAndPassword(
          email: recruiterEmail,
          password: password,
        );
      } catch (e) {
        // If sign in fails, create recruiter account
        await signUp(recruiterEmail, password, UserRole.recruiter);
      }

      // Sign out from previous sign in
      await _auth.signOut();

      try {
        // Try to sign in with jobseeker credentials
        await _auth.signInWithEmailAndPassword(
          email: jobseekerEmail,
          password: password,
        );
      } catch (e) {
        // If sign in fails, create jobseeker account
        await signUp(jobseekerEmail, password, UserRole.jobseeker);
      }

      // Sign out after creating demo accounts
      await _auth.signOut();
    } catch (e) {
      print('Error creating demo users: $e');
    }
  }
}