import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/category.dart'; // Added import for Category model
import '../models/listing.dart';
import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/side_panel.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  Future<void>? _initialLoadListingsFuture; // Renamed and typed for initial load
  String? _loadedListingsForUserId;

  @override
  void initState() {
    super.initState();
    // Initial load is now primarily driven by didChangeDependencies
    // or the first build if auth state is already available.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUser?.uid;

    if (currentUserId != _loadedListingsForUserId) {
      // User has changed, or initial setup
      _loadUserListings(currentUserId);
    } else if (_initialLoadListingsFuture == null && currentUserId != null) {
      // This handles the case where didChangeDependencies is called
      // but the user hasn't changed, yet initial load hasn't been triggered.
      // e.g. navigating back to the screen.
      _loadUserListings(currentUserId);
    }
  }

  void _loadUserListings(String? userId) {
    if (!mounted) return;
    _loadedListingsForUserId = userId;

    if (userId == null) {
      setState(() {
        // Clear future if user logs out
        _initialLoadListingsFuture = Future.value(); 
      });
      return;
    }

    final listingsProvider =
        Provider.of<ListingsProvider>(context, listen: false);
    // Use fetchListingsForUserIfNeeded for the FutureBuilder's future
    // This future completes when listings are available or an error occurs.
    // It doesn't return the list itself, that comes from a sync getter later.
    _initialLoadListingsFuture = listingsProvider.fetchListingsForUserIfNeeded(userId);
    // We might still need a setState here if _initialLoadListingsFuture was null
    // and is now being set, to make the FutureBuilder pick it up.
    if (mounted) {
       setState(() {});
    }
  }

  // _refreshListings is kept in case of pull-to-refresh or explicit refresh button later.
  // For item updates, we rely on provider notifications.
  /* void _refreshListings() {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _loadUserListings(authProvider.currentUser?.uid);
  } */

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // currentUser might be null during transitions, handle gracefully.
    final currentUserId = authProvider.currentUser?.uid;

    if (currentUserId == null) {
      // User not logged in UI
      return Scaffold(
        appBar: const StansListAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Please log in to see your posts.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/auth'),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      );
    }

    // Ensure _loadedListingsForUserId is in sync if build is called before didChangeDependencies
    // or if auth state changes rapidly.
    if (_loadedListingsForUserId != currentUserId) {
        _loadUserListings(currentUserId);
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSidePanel = screenWidth >= 768;

    return Scaffold(
      appBar: const StansListAppBar(),
      body: Row(
        children: [
          if (showSidePanel) const SidePanel(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<void>( // Future is now Future<void>
                    future: _initialLoadListingsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && _loadedListingsForUserId == currentUserId) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error loading listings: ${snapshot.error}'));
                      }

                      // Data is ready or an error occurred, now get listings from provider
                      // Use a Consumer or Provider.of with listen:true here for live updates
                      final listingsProvider = Provider.of<ListingsProvider>(context);
                      final listings = listingsProvider.getCurrentlyLoadedUserListings(currentUserId);

                      if (listings.isEmpty && snapshot.connectionState == ConnectionState.done && !snapshot.hasError) {
                        // Initial load complete, no error, but no listings for this user
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                  "You haven't posted any listings yet."),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => context.go('/create'),
                                child: const Text('Post a Listing'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      // If listings are available (or even if not, but not in initial empty state)
                      return Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: listings.length,
                            itemBuilder: (context, index) {
                              final listing = listings[index];
                              return _MyListingCard(
                                key: ValueKey(listing.id), // Key only depends on ID now
                                listing: listing,
                                // onListingStatusChanged callback is no longer needed for status toggles
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/create'),
        child: const Icon(Icons.add),
        tooltip: 'Create new listing',
      ),
    ); 
  }
}

// Changed _MyListingCard to a StatefulWidget
class _MyListingCard extends StatefulWidget {
  final Listing listing;
  // final VoidCallback onListingStatusChanged; // Removed, not needed for button state update

  const _MyListingCard({
    Key? key,
    required this.listing,
    // required this.onListingStatusChanged,
  }) : super(key: key);

  @override
  _MyListingCardState createState() => _MyListingCardState();
}

class _MyListingCardState extends State<_MyListingCard> {
  @override
  void didUpdateWidget(_MyListingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.isActive != widget.listing.isActive) {
      // If isActive changed, trigger a rebuild of this card
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider =
        Provider.of<ListingsProvider>(context, listen: false);
    final currencyFormatter =
        NumberFormat.currency(symbol: "\$", decimalDigits: 0); 

    final listing = widget.listing;
    final categoryInfo = Categories.getById(listing.category);

    // Helper to format category name if not found in predefined Categories
    String _getFormattedCategoryName() {
      if (categoryInfo != null) {
        return categoryInfo.name; // Use predefined name
      }
      // Format IDs like "for-sale" to "For Sale"
      return listing.category
          .split('-')
          .map((word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
              : '')
          .join(' ');
    }

    String _getCategoryIcon() {
      return categoryInfo?.icon ?? '🏷️'; // Default icon if not found
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      elevation: 2.0,
      child: InkWell(
        onTap: () {
          context.go('/listing/${listing.id}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row( // Main Row: Image on left, details+actions on right
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              SizedBox(
                width: 140, 
                height: 140, 
                child: listing.images.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image.network(
                          listing.images.first,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 60),
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      )
                    : Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: const Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                      ),
              ),
              const SizedBox(width: 12), // Spacer between image and details
              // Details and Actions Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribute space
                  children: [
                    Column( // Text details
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(listing.price),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Chip(
                          avatar: Text(
                            _getCategoryIcon(),
                            style: TextStyle(
                              fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize ?? 16, // Increased icon size
                            ),
                          ),
                          label: Text(_getFormattedCategoryName()), // Use formatted name
                          padding: EdgeInsets.zero,
                          labelStyle: Theme.of(context).textTheme.bodySmall,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(height: 8), 
                        Text( 
                          'Posted: ${DateFormat.yMMMd().format(listing.datePosted)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    // const Spacer(), // Use Spacer if buttons should be at the very bottom
                                     // Or SizedBox for fixed spacing if preferred
                    // Action Buttons
                    LayoutBuilder( 
                      builder: (context, constraints) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        if (screenWidth < 452) { // Changed breakpoint to 452px
                          return PopupMenuButton<String>(
                            icon: const Icon(Icons.more_horiz), 
                            onSelected: (value) async {
                              if (value == 'toggleStatus') {
                                final bool wasActive = listing.isActive;
                                try {
                                  await listingsProvider.toggleListingActiveStatus(listing);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(wasActive ? 'Listing marked as sold.' : 'Listing marked as available.'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Failed to update listing status: $e'),
                                    ),
                                  );
                                }
                              } else if (value == 'share') {
                                final String textToShare =
                                    'Check out this listing: ${listing.title} for ${currencyFormatter.format(listing.price)}\n'
                                    'View it here: ${Uri.base.origin}/#/listing/${listing.id}';
                                Share.share(textToShare, subject: 'Check out this listing: ${listing.title}');
                              } else if (value == 'edit') {
                                context.go('/listing/${listing.id}/edit');
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this listing?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Delete',
                                              style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  try {
                                    await listingsProvider.deleteListing(listing.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Listing deleted')),
                                    );
                                    // Refresh listings after delete
                                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                    if (authProvider.currentUser?.uid != null) {
                                      Provider.of<ListingsProvider>(context, listen: false)
                                        .fetchListingsForUserIfNeeded(authProvider.currentUser!.uid);
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to delete listing: $e')),
                                    );
                                  }
                                }
                              }
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'toggleStatus',
                                child: Text(listing.isActive ? 'Mark as Sold' : 'Mark as Available'),
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
                                child: Text('Delete', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        } else {
                          // Original Wrap layout for wider screens
                          return Wrap(
                            spacing: 2.0,
                            runSpacing: 0.0,
                            alignment: WrapAlignment.start,
                            children: [
                              // 1. Mark as Sold/Available Button
                              Container(
                                constraints: const BoxConstraints(minWidth: 150),
                                child: TextButton.icon(
                                  icon: Icon(listing.isActive ? Icons.visibility_off : Icons.visibility, size: 20),
                                  label: Text(
                                    listing.isActive ? 'Mark as Sold' : 'Mark as Available',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onPressed: () async {
                                    final bool wasActive = listing.isActive;
                                    try {
                                      await listingsProvider.toggleListingActiveStatus(listing);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(wasActive ? 'Listing marked as sold.' : 'Listing marked as available.'),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to update listing status: $e'),
                                        ),
                                      );
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    foregroundColor: listing.isActive ? Colors.orangeAccent : Colors.green,
                                  ),
                                ),
                              ),
                              // 2. Share Button
                              IconButton(
                                icon: const Icon(Icons.share, size: 20),
                                tooltip: 'Share',
                                onPressed: () {
                                  final String textToShare =
                                      'Check out this listing: ${listing.title} for ${currencyFormatter.format(listing.price)}\n'
                                      'View it here: ${Uri.base.origin}/#/listing/${listing.id}';
                                  Share.share(textToShare, subject: 'Check out this listing: ${listing.title}');
                                },
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                              // 3. Edit Button
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: 'Edit',
                                onPressed: () {
                                  context.go('/listing/${listing.id}/edit');
                                },
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                              // 4. Delete Button
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 20, color: Colors.redAccent),
                                tooltip: 'Delete',
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this listing?'),
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete',
                                                style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  if (confirm == true) {
                                    try {
                                      await listingsProvider.deleteListing(listing.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Listing deleted')),
                                      );
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      if (authProvider.currentUser?.uid != null) {
                                        Provider.of<ListingsProvider>(context, listen: false)
                                          .fetchListingsForUserIfNeeded(authProvider.currentUser!.uid);
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Failed to delete listing: $e')),
                                      );
                                    }
                                  }
                                },
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
