import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  // Unified handler for Google Sign-In, called by both web and mobile buttons.
  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // AuthProvider.signInWithGoogle() will call _googleSignIn.signIn()
      // The onCurrentUserChanged listener in AuthProvider handles the rest.
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
      // If sign-in is successful, AuthProvider will notify listeners,
      // and UI should react accordingly (e.g., navigate away).
      // We might not need to set _isLoading = false here if navigation occurs.
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to sign in with Google: ${e.toString()}';
        });
      }
    }
  }

  Widget _buildGoogleSignInButton(BuildContext context) {
    // Common button for both platforms now
    return OutlinedButton.icon(
      icon: Image.asset('assets/google-icon-2048x2048-czn3g8x8.png', height: 24.0),
      label: const Text('Sign in with Google'),
      onPressed: _isLoading ? null : _handleGoogleSignIn, // Unified handler
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade400),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Register'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to Stan\'s List',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                _buildGoogleSignInButton(context), // Use the unified button
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
