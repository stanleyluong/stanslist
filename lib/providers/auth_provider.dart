import 'dart:async'; // Import for StreamSubscription

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Import google_sign_in if you plan to use it, after adding the dependency
// import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn(); // Uncomment if using Google Sign-In
  StreamSubscription<User?>? _authStateSubscription;

  User? _currentUser;

  AuthProvider() {
    _currentUser = _auth.currentUser;
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  User? get currentUser => _currentUser;

  // Email/Password Sign Up
  Future<UserCredential?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // notifyListeners(); // Already handled by authStateChanges listener
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., email-already-in-use, weak-password)
      print('Failed to sign up: ${e.message}');
      throw e; // Re-throw to be caught by UI
    }
  }

  // Email/Password Sign In
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // notifyListeners(); // Already handled by authStateChanges listener
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle errors (e.g., user-not-found, wrong-password)
      print('Failed to sign in: ${e.message}');
      throw e; // Re-throw to be caught by UI
    }
  }

  // Google Sign In - Placeholder, will require google_sign_in package and setup
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      // if (googleUser == null) {
      //   // The user canceled the sign-in
      //   return null;
      // }

      // // Obtain the auth details from the request
      // final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // // Create a new credential
      // final AuthCredential credential = GoogleAuthProvider.credential(
      //   accessToken: googleAuth.accessToken,
      //   idToken: googleAuth.idToken,
      // );

      // // Sign in to Firebase with the Google [UserCredential]
      // UserCredential userCredential = await _auth.signInWithCredential(credential);
      // notifyListeners();
      // return userCredential;
      print(
          'Google Sign-In not fully implemented yet. Requires google_sign_in package.');
      throw UnimplementedError('Google Sign-In not fully implemented yet.');
    } catch (e) {
      print('Failed to sign in with Google: $e');
      throw e; // Re-throw to be caught by UI
    }
  }

  // Sign Out
  Future<void> signOut() async {
    // await _googleSignIn.signOut(); // Uncomment if using Google Sign-In
    await _auth.signOut();
    // notifyListeners(); // Already handled by authStateChanges listener
  }
}
