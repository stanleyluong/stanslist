import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/listings_provider.dart';

class StansListSearchBar extends ConsumerStatefulWidget {
  const StansListSearchBar({super.key});

  @override
  ConsumerState<StansListSearchBar> createState() => _StansListSearchBarState();
}

class _StansListSearchBarState extends ConsumerState<StansListSearchBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final provider = ref.read(listingsProvider);
        _searchController.text = provider.searchQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search listings...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(listingsProvider).setSearchQuery('');
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          ref.read(listingsProvider).setSearchQuery(value);
          setState(() {});
        },
        onSubmitted: (value) {
          ref.read(listingsProvider).setSearchQuery(value);
        },
      ),
    );
  }
}
