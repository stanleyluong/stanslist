import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import ConsumerWidget and WidgetRef
import 'package:go_router/go_router.dart';

// import 'package:provider/provider.dart'; // Remove provider import

import '../models/category.dart';
import 'search_bar.dart'; // Assuming StansListSearchBar will handle its own provider needs

class SidePanel extends ConsumerWidget {
  // Change to ConsumerWidget
  const SidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Add WidgetRef ref
    // final listingsProviderInstance = ref.watch(listingsProvider); // Watch if needed, or read if only for actions
    // For StansListSearchBar, if it needs to interact with ListingsProvider, it should also be a ConsumerWidget.
    // Assuming StansListSearchBar is or will be converted to a ConsumerWidget and will use `ref` internally.

    return Container(
      width: 280, // Adjust width as needed
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Match scaffold background color
        border: Border(
          right: BorderSide(
              color: Colors.grey.shade300, width: 1), // Add subtle border
        ),
      ),
      child: ListView(
        children: [
          Text(
            'Marketplace',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // Search bar widget for marketplace
          const StansListSearchBar(), // Assuming StansListSearchBar is a ConsumerWidget or uses ref
          const SizedBox(height: 20),
          _buildExpansionTile(
            context: context,
            icon: Icons.shopping_bag_outlined,
            title: 'Browse all',
            onTap: () => context.go('/listings'),
          ),
          const Divider(),
          _buildExpansionTile(
            context: context,
            icon: Icons.add_circle_outline,
            title: 'Create new listing',
            onTap: () => context.go('/create'),
          ),
          // Potentially add other links like "Buying", "Selling" based on auth status
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Categories',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          ...Categories.all
              .map((category) => _buildCategoryItem(context, category))
              .toList(),
          const Divider(),
          // Add other items like "Location", "Filters" if needed
        ],
      ),
    );
  }

  Widget _buildExpansionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    List<Widget>? children,
  }) {
    if (children == null || children.isEmpty) {
      return ListTile(
        leading:
            Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        onTap: onTap,
        dense: true,
        contentPadding: EdgeInsets.zero,
      );
    }
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      children: children,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 16),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category) {
    return ListTile(
      leading: Text(category.icon, style: const TextStyle(fontSize: 18)),
      title: Text(category.name, style: Theme.of(context).textTheme.bodyMedium),
      onTap: () => context.go('/category/${category.id}'),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      visualDensity: VisualDensity.compact,
    );
  }
}
