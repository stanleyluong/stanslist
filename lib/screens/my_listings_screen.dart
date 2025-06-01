import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stanslist/models/listing.dart';
import 'package:stanslist/providers/auth_provider.dart';
import 'package:stanslist/providers/listings_provider.dart';
import 'package:stanslist/widgets/app_bar.dart'; // Import StansListAppBar
import 'package:stanslist/widgets/delete_confirmation_dialog.dart';
import 'package:stanslist/widgets/side_panel.dart'; // Import SidePanel

class MyListingsScreen extends ConsumerStatefulWidget {
  const MyListingsScreen({super.key});

  @override
  ConsumerState<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends ConsumerState<MyListingsScreen> {
  Future<void>? _initialLoadListingsFuture;
  String? _loadedListingsForUserId;

  @override
  void initState() {
    super.initState();
    // Delaying the initial load until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still in the tree (mounted) before using ref.
      if (mounted) {
        final user = ref.read(authProvider).user;
        if (user != null && _loadedListingsForUserId != user.uid) {
          _loadUserListings(user.uid);
        } else if (user == null && _loadedListingsForUserId != null) {
          _loadUserListings(null); // Clear listings if user logged out
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = ref.watch(authProvider).user; // Watch for auth changes
    if (user != null && _loadedListingsForUserId != user.uid) {
      _loadUserListings(user.uid);
    } else if (user == null && _loadedListingsForUserId != null) {
      _loadUserListings(null);
    }
  }

  void _loadUserListings(String? userId) {
    _loadedListingsForUserId = userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _initialLoadListingsFuture = Future.value();
        });
      }
      return;
    }
    final listingsNotifier = ref.read(listingsProvider);
    // Fetch listings for the user; this future is used by the FutureBuilder
    _initialLoadListingsFuture =
        listingsNotifier.fetchListingsForUserIfNeeded(userId);
    if (mounted) {
      // This setState will trigger a rebuild if needed, allowing FutureBuilder to pick up the new future.
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUserId = authState.user?.uid;
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width
    final bool showSidePanel = screenWidth >= 768; // Determine if side panel should be shown

    if (currentUserId == null) {
      return Scaffold(
        appBar: const StansListAppBar(), // Use StansListAppBar
        body: Row( // Added Row for potential side panel
          children: [
            if (showSidePanel) const SidePanel(), // Show side panel if applicable
            const Expanded(
              child: Center(
                child: Text('Please log in to see your listings.'),
              ),
            ),
          ],
        ),
      );
    }

    // Ensure that listings are loaded for the current user.
    // This handles cases where the widget is built before initState/didChangeDependencies fully resolves the user.
    if (_loadedListingsForUserId != currentUserId) {
      // This might be called during a build, schedule for after frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserListings(currentUserId);
      });
    }

    return Scaffold(
      appBar: const StansListAppBar(), // Use StansListAppBar
      body: Row( // Wrap body content with Row
        children: [
          if (showSidePanel) const SidePanel(), // Add SidePanel here
          Expanded( // Wrap FutureBuilder with Expanded
            child: FutureBuilder<void>(
              future: _initialLoadListingsFuture,
              builder: (context, snapshot) {
                // Use _loadedListingsForUserId to ensure we are showing data for the correct user,
                // especially during transitions (login/logout).
                if (snapshot.connectionState == ConnectionState.waiting &&
                    (_initialLoadListingsFuture != null &&
                        _loadedListingsForUserId == currentUserId)) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                          'Error loading listings: ${snapshot.error}\nSource: FutureBuilder'));
                }

                final listingsNotifier = ref.watch(listingsProvider);
                // Get listings specifically for the current user from the provider's cache.
                final listings =
                    listingsNotifier.getCurrentlyLoadedUserListings(currentUserId);

                if (listings.isEmpty &&
                    snapshot.connectionState == ConnectionState.done &&
                    !snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('You haven\'t posted any listings yet.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/create-listing'),
                          child: const Text('Create Your First Listing'),
                        ),
                      ],
                    ),
                  );
                }

                // Display listings only if they belong to the currently active user for whom they were loaded.
                if (listings.isNotEmpty &&
                    _loadedListingsForUserId == currentUserId) {
                  return ListView.builder(
                    itemCount: listings.length,
                    itemBuilder: (context, index) {
                      final listing = listings[index];
                      return _MyListingCard(
                          listing: listing, currentUserId: currentUserId);
                    },
                  );
                }
                // Fallback or if _loadedListingsForUserId != currentUserId (e.g. user just logged out, waiting for UI to update)
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MyListingCard extends ConsumerWidget {
  final Listing listing;
  final String currentUserId;

  const _MyListingCard({required this.listing, required this.currentUserId});

  Future<void> _performShare(
      BuildContext context, WidgetRef ref, Listing listing) async {
    final currencyFormatter =
        NumberFormat.currency(symbol: "\$", decimalDigits: 0);
    final String textToShare =
        'Check out this listing: ${listing.title} for ${currencyFormatter.format(listing.price)}\n'
        'View it here: ${Uri.base.origin}/#/listing/${listing.id}';
    
    // Updated to use SharePlus.instance.share(ShareParams(...)) as per documentation for v11.0.0
    await SharePlus.instance.share(
      ShareParams(
        text: textToShare,
        subject: 'Check out this listing on Stan\'s List!'
      )
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Listing listing) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return DeleteConfirmationDialog(
          itemName: listing.title,
          onConfirm: () async {
            Navigator.of(dialogContext).pop(); // Close the dialog
            try {
              await ref.read(listingsProvider).deleteListing(listing.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('"${listing.title}" deleted successfully.')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting listing: $e')),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsNotifier = ref.read(listingsProvider);
    final currencyFormatter =
        NumberFormat.currency(symbol: "\$", decimalDigits: 0);

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (listing.images.isNotEmpty)
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: listing.images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.network(
                        listing.images[index],
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image, size: 50),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            Text(
              listing.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              currencyFormatter.format(listing.price),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Category: ${listing.category}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Posted: ${DateFormat.yMMMd().format(listing.datePosted)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Status: ${listing.isActive ? 'Active' : 'Inactive'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: listing.isActive ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'toggle_active') {
                      await listingsNotifier.toggleListingActiveStatus(listing);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('"${listing.title}" status updated.')),
                        );
                      }
                    } else if (value == 'share') {
                      _performShare(context, ref, listing);
                    } else if (value == 'edit') {
                      context.go('/edit-listing/${listing.id}');
                    } else if (value == 'delete') {
                      _confirmDelete(context, ref, listing);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'toggle_active',
                      child: Text(listing.isActive
                          ? 'Set as Inactive'
                          : 'Set as Active'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'share',
                      child: Text('Share'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
                IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _performShare(context, ref, listing)),
                IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/edit-listing/${listing.id}')),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, ref, listing),
                  tooltip: 'Delete Listing',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
