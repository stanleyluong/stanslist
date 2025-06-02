import 'package:uuid/uuid.dart';

class Listing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String userId; // ID of the user who posted the listing
  final DateTime datePosted;
  final DateTime createdAt;
  final String? imageUrl; // Nullable for listings without images
  final List<String> images; // List of image URLs
  final String location; // e.g., "City, State" or more specific
  final bool isActive;
  final String contactEmail;
  final String? contactPhone;

  // Category-specific fields
  final Map<String, dynamic> categoryFields; // Store category-specific fields

  Listing({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.userId,
    required this.datePosted,
    DateTime? createdAt,
    // this.imageUrl, // Deprecate direct use of single imageUrl in constructor
    List<String>? images,
    required this.location,
    this.isActive = true,
    required this.contactEmail,
    this.contactPhone,
    Map<String, dynamic>? categoryFields,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        images = images ?? [], // Default to empty list if null
        // Derive imageUrl from the images list (e.g., first image or null)
        imageUrl = (images != null && images.isNotEmpty) ? images[0] : null,
        categoryFields = categoryFields ?? {};

  Listing copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? userId,
    DateTime? datePosted,
    DateTime? createdAt,
    // String? imageUrl, // Should be derived from images list if images is also copied
    List<String>? images,
    String? location,
    bool? isActive,
    String? contactEmail,
    String? contactPhone,
    Map<String, dynamic>? categoryFields,
  }) {
    final newImages = images ?? this.images;
    return Listing(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      userId: userId ?? this.userId,
      datePosted: datePosted ?? this.datePosted,
      createdAt: createdAt ?? this.createdAt,
      images: newImages, // Use the newImages list
      // imageUrl is derived by the constructor based on newImages
      location: location ?? this.location,
      isActive: isActive ?? this.isActive,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      categoryFields: categoryFields ?? this.categoryFields,
    );
  }

  // Convert a Listing object into a Map object (for JSON serialization)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        'userId': userId,
        'datePosted': datePosted.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        // 'imageUrl': imageUrl, // Store only the images list
        'images': images, // This is the source of truth for images
        'location': location,
        'isActive': isActive,
        'contactEmail': contactEmail,
        'contactPhone': contactPhone,
        'categoryFields': categoryFields,
      };

  // Extract a Listing object from a Map object (for JSON deserialization)
  factory Listing.fromJson(Map<String, dynamic> json) {
    // Helper function to parse DateTime from various formats
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) return DateTime.parse(value);
      // Handle Firestore Timestamp - check if it has toDate method
      if (value.runtimeType.toString().contains('Timestamp')) {
        return (value as dynamic).toDate();
      }
      return DateTime.now();
    }

    // Handle datePosted - use createdAt as fallback if datePosted is null
    DateTime datePosted;
    if (json['datePosted'] != null) {
      datePosted = parseDateTime(json['datePosted']);
    } else if (json['createdAt'] != null) {
      datePosted = parseDateTime(json['createdAt']);
    } else {
      datePosted = DateTime.now();
    }

    // Handle createdAt
    DateTime createdAt;
    if (json['createdAt'] != null) {
      createdAt = parseDateTime(json['createdAt']);
    } else {
      createdAt = datePosted; // Use datePosted as fallback
    }

    return Listing(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      userId: json['userId'] as String,
      datePosted: datePosted,
      createdAt: createdAt,
      // imageUrl is now derived by constructor, so we pass the images list
      images: json['images'] != null
          ? List<String>.from(json['images'])
          // Fallback for old data: if 'images' is null but 'imageUrl' exists, use it in a list
          : (json['imageUrl'] != null ? [json['imageUrl'] as String] : []),
      location: json['location'] as String,
      isActive:
          json['isActive'] as bool? ?? true, // default to true for old data
      contactEmail:
          json['contactEmail'] as String? ?? 'placeholder@example.com',
      contactPhone: json['contactPhone'] as String?,
      categoryFields: json['categoryFields'] != null
          ? Map<String, dynamic>.from(json['categoryFields'])
          : {},
    );
  }
}
