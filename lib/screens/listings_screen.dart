import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/listings_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/filters_bar.dart';
import '../widgets/listing_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/side_panel.dart';

class ListingsScreen extends ConsumerWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Determine if we should show the side panel
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSidePanel = screenWidth >= 768; // Desktop threshold

    return Scaffold(
      appBar: const StansListAppBar(),
      body: Row(
        children: [
          // Show side panel on desktop view
          if (showSidePanel) const SidePanel(),
          // Main content area
          Expanded(
            child: Column(
              children: [
                // Search and Filters
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.1).round()),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      StansListSearchBar(),
                      SizedBox(height: 16),
                      FiltersBar(),
                    ],
                  ),
                ),

                // Listings Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final provider = ref.watch(listingsProvider);
                      final listingsNotifier =
                          ref.read(listingsProvider.notifier);

                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final listings = provider.listings;

                      if (listings.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No listings found',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () =>
                                    listingsNotifier.clearFilters(),
                                child: const Text('Clear Filters'),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(context),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: listings.length,
                        itemBuilder: (context, index) {
                          return ListingCard(listing: listings[index]);
                        },
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
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 1;
  }
}
