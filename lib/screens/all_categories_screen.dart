import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/category.dart';
import '../widgets/app_bar.dart';
import '../widgets/side_panel.dart';

class AllCategoriesScreen extends StatelessWidget {
  const AllCategoriesScreen({super.key});

  // Helper method similar to SidePanel._buildCategoryItem
  Widget _buildCategoryListItem(BuildContext context, Category category) {
    return ListTile(
      leading: Text(category.icon,
          style: const TextStyle(fontSize: 24)), // Slightly larger icon
      title:
          Text(category.name, style: Theme.of(context).textTheme.titleMedium),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/category/${category.id}'),
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0, vertical: 8.0), // Add some padding
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if we should show the side panel
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSidePanel = screenWidth >= 768; // Desktop threshold
    final allCategories = Categories.all; // Get all categories

    return Scaffold(
      appBar: StansListAppBar(
        titleText: 'All Categories',
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Show side panel only on desktop
          if (showSidePanel) const SidePanel(),
          // Main content area
          Expanded(
            child: ListView.separated(
              // Changed from SingleChildScrollView and CategoryGrid
              padding: const EdgeInsets.symmetric(
                  vertical: 8.0), // Add vertical padding to the list
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                return _buildCategoryListItem(context, category);
              },
              separatorBuilder: (context, index) => const Divider(
                  indent: 16, endIndent: 16), // Add a divider between items
            ),
          ),
        ],
      ),
    );
  }
}
