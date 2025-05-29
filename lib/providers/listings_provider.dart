import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/listing.dart';

class ListingsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Listing> _listings = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedLocation = '';

  List<Listing> get listings => _filteredListings();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedLocation => _selectedLocation;

  ListingsProvider() {
    // _loadListings(); // Removed: Listings are loaded via refreshListings called from UI post-build
  }

  List<Listing> _filteredListings() {
    var filtered = _listings.where((listing) => listing.isActive).toList();

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((listing) =>
              listing.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              listing.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_selectedCategory.isNotEmpty) {
      filtered = filtered
          .where((listing) => listing.category == _selectedCategory)
          .toList();
    }

    if (_selectedLocation.isNotEmpty) {
      filtered = filtered
          .where((listing) => listing.location
              .toLowerCase()
              .contains(_selectedLocation.toLowerCase()))
          .toList();
    }

    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setLocation(String location) {
    _selectedLocation = location;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedLocation = '';
    notifyListeners();
  }

  Future<void> addListing(Listing listing) async {
    try {
      // Add to Firestore
      final docRef =
          await _firestore.collection('listings').add(listing.toJson());

      // Update the listing with the Firestore document ID and use the images list
      final updatedListing = Listing(
        id: docRef.id,
        title: listing.title,
        description: listing.description,
        price: listing.price,
        category: listing.category,
        images: listing.images, // Use the images list
        location: listing.location,
        contactEmail: listing.contactEmail,
        contactPhone: listing.contactPhone,
        userId: listing.userId,
        datePosted: listing.datePosted,
        createdAt: listing.createdAt,
        isActive: listing.isActive,
        categoryFields:
            listing.categoryFields, // Ensure categoryFields are passed
      );

      // Update the document with the ID and the full updated listing data
      // This ensures that the `images` field (and derived `imageUrl`) are correct in Firestore
      await _firestore.collection('listings').doc(docRef.id).set(
          updatedListing.toJson()); // Use set to ensure all fields are updated

      // Add to local list
      _listings.add(updatedListing);
      notifyListeners();
    } catch (e) {
      print('Error adding listing: $e');
      throw e;
    }
  }

  Future<void> updateListing(String id, Listing updatedListing) async {
    try {
      // Update in Firestore
      await _firestore
          .collection('listings')
          .doc(id)
          .update(updatedListing.toJson());

      // Update in local list
      final index = _listings.indexWhere((listing) => listing.id == id);
      if (index != -1) {
        _listings[index] = updatedListing;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating listing: $e');
      throw e;
    }
  }

  Future<void> deleteListing(String id) async {
    try {
      // Delete from Firestore
      await _firestore.collection('listings').doc(id).delete();

      // Remove from local list
      _listings.removeWhere((listing) => listing.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting listing: $e');
      throw e;
    }
  }

  Listing? getListingById(String id) {
    try {
      return _listings.firstWhere((listing) => listing.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Listing> getListingsByCategory(String category) {
    return _listings
        .where((listing) => listing.category == category && listing.isActive)
        .toList();
  }

  Future<void> _loadListings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('listings')
          .orderBy('createdAt', descending: true)
          .get();

      _listings = querySnapshot.docs.map((doc) {
        final data = doc.data();
        // Ensure the ID from the document is used
        data['id'] = doc.id;
        return Listing.fromJson(data);
      }).toList();
    } catch (e) {
      print('Error loading listings: $e');
      _listings = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Method to refresh listings from Firestore
  Future<void> refreshListings() async {
    await _loadListings();
  }

  // Method to get listings for a specific user
  Future<List<Listing>> getListingsForUser(String userId) async {
    // Ensure all listings are loaded if not already
    if (_listings.isEmpty && !_isLoading) {
      await _loadListings();
    }
    // Filter listings by userId
    return _listings.where((listing) => listing.userId == userId).toList();
  }
}
