import 'dart:async'; // Import for StreamSubscription

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Added for platform check
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // This is the Web Client ID from your Google Cloud Platform OAuth 2.0 credentials.
  // Used for Google Sign-In on Web via the `clientId` parameter.
  // Also used as `serverClientId` for Google Sign-In on mobile platforms
  // to request an ID token that Firebase can verify.
  static const String _googleOAuthWebClientId =
      "441136828732-8ll9m1auejil9uv1q06hvpjedmjgodo2.apps.googleusercontent.com";

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // For web: Pass the OAuth Web Client ID directly.
    clientId: kIsWeb ? _googleOAuthWebClientId : null,
    // For mobile (Android/iOS): This is the Web Client ID from your Firebase project's
    // connected Google Cloud OAuth 2.0 credential. It's used to obtain an ID token for Firebase.
    // For web: serverClientId must be null.
    serverClientId: kIsWeb ? null : _googleOAuthWebClientId,
  );
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<GoogleSignInAccount?>? _googleSignInSubscription; // Added

  User? _currentUser;

  AuthProvider() {
    _currentUser = _auth.currentUser;
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });

    // Listen to Google Sign-In changes
    _googleSignInSubscription = _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      if (account != null) {
        // User signed in with Google, now exchange for Firebase credential
        try {
          await _performFirebaseSignInWithGoogle(account);
          // Firebase auth state will be updated by _auth.authStateChanges()
        } catch (e) {
          // Error during Firebase sign-in with Google account
          // This error is not directly propagated to the UI that initiated signInWithGoogle()
          // Consider implementing a mechanism to expose this error if needed (e.g., an error stream or state in AuthProvider)
          print('Error signing into Firebase with Google account: $e');
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _googleSignInSubscription?.cancel(); // Added
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

  // Renamed from signInWithGoogle and modified to take GoogleSignInAccount
  Future<UserCredential?> _performFirebaseSignInWithGoogle(
      GoogleSignInAccount googleUser) async {
    try {
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print('AuthProvider: GoogleSignInAuthentication idToken: ${googleAuth.idToken}');
      print('AuthProvider: GoogleSignInAuthentication accessToken: ${googleAuth.accessToken}');

      // Create a new credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // This might be null for web, idToken is key
        idToken: googleAuth.idToken, // This is crucial for Firebase
      );

      // Sign in to Firebase with the Google [UserCredential]
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      // notifyListeners(); // Already handled by authStateChanges listener
      return userCredential;
    } catch (e) {
      print('Failed to sign in to Firebase with Google: $e');
      throw e; // Re-throw to be caught by the listener's try-catch or if called directly
    }
  }

  // New method to initiate Google Sign-In flow
  // AuthScreen will call this method.
  Future<void> signInWithGoogle() async {
    try {
      // Trigger the authentication flow.
      // The onCurrentUserChanged listener will handle the GoogleSignInAccount.
      await _googleSignIn.signIn();
    } catch (e) {
      print('Error initiating Google Sign-In: $e');
      // This error will be caught by the try-catch in AuthScreen
      throw e;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    print('[AuthProvider] Signing out...');
    // Order is important: sign out from Google first, then Firebase.
    await _googleSignIn.signOut();
    await _auth.signOut();
    print('[AuthProvider] Sign out complete.');
    // notifyListeners(); // Already handled by _auth.authStateChanges listener
  }
}

// Removed NavigationService as it's no longer needed with the simplified approach
