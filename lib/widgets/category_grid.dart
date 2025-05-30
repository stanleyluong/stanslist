import 'package:flutter/material.dart';

import '../models/category.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final Function(Category) onCategorySelected;

  const CategoryGrid({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Get screen width to decide grid layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          // Ensures the constrained grid is centered
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 16),
            constraints: BoxConstraints(
                maxWidth: isMobile ? screenWidth : 840), // More flexible width
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    _getCrossAxisCount(screenWidth), // Responsive column count
                crossAxisSpacing: 4, // Reduced spacing between cards
                mainAxisSpacing: 4, // Reduced spacing between cards
                childAspectRatio: 1.0, // Aim for square cards
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () => onCategorySelected(category),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Helper method to determine number of columns based on screen width
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth < 360) return 2; // Extra small screens
    if (screenWidth < 600) return 3; // Small mobile screens
    if (screenWidth < 768) return 4; // Regular mobile screens
    if (screenWidth < 1024) return 5; // Tablets
    return 6; // Desktop
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Card(
      elevation: 0.5, // Minimal elevation
      margin: EdgeInsets.all(isMobile ? 2 : 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // Slightly larger radius
      ),
      color: Theme.of(context)
          .colorScheme
          .surface, // Use theme surface color instead of blue tint
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 4 : 8), // Responsive padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    category.icon,
                    style: TextStyle(
                        fontSize: isMobile ? 24 : 32), // Responsive icon size
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 4 : 8), // Responsive spacing
              Flexible(
                flex: 2,
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 10 : 12, // Responsive font size
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
