import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/listing.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
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
              aspectRatio: 1 / 1, // Square aspect ratio
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
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Keep content compact
                children: [
                  // Price (Moved up)
                  Text(
                    NumberFormat.currency(
                            symbol: '\$',
                            decimalDigits: 0) // Corrected currency symbol
                        .format(listing.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4), // Spacing after price

                  // Title
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4), // Spacing after title

                  // Location and date
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          // Using just location for now, like Facebook Marketplace
                          listing.location,
                          // '${listing.location} • ${DateFormat.yMMMd().format(listing.createdAt)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey.shade600.withAlpha(200),
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
