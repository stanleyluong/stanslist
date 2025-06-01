import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stanslist/providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleSignIn(Future<void> Function() signInMethod) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await signInMethod();
      // Navigation or further actions will be handled by the AuthProvider listener
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
      // _showErrorDialog(_errorMessage!); // Keep or remove based on whether you want a dialog for errors here
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // void _showErrorDialog(String message) { // Removed as it's not currently used, can be re-added if dialogs are preferred over inline messages
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text('An Error Occurred'),
  //       content: Text(message),
  //       actions: <Widget>[
  //         TextButton(
  //           child: const Text('Okay'),
  //           onPressed: () {
  //             Navigator.of(ctx).pop();
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider); // Correctly watch the provider

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    _errorMessage!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              if (authState.user == null) ...[
                // Use authState.user
                if (_isLoading) const CircularProgressIndicator(),
                if (!_isLoading) ...[
                  OutlinedButton.icon(
                    icon: Image.asset( // Changed from SvgPicture.asset
                      'assets/google-icon-2048x2048-czn3g8x8.png', // Updated path
                      height: 24.0, // Adjust size as needed
                    ),
                    label: const Text('Sign in with Google'),
                    onPressed: () => _handleSignIn(ref
                        .read(authProvider)
                        .signInWithGoogle), // Use ref.read(authProvider) to call method
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Placeholder for Apple Sign In button
                  // OutlinedButton.icon(
                  //   icon: Icon(Icons.apple, color: Colors.black), // Example Apple icon
                  //   label: const Text('Sign in with Apple'),
                  //   onPressed: () {
                  //     // TODO: Implement Apple Sign In
                  //     print('Apple Sign In clicked');
                  //   },
                  //   style: OutlinedButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  //     textStyle: const TextStyle(fontSize: 16, color: Colors.black),
                  //     side: BorderSide(color: Colors.grey.shade400),
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(8),
                  //     ),
                  //   ),
                  // ),
                ],
              ] else ...[
                Text(
                    'You are signed in as ${authState.user!.displayName ?? authState.user!.email}!'), // Display user info
                const SizedBox(height: 20),
                ElevatedButton(
                  child: const Text('Sign Out'),
                  onPressed: () async {
                    await ref
                        .read(authProvider)
                        .signOut(); // Use ref.read(authProvider) to call method
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
