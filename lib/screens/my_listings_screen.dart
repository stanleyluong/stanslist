import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/auth_provider.dart';
import '../providers/listings_provider.dart';
import '../models/listing.dart';
import '../widgets/app_bar.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  Future<List<Listing>>? _myListingsFuture;

  @override
  void initState() {
    super.initState();
    // Ensure that AuthProvider and ListingsProvider are available before calling this
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final listingsProvider = Provider.of<ListingsProvider>(context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser != null) {
        setState(() {
          _myListingsFuture = listingsProvider.getListingsForUser(currentUser.uid);
        });
      } else {
        // If no user is logged in, redirect to auth screen or show a message
        // For now, we'll set future to an empty list or handle error appropriately
        setState(() {
          _myListingsFuture = Future.value([]);
        });
        // Optionally, redirect
        // context.go('/auth');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    if (currentUser == null) {
      // This case should ideally be handled by a route guard or earlier check
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

    return Scaffold(
      appBar: const StansListAppBar(),
      body: FutureBuilder<List<Listing>>(
        future: _myListingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error fetching user listings: \${snapshot.error}');
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("You haven't posted any listings yet."), // Corrected string
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/create'), // Removed const
                    child: const Text('Post a Listing'),
                  )
                ],
              ),
            );
          }

          final userListings = snapshot.data!; // Renamed to avoid conflict
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox( // Ensure DataTable tries to expand
                width: double.infinity,
                child: DataTable(
                  columnSpacing: 20,
                  headingRowColor: WidgetStateColor.resolveWith((states) => Theme.of(context).colorScheme.primaryContainer),
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
                  columns: const [
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Title')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Date Posted')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: userListings.map((listing) {
                    return DataRow(
                      cells: [
                        DataCell(
                          SizedBox( // Constrain image size
                            width: 60,
                            height: 60,
                            child: listing.images.isNotEmpty
                                ? ClipRRect( // Add rounded corners to images
                                    borderRadius: BorderRadius.circular(4.0),
                                    child: Image.network(
                                      listing.images.first,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 40),
                                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.0,
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container( // Placeholder with a border
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade300),
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                                  ),
                          ),
                        ),
                        DataCell(
                          ConstrainedBox( // Constrain title width and allow wrapping
                            constraints: const BoxConstraints(maxWidth: 200), // Adjust maxWidth as needed
                            child: Text(listing.title, overflow: TextOverflow.ellipsis, maxLines: 2),
                          )
                        ),
                        DataCell(Text(NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(listing.price))),
                        DataCell(Chip(label: Text(listing.category), padding: EdgeInsets.zero)),
                        DataCell(Text(DateFormat.yMMMd().format(listing.datePosted))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              tooltip: 'Edit',
                              onPressed: () {
                                context.go('/listing/${listing.id}/edit'); // Placeholder for edit route
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
                              tooltip: 'Delete',
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Confirm Delete'),
                                      content: const Text('Are you sure you want to delete this listing?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                                if (confirm == true) {
                                  try {
                                    await Provider.of<ListingsProvider>(context, listen: false).deleteListing(listing.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Listing deleted'), backgroundColor: Colors.green),
                                    );
                                    // Refresh the list
                                    setState(() {
                                      _myListingsFuture = Provider.of<ListingsProvider>(context, listen: false)
                                          .getListingsForUser(currentUser.uid);
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Failed to delete listing: $e'), backgroundColor: Colors.red),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        )),
                      ],
                      onSelectChanged: (selected) {
                        if (selected ?? false) {
                          // Ensure listing.id is not null or empty before navigating
                          if (listing.id.isNotEmpty) {
                            // Added logging
                            print('Attempting to navigate. Listing ID type: ${listing.id.runtimeType}, Value: "${listing.id}"');
                            final path = '/listing/${listing.id}';
                            print('Generated path for go_router: "$path"');
                            context.go(path);
                          } else {
                            // Added logging
                            print('Navigation skipped: Listing ID is empty.');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error: Listing ID is missing.'), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
