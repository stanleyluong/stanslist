import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/category.dart';
import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    final category = Categories.getById(listing.category);

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.go('/listing/${listing.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
 mainAxisSize: MainAxisSize.min,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 1 / 1, // Changed aspect ratio to 1/1 (square)
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: listing.images.isNotEmpty
                    ? Image(
                        image: listing.images.first.startsWith('assets/')
                            ? AssetImage(listing.images.first)
                            : NetworkImage(listing.images.first)
                                as ImageProvider,
                        fit: BoxFit.cover,
                      )
                    : Center(
                        child: Icon(
                          Icons.image,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
              ),
            ),

            // Content
 Flexible( // Wrap the Padding with Expanded
              child: Padding(
                padding: const EdgeInsets.all(8),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha((255 * 0.1).round()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            category?.icon ?? '📦',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 2),
                          Flexible(
                            child: Text(
                              category?.name ?? listing.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),

                    // Title
                    Text(
                      listing.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
 fontWeight: FontWeight.bold,
                            fontSize: 14, // Reduced font size
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1), // Reduced spacing

                    // Price
                    Text(
                      NumberFormat.currency(symbol: '\$', decimalDigits: 0)
                          .format(listing.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith( // Changed from titleLarge
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            // fontSize: 16, // Optionally reduce price font size further if needed
                          ),
                    ), // Reduced spacing
                    const SizedBox(height: 4), // Reduced spacing

                    // Location and date
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 11,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 2),
                        Flexible(
                          child: Text(
                            '${listing.location} • ${DateFormat.yMMMd().format(listing.createdAt)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600.withAlpha(200),
                                    ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ), // Closing the inner Row
                  ], // Closing the inner Column's children list
                ), // Closing the inner Column
              ), // Closing the Padding
            ), // Closing the Expanded
          ], // Closing the outer Column's children list
        ), // Closing the outer Column
      ), // Closing the InkWell
    ); // Closing the Card
  }
}
