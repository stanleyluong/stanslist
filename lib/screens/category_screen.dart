import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../providers/listings_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/listing_card.dart';
import '../widgets/side_panel.dart';

class CategoryScreen extends ConsumerWidget {
  final String category;

  const CategoryScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryInfo = Categories.getById(category);

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
                // Category Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withAlpha((255 * 0.1).round()),
                  ),
                  child: Column(
                    children: [
                      Text(
                        categoryInfo?.icon ?? '📦',
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categoryInfo?.name ?? category,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        categoryInfo?.description ??
                            'Browse listings in this category',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Listings
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final listingsState = ref.watch(listingsProvider);
                      final listings =
                          listingsState.getListingsByCategory(category);

                      if (listings.isEmpty && !listingsState.isLoading) {
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
                                'No listings in this category yet',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to post something!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.grey.shade500,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (listingsState.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _getCrossAxisCount(context),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
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
