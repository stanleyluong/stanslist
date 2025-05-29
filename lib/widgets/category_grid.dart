import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/category.dart';

class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          // Ensures the constrained grid is centered
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 4), // Further reduced padding for the grid area
            constraints: const BoxConstraints(
                maxWidth: 320), // Significantly reduced max width
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Strictly 3 columns
                crossAxisSpacing: 4, // Reduced spacing between cards
                mainAxisSpacing: 4, // Reduced spacing between cards
                childAspectRatio: 1.0, // Aim for square cards
              ),
              itemCount: Categories.all.length,
              itemBuilder: (context, index) {
                final category = Categories.all[index];
                return CategoryCard(category: category);
              },
            ),
          ),
        );
      },
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  const CategoryCard({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.5, // Minimal elevation
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Small radius
      ),
      child: InkWell(
        onTap: () => context.go('/category/${category.id}'),
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding:
              const EdgeInsets.all(4), // Further reduced padding inside card
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
                    style: const TextStyle(
                        fontSize: 22), // Slightly adjusted icon size
                  ),
                ),
              ),
              const SizedBox(height: 2), // Minimal spacing
              Flexible(
                flex: 2,
                child: Text(
                  category.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Adjusted font size
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
