import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';
import '../models/category.dart';

class FiltersBar extends StatelessWidget {
  const FiltersBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ListingsProvider>(
      builder: (context, provider, child) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Category Filter
            DropdownButton<String>(
              value: provider.selectedCategory.isEmpty ? null : provider.selectedCategory,
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
                provider.setCategory(value ?? '');
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
                  provider.setLocation(value);
                },
              ),
            ),

            // Clear Filters Button
            if (provider.selectedCategory.isNotEmpty || 
                provider.selectedLocation.isNotEmpty || 
                provider.searchQuery.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => provider.clearFilters(),
                icon: const Icon(Icons.clear, size: 16),
                label: const Text('Clear Filters'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                ),
              ),
          ],
        );
      },
    );
  }
}
