import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider; // Hide Firebase's AuthProvider
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
class StansListAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText; // Add this line

  const StansListAppBar({
    super.key,
    this.titleText, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    // Use context.watch to listen to AuthProvider changes
    final authProvider = context.watch<AuthProvider>();
    final User? currentUser = authProvider.currentUser;

    // Debug print to check currentUser status in the console
    print(
        '[StansListAppBar] Building. currentUser UID: ${currentUser?.uid ?? "null"}');

    return AppBar(
      title: InkWell( // Wrap the Text widget in an InkWell
        onTap: () => context.go('/'), // Add onTap to navigate to homepage
        child: Text(titleText ?? 'Stan\'s List'), // Modify this line
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/listings'),
          icon: const Icon(Icons.search),
          label: const Text('Browse'),
          style: TextButton.styleFrom(foregroundColor: Colors.white), // Add this line
        ),
        TextButton.icon(
          onPressed: () {
            context.go('/create');
          },
          icon: const Icon(Icons.add),

          style: TextButton.styleFrom(foregroundColor: Colors.white), // Add this line
          label: const Text('Post'),
        ),
        const SizedBox(width: 4), // Reduced width
        if (currentUser == null) ...[
          TextButton(
            onPressed: () => context.go('/auth'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8), // Reduced horizontal padding
            ),
            child: const Text('Login'),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () {
              context.go('/my-posts');
            },
            icon: const Icon(Icons.list_alt),
            label: const Text('My Posts'),
            style: TextButton.styleFrom(foregroundColor: Colors.white), // Add this line
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8), // Reduced horizontal padding
            ),
            child: const Text('Logout'),
          ),
        ],
        const SizedBox(width: 8), // Reduced width
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
