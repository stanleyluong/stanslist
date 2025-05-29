import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/listings_provider.dart';

class StansListSearchBar extends StatefulWidget {
  const StansListSearchBar({super.key});

  @override
  State<StansListSearchBar> createState() => _StansListSearchBarState();
}

class _StansListSearchBarState extends State<StansListSearchBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final provider = context.read<ListingsProvider>();
    _searchController.text = provider.searchQuery;
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
                    context.read<ListingsProvider>().setSearchQuery('');
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          context.read<ListingsProvider>().setSearchQuery(value);
        },
        onSubmitted: (value) {
          context.read<ListingsProvider>().setSearchQuery(value);
        },
      ),
    );
  }
}
