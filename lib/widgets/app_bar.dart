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
    final authProvider = context.watch<AuthProvider>();
    final User? currentUser = authProvider.currentUser;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showLabels = screenWidth > 700; // Breakpoint for showing labels

    // Debug print to check currentUser status in the console
    print(
        '[StansListAppBar] Building. currentUser UID: ${currentUser?.uid ?? "null"}');

    return AppBar(
      title: InkWell(
        // Wrap the Text widget in an InkWell
        onTap: () => context.go('/'), // Add onTap to navigate to homepage
        child: Text(titleText ?? 'Stan\'s List'), // Modify this line
      ),
      actions: [
        TextButton.icon(
          onPressed: () => context.go('/listings'),
          icon: const Icon(Icons.search),
          label: showLabels ? const Text('Browse') : const SizedBox.shrink(),
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
        // Only show categories button on mobile (less than 768px)
        if (MediaQuery.of(context).size.width < 768)
          TextButton.icon(
            onPressed: () => context.go('/categories'),
            icon: const Icon(Icons.category),
            label:
                showLabels ? const Text('Categories') : const SizedBox.shrink(),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        TextButton.icon(
          onPressed: () {
            context.go('/create');
          },
          icon: const Icon(Icons.add),
          label: showLabels ? const Text('Post') : const SizedBox.shrink(),
          style: TextButton.styleFrom(
              foregroundColor: Colors.white), // Add this line
        ),
        // const SizedBox(width: 4), // Spacing might not be needed if labels are hidden
        if (currentUser == null) ...[
          TextButton(
            onPressed: () => context.go('/auth'),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: showLabels ? 12 : 8, vertical: 8),
            ),
            child: showLabels
                ? const Text('Login')
                : const Icon(Icons.login, size: 20), // Show icon if no label
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () {
              // Corrected route from /my-posts to /my-posts
              context.go('/my-posts');
            },
            icon: const Icon(Icons.list_alt),
            label:
                showLabels ? const Text('My Posts') : const SizedBox.shrink(),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white), // Add this line
          ),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().signOut();
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey[600],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                  horizontal: showLabels ? 12 : 8, vertical: 8),
            ),
            child: showLabels
                ? const Text('Logout')
                : const Icon(Icons.logout, size: 20), // Show icon if no label
          ),
        ],
        const SizedBox(width: 8), // Reduced width
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
