import 'package:firebase_auth/firebase_auth.dart'
    hide AuthProvider; // Hide Firebase's AuthProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ensure this import is present
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stanslist/providers/auth_provider.dart';

class StansListAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? titleText;

  const StansListAppBar({
    super.key,
    this.titleText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final User? currentUser = auth.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showLabels = screenWidth > 700;

    // Debug print to check currentUser status in the console
    // print('[StansListAppBar] Building. currentUser UID: ${currentUser?.uid ?? "null"}');

    const String marketplaceIconSvg =
        '''<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m2 7 4.41-4.41A2 2 0 0 1 7.83 2h8.34a2 2 0 0 1 1.42.59L22 7"/><path d="M4 12v8a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-8"/><path d="M15 22v-4a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v4"/><path d="M2 7h20"/><path d="M22 7v3a2 2 0 0 1-2 2a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 16 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 12 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 8 12a2.7 2.7 0 0 1-1.59-.63.7.7 0 0 0-.82 0A2.7 2.7 0 0 1 4 12a2 2 0 0 1-2-2V7"/></svg>''';

    return AppBar(
      title: InkWell(
        onTap: () => context.go('/'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.string(
              marketplaceIconSvg,
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(
                Theme.of(context).appBarTheme.titleTextStyle?.color ??
                    Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 8),
            Text(titleText ??
                "Stan's List"), // Using double quotes for Stan's List
          ],
        ),
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
          style: TextButton.styleFrom(foregroundColor: Colors.white),
        ),
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
            label: showLabels
                ? const Text('My Listings')
                : const SizedBox.shrink(),
            style: TextButton.styleFrom(
                foregroundColor: Colors.white), // Add this line
          ),
          TextButton.icon(
            icon: const Icon(Icons.logout),
            label: showLabels ? const Text('Logout') : const SizedBox.shrink(),
            onPressed: () async {
              await ref.read(authProvider).signOut();
              context.go('/'); // Navigate to home or auth screen after logout
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
          ),
        ],
        const SizedBox(width: 16), // Add some padding to the right edge
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
