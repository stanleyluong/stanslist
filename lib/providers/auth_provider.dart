import 'dart:async'; // Import for StreamSubscription

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod import
import 'package:google_sign_in/google_sign_in.dart';

// AuthProvider class definition (ChangeNotifier)
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  GoogleSignIn _googleSignIn;
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              // Use dart-define values for both development and production
              clientId: kIsWeb
                  ? const String.fromEnvironment('GOOGLE_SIGN_IN_CLIENT_ID')
                  : null,
              // serverClientId: !kIsWeb ? const String.fromEnvironment('ANDROID_OAUTH_CLIENT_ID') : null, // For Android if needed
            ) {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
    _googleSignIn.onCurrentUserChanged.listen(_onGoogleCurrentUserChanged);
    // Initial check, important for when app starts and user is already signed in with Firebase
    _user = _firebaseAuth.currentUser;
    print("AuthProvider initialized. Current Firebase user: ${_user?.uid}");
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    print(
        "AuthProvider: Firebase authStateChanged. User: ${firebaseUser?.uid}");
    if (firebaseUser == null) {
      _user = null;
      // If Firebase user is null, and GoogleSignIn still thinks it's signed in (on mobile),
      // this could be a state to reconcile, but usually explicit sign-out handles both.
      if (!kIsWeb && await _googleSignIn.isSignedIn()) {
        print(
            "AuthProvider: Firebase user is null, but GoogleSignIn (mobile) is still signed in. This might happen during initial load or if only Firebase token expired.");
      }
    } else {
      _user = firebaseUser;
    }
    _isLoading = false; // Ensure loading is false after auth state change
    notifyListeners();
  }

  Future<void> _onGoogleCurrentUserChanged(GoogleSignInAccount? account) async {
    print(
        'AuthProvider: _googleSignIn.onCurrentUserChanged. Account: ${account?.displayName}, kIsWeb: $kIsWeb, Current Firebase User: ${_user?.uid}');
    if (kIsWeb) {
      print(
          'AuthProvider (Web): _googleSignIn.onCurrentUserChanged. No Firebase action taken from here for web, as signInWithPopup manages its own flow.');
      // It's possible the user signed out from a Google prompt triggered by google_sign_in (e.g. if renderButton was used and then removed)
      // If Firebase session is still active, it will remain. If not, _onAuthStateChanged would handle it.
      return;
    }

    // Mobile path
    if (account != null) {
      if (_user == null) {
        print(
            'AuthProvider (Mobile): Google account found via onCurrentUserChanged and no Firebase user. Attempting Firebase sign-in.');
        _isLoading = true;
        _error = null;
        notifyListeners();
        try {
          await _performFirebaseSignInWithGoogleMobile(account);
        } catch (e) {
          print(
              'AuthProvider (Mobile): Error during auto Firebase sign-in via onCurrentUserChanged: $e');
          _error = e.toString();
          // _user will remain null or be set by _performFirebaseSignInWithGoogleMobile
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      } else {
        print(
            'AuthProvider (Mobile): Google account found via onCurrentUserChanged, but Firebase user already exists. No action from here.');
      }
    } else {
      print(
          'AuthProvider (Mobile): Google account via onCurrentUserChanged is null (signed out from Google plugin).');
      // This doesn't automatically sign out the Firebase user.
      // If _user is not null and was a Google user, this might indicate a desync.
      // Explicit app signOut is the primary mechanism for full sign out.
    }
  }

  Future<void> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        print('AuthProvider (Web): Attempting signInWithPopup.');
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        // For web, ensure your Firebase project has Google Sign-In enabled and
        // the correct OAuth client IDs are configured in the Firebase console.
        // The WEB_OAUTH_CLIENT_ID in .env is for the google_sign_in plugin,
        // which we are NOT primarily relying on for the web sign-in token part here.
        // Firebase signInWithPopup handles its own GIS initialization using Firebase console config.

        final UserCredential userCredential =
            await _firebaseAuth.signInWithPopup(googleProvider);
        // _user = userCredential.user; // _onAuthStateChanged will handle this
        print(
            'AuthProvider (Web): signInWithPopup successful. User will be updated by authStateChanges. User from cred: ${userCredential.user?.displayName}');
        _error = null;
      } else {
        // Mobile flow
        print('AuthProvider (Mobile): Attempting _googleSignIn.signIn().');
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print('AuthProvider (Mobile): Google Sign-In cancelled by user.');
          _error = 'Google Sign-In cancelled by user.';
          // _isLoading will be set to false in finally
          return;
        }
        print(
            'AuthProvider (Mobile): Google Sign-In successful. User: ${googleUser.displayName}. Now performing Firebase sign-in.');
        await _performFirebaseSignInWithGoogleMobile(googleUser);
      }
    } catch (e) {
      print('AuthProvider: Error during signInWithGoogle: $e');
      _error = e.toString();
      // _user = null; // _onAuthStateChanged will set user to null if auth fails overall
      if (e is FirebaseAuthException &&
          (e.code == 'cancelled-popup-request' ||
              e.code == 'popup-closed-by-user')) {
        _error = 'Sign-in popup closed by user.';
      }
      // Consider specific error codes for google_sign_in on mobile if needed
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _performFirebaseSignInWithGoogleMobile(
      GoogleSignInAccount googleSignInAccount) async {
    // This method is part of the signInWithGoogle flow for mobile,
    // or called by _onGoogleCurrentUserChanged for auto-sign-in on mobile.
    print(
        'AuthProvider (Mobile): Performing Firebase sign-in with Google account: ${googleSignInAccount.displayName}');
    try {
      final GoogleSignInAuthentication googleAuth =
          await googleSignInAccount.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken =
          googleAuth.accessToken; // May or may not be needed by your backend

      print(
          'AuthProvider (Mobile): GoogleSignInAuthentication idToken: $idToken');
      print(
          'AuthProvider (Mobile): GoogleSignInAuthentication accessToken: $accessToken');

      if (idToken == null) {
        print(
            'AuthProvider (Mobile): Google Sign-In ID token is null. This is unexpected on mobile.');
        throw FirebaseAuthException(
            code: 'google-sign-in-no-id-token',
            message: 'Google Sign-In ID token is null on mobile.');
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken:
            accessToken, // Firebase uses idToken primarily, accessToken might be optional for this credential type
        idToken: idToken,
      );
      print(
          'AuthProvider (Mobile): Signing into Firebase with Google credential.');
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      // _user = userCredential.user; // _onAuthStateChanged will handle this
      print(
          'AuthProvider (Mobile): Firebase sign-in successful. User will be updated by authStateChanges. User from cred: ${userCredential.user?.displayName}');
      _error = null;
    } on FirebaseAuthException catch (e) {
      print(
          'AuthProvider (Mobile): FirebaseAuthException in _performFirebaseSignInWithGoogleMobile: ${e.code} - ${e.message}');
      _error = e.message ?? e.code;
      throw e; // Re-throw to be caught by the caller if necessary
    } catch (e) {
      print(
          'AuthProvider (Mobile): Generic error in _performFirebaseSignInWithGoogleMobile: $e');
      _error = e.toString();
      throw e; // Re-throw to be caught by the caller
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      print('AuthProvider: Signing out...');
      await _firebaseAuth.signOut();
      // Also sign out from Google Sign-In plugin.
      // For web, if _googleSignIn.signIn() was never called, or if signInWithPopup is used,
      // _googleSignIn.isSignedIn() might be false. It's good practice to call it.
      if (await _googleSignIn.isSignedIn()) {
        print('AuthProvider: Signing out from GoogleSignIn plugin.');
        await _googleSignIn.signOut();
        print('AuthProvider: GoogleSignIn plugin signOut completed.');
      }
      // _user = null; // _onAuthStateChanged will handle this
      _error = null;
      print(
          'AuthProvider: Firebase Sign out successful. User will be updated by authStateChanges.');
    } catch (e) {
      print('AuthProvider: Error during signOut: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Define the Riverpod provider instance
final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});
