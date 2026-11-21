import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// AuthController manages Firebase Authentication and user profile creation in Firestore.
/// Extends ChangeNotifier to update UI views via Provider.
class AuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthController() {
    _currentUser = _auth.currentUser;
    // Listen to Firebase Auth state changes
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clear any error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Register user with Email, Password, and Display Name
  /// Creates auth account + adds document to `/users/{userId}` adhering to Firestore rules.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // 1. Create account in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        // Update display name in Firebase Auth
        await user.updateDisplayName(name.trim());

        // 2. Create document in Firestore: /users/{userId}
        // Satisfies rule: request.auth != null && request.auth.uid == userId
        final userModel = UserModel(
          uid: user.uid,
          name: name.trim(),
          email: email.trim(),
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        _currentUser = user;
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFriendlyErrorMessage(e.code, e.message));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Registration failed: ${e.toString()}');
      return false;
    }
  }

  /// Login user with Email and Password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = userCredential.user;
      if (user != null) {
        _currentUser = user;

        // Ensure user document exists in Firestore (creates if not present)
        final docRef = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await docRef.get();
        if (!docSnapshot.exists) {
          await docRef.set({
            'uid': user.uid,
            'name': user.displayName ?? email.split('@').first,
            'email': user.email ?? email,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setLoading(false);
      _setError(_getFriendlyErrorMessage(e.code, e.message));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Login failed: ${e.toString()}');
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _setError('Logout error: ${e.toString()}');
    }
  }

  /// Helper to convert Firebase error codes to readable text
  String _getFriendlyErrorMessage(String code, String? defaultMsg) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-email':
        return 'Please provide a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered. Please log in.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return defaultMsg ?? 'Authentication error occurred.';
    }
  }
}
