import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ConsumerStatefulWidget, ConsumerState, and WidgetRef
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
// import 'package:provider/provider.dart'; // Remove provider import
import 'package:stanslist/providers/listings_provider.dart';

import '../widgets/app_bar.dart';
import '../widgets/listing_card.dart';
import '../widgets/side_panel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  // Change to ConsumerStatefulWidget
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() =>
      _HomeScreenState(); // Change to ConsumerState
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Change to ConsumerState<HomeScreen>
  @override
  void initState() {
    super.initState();
    // Load listings after the first frame is built using ref.read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future(() {
        if (mounted) {
          ref.read(listingsProvider).refreshListings(); // Use ref.read
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // No need for WidgetRef here as it's available via `ref` member
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSidePanel =
        screenWidth > 768; // Example breakpoint, adjust as needed

    // Watch the listingsProvider for changes
    final listingsState = ref.watch(listingsProvider);

    return Scaffold(
      appBar: const StansListAppBar(),
      body: Row(
        children: [
          if (showSidePanel) // Conditionally display SidePanel
            const SidePanel(),
          Expanded(
            // No longer need Consumer<ListingsProvider> here, as we use ref.watch above
            child: () {
              if (listingsState.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (listingsState.listings.isEmpty && !listingsState.isLoading) {
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
              return Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(
                          12.0), // Add some padding around the grid
                      child: MasonryGridView.count(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200
                            ? 4
                            : (MediaQuery.of(context).size.width > 800 ? 3 : 2),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: listingsState.listings.length,
                        itemBuilder: (context, index) {
                          final listing = listingsState.listings[index];
                          return ListingCard(listing: listing);
                        },
                      ),
                    ),
                  ),
                ],
              );
            }(),
          ),
        ],
      ),
    );
  }
}
