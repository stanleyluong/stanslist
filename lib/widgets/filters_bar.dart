import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../providers/listings_provider.dart';

class FiltersBar extends ConsumerWidget {
  const FiltersBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(listingsProvider);
    final listingsNotifier = ref.read(listingsProvider.notifier);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // Category Filter
        DropdownButton<String>(
          value: provider.selectedCategory.isEmpty
              ? null
              : provider.selectedCategory,
          hint: const Text('All Categories'),
          items: [
            const DropdownMenuItem<String>(
              value: '',
              child: Text('All Categories'),
            ),
            ...Categories.all.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(category.icon),
                    const SizedBox(width: 8),
                    Text(category.name),
                  ],
                ),
              );
            }),
          ],
          onChanged: (value) {
            listingsNotifier.setCategory(value ?? '');
          },
          underline: Container(),
        ),

        const SizedBox(width: 16),

        // Location Filter
        SizedBox(
          width: 200,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Filter by location',
              prefixIcon: Icon(Icons.location_on_outlined, size: 20),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            onChanged: (value) {
              listingsNotifier.setLocation(value);
            },
          ),
        ),

        // Clear Filters Button
        if (provider.selectedCategory.isNotEmpty ||
            provider.selectedLocation.isNotEmpty ||
            provider.searchQuery.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => listingsNotifier.clearFilters(),
            icon: const Icon(Icons.clear, size: 16),
            label: const Text('Clear Filters'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
          ),
      ],
    );
  }
}
