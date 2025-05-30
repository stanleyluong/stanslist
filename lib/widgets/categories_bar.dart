import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/category.dart';

class CategoriesBar extends StatelessWidget {
  final List<Category> categories;

  const CategoriesBar({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Only show this on mobile
    if (!isMobile) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
            child: Text(
              'Categories',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryButton(category: category);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryButton extends StatelessWidget {
  final Category category;

  const CategoryButton({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.go('/category/${category.id}'),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withAlpha(51), // 0.2 * 255 = 51
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  category.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 65,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
