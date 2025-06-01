import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/listings_provider.dart';
import 'listing_card.dart';

class FeaturedListings extends ConsumerWidget {
  const FeaturedListings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsState = ref.watch(listingsProvider);

    if (listingsState.isLoading && listingsState.listings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final listings = listingsState.listings.take(6).toList();

    if (listings.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No listings yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Be the first to post a listing!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 300,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: listings.length,
        itemBuilder: (context, index) {
          return Container(
            width: 250,
            margin: const EdgeInsets.only(right: 16),
            child: ListingCard(listing: listings[index]),
          );
        },
      ),
    );
  }
}
