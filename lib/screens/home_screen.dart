import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:stanslist/providers/listings_provider.dart';

import '../widgets/app_bar.dart';
import '../widgets/listing_card.dart';
import '../widgets/side_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load listings after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() {
        if (mounted) {
          Provider.of<ListingsProvider>(context, listen: false)
              .refreshListings();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const StansListAppBar(),
      body: Row(
        children: [
          const SidePanel(),
          Expanded(
            child: Consumer<ListingsProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.listings.isEmpty && !provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('No listings yet.',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          'Why not create one?',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Create Listing'),
                          onPressed: () => context.go('/create'),
                        ),
                      ],
                    ),
                  );
                }

                // Display all listings in a Staggered Grid View
                return Padding(
                  padding: const EdgeInsets.all(
                      12.0), // Add some padding around the grid
                  child: MasonryGridView.count(
                    crossAxisCount: MediaQuery.of(context).size.width > 1200
                        ? 4
                        : (MediaQuery.of(context).size.width > 800 ? 3 : 2),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: provider.listings.length,
                    itemBuilder: (context, index) {
                      final listing = provider.listings[index];
                      return ListingCard(listing: listing);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
