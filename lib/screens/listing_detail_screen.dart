// Add these imports for web map display
// import 'dart:ui' as ui; // Keep for other UI elements if needed, or remove if not used elsewhere
// ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html; // Removed deprecated import
// import 'dart:ui_web' as ui_web; // Removed deprecated import, not needed for GoogleMap widget

import 'package:flutter/foundation.dart' show kIsWeb, Factory; // Ensure Factory is imported
import 'package:flutter/gestures.dart'; // For EagerGestureRecognizer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/category.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/side_panel.dart';

class ListingDetailScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState(); // Changed to ConsumerState
}

class _ListingDetailScreenState extends ConsumerState<ListingDetailScreen> {
  // Changed to extend ConsumerState
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isFetchingListing = false; // To prevent multiple fetches
  // GoogleMapController? _mapController; // Commented out as it's unused for now

  // Access the API key passed via --dart-define
  static const String _googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '', // Ensure this is an empty string
  );

  @override
  void initState() {
    super.initState();
    // Attempt to fetch the listing if not already available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(listingsProvider); // Changed to ref.read
      final listing = provider.getListingById(widget.listingId);
      if (listing == null && !provider.isLoading && !_isFetchingListing) {
        setState(() {
          _isFetchingListing = true;
        });
        ref.read(listingsProvider).refreshListings().then((_) {
          if (mounted) {
            setState(() {
              _isFetchingListing = false;
            });
          }
        }).catchError((_) {
          if (mounted) {
            setState(() {
              _isFetchingListing = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose(); // Dispose controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool showSidePanel = screenWidth >= 768;
    final bool showDetailsPanelAside = screenWidth >= 1050;

    final listingsState = ref.watch(listingsProvider);

    if (_isFetchingListing ||
        (listingsState.isLoading && listingsState.listings.isEmpty)) {
      return Scaffold(
        appBar: const StansListAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final listing = listingsState.getListingById(widget.listingId);

    if (listing == null) {
      return Scaffold(
        appBar: const StansListAppBar(),
        body: const Center(
          child: Text('Listing not found'),
        ),
      );
    }

    final images = listing.images.isEmpty
        ? ['assets/images/placeholder-image.jpg']
        : listing.images;

    // Define the details content widget once
    Widget buildDetailsContent(BuildContext context, Listing currentListing) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            currentListing.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),

          // Price
          Text(
            NumberFormat.currency(
                    symbol: '\$', // Corrected escape for dollar sign
                    decimalDigits: 0)
                .format(currentListing.price),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Category chip
          Row(
            children: [
              const Icon(Icons.category_outlined, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Chip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Categories.getById(currentListing.category)?.icon ??
                            '📦',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          Categories.getById(currentListing.category)?.name ??
                              currentListing.category,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withAlpha((255 * 0.1).round()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Location and date
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  currentListing.location,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                "Posted ${DateFormat.yMMMd().format(currentListing.createdAt)}",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const Divider(height: 30),

          // Category-specific details (if available)
          if (currentListing.categoryFields.isNotEmpty) ...[
            Text(
              'Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            _buildCategorySpecificDetails(context, currentListing),
            const Divider(height: 30),
          ],

          // Location Map
          if (currentListing.location.isNotEmpty) ...[
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250, // Adjust height as needed
              width: double.infinity,
              child: _buildMapView(currentListing.location),
            ),
            const SizedBox(height: 10), // Add some space before the button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _launchDirections(currentListing.location),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const Divider(height: 30),
          ],

          // Description
          Text(
            'Description',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            currentListing.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(height: 30),

          // Contact Information
          Text(
            'Contact Seller',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Email button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchEmail(currentListing.contactEmail),
              icon: const Icon(Icons.email),
              label: Text('Email: ${currentListing.contactEmail}'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),

          // Phone button (if available)
          if (currentListing.contactPhone != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _launchPhone(currentListing.contactPhone!),
                icon: const Icon(Icons.phone),
                label: Text('Call: ${currentListing.contactPhone}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ],
      );
    }

    Widget detailsContent = buildDetailsContent(context, listing);

    return Scaffold(
      appBar: const StansListAppBar(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSidePanel) const SidePanel(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LayoutBuilder(builder: (context, constraints) {
                    final bool isNarrow = constraints.maxWidth < 400;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 500,
                          ),
                          margin: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: isNarrow ? 0 : 8,
                          ),
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withAlpha((255 * 0.1).round()),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                )
                              ]),
                          child: images.isNotEmpty
                              ? PageView.builder(
                                  controller: _pageController,
                                  itemCount: images.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _selectedImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image(
                                        image:
                                            images[index].startsWith('assets/')
                                                ? AssetImage(images[index])
                                                : NetworkImage(images[index])
                                                    as ImageProvider,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Try to load as asset if network fails, or vice-versa (basic fallback)
                                          // This is a simple fallback, a more robust solution might be needed
                                          final isAsset = images[index].startsWith('assets/');
                                          return Image(
                                            image: isAsset ? NetworkImage(images[index].replaceFirst('assets/', '')) : AssetImage('assets/' + images[index]) as ImageProvider,
                                            fit: BoxFit.contain,
                                            errorBuilder: (ctx, err, st) => const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 64,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Icon(
                                    Icons.image,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        if (images.length > 1)
                          Container(
                            height: 80,
                            margin: EdgeInsets.symmetric(
                              horizontal: isNarrow ? 0 : 8,
                              vertical: 10,
                            ),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImageIndex = index;
                                      _pageController.animateToPage(
                                        index,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    });
                                  },
                                  child: Container(
                                    width: 80,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                        border: _selectedImageIndex == index
                                            ? Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                width: 2.5)
                                            : Border.all(
                                                color: Colors.grey.shade400,
                                                width: 1),
                                        borderRadius: BorderRadius.circular(8),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0x1A000000), // Replaced Colors.black.withOpacity(0.1)
                                            spreadRadius: 0,
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          )
                                        ]),
                                    child: Opacity(
                                      opacity: _selectedImageIndex == index
                                          ? 1.0
                                          : 0.7,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image(
                                          image: images[index]
                                                  .startsWith('assets/')
                                              ? AssetImage(images[index])
                                              : NetworkImage(images[index])
                                                  as ImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    );
                  }),
                  if (!showDetailsPanelAside) ...[
                    const Divider(
                        height: 40, thickness: 1, indent: 16, endIndent: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: detailsContent,
                    ),
                  ]
                ],
              ),
            ),
          ),
          if (showDetailsPanelAside)
            Container(
              width: 350,
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  left: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: SingleChildScrollView(child: detailsContent),
            ),
        ],
      ),
    );
  }

  // Build UI for category-specific details
  Widget _buildCategorySpecificDetails(BuildContext context, Listing listing) {
    final fields = <Widget>[];
    final categoryId = listing.category;

    // Helper to add a detail item if the value is not null or empty
    void addDetailItem(String label, dynamic value) {
      // Changed value type to dynamic
      if (value != null && value.toString().isNotEmpty) {
        fields.add(_buildDetailItem(
            context, label, value.toString())); // Ensure value is string
        fields.add(const SizedBox(height: 8));
      }
    }

    switch (categoryId) {
      case 'for-sale':
        addDetailItem('Description', listing.categoryFields['description']);
        break;
      case 'jobs':
        addDetailItem('Pay', listing.categoryFields['pay']);
        addDetailItem(
            'Job Description', listing.categoryFields['job_description']);
        break;
      case 'vehicles':
        addDetailItem('Make', listing.categoryFields['make']);
        addDetailItem('Model', listing.categoryFields['model']);
        addDetailItem('Year', listing.categoryFields['year']);
        addDetailItem('Mileage', listing.categoryFields['mileage']);
        addDetailItem('Condition', listing.categoryFields['condition']);
        break;
      case 'housing':
        addDetailItem('Property Type', listing.categoryFields['property_type']);
        addDetailItem('Bedrooms', listing.categoryFields['bedrooms']);
        addDetailItem('Bathrooms', listing.categoryFields['bathrooms']);
        addDetailItem('Square Footage', listing.categoryFields['sq_ft']);
        addDetailItem('Rent/Price', listing.categoryFields['rent_price']);
        break;
      case 'electronics':
        addDetailItem('Type', listing.categoryFields['electronics_type']);
        addDetailItem('Brand', listing.categoryFields['electronics_brand']);
        addDetailItem(
            'Condition', listing.categoryFields['electronics_condition']);
        addDetailItem(
            'Warranty', listing.categoryFields['electronics_warranty']);
        break;
      case 'services':
        addDetailItem('Service Type', listing.categoryFields['service_type']);
        addDetailItem('Rate/Pricing', listing.categoryFields['service_rate']);
        addDetailItem('Experience/Portfolio',
            listing.categoryFields['service_experience']);
        addDetailItem(
            'Availability', listing.categoryFields['service_availability']);
        break;
      case 'community':
        addDetailItem('Event/Activity Type',
            listing.categoryFields['community_event_type']);
        addDetailItem('Date', listing.categoryFields['community_date']);
        addDetailItem('Time', listing.categoryFields['community_time']);
        addDetailItem('Venue', listing.categoryFields['community_venue']);
        addDetailItem(
            'Cost/Admission', listing.categoryFields['community_cost']);
        break;
      case 'furniture':
        addDetailItem(
            'Type of Furniture', listing.categoryFields['furniture_type']);
        addDetailItem('Material', listing.categoryFields['furniture_material']);
        addDetailItem(
            'Condition', listing.categoryFields['furniture_condition']);
        addDetailItem(
            'Dimensions', listing.categoryFields['furniture_dimensions']);
        addDetailItem('Age', listing.categoryFields['furniture_age']);
        break;
      case 'pets':
        addDetailItem(
            'Type of Animal', listing.categoryFields['pets_animal_type']);
        addDetailItem('Breed', listing.categoryFields['pets_breed']);
        addDetailItem('Age', listing.categoryFields['pets_age']);
        addDetailItem('Sex', listing.categoryFields['pets_sex']);
        addDetailItem(
            'Spayed/Neutered', listing.categoryFields['pets_spayed_neutered']);
        addDetailItem(
            'Vaccination Details', listing.categoryFields['pets_vaccination']);
        addDetailItem(
            'Adoption Fee/Price', listing.categoryFields['pets_fee_price']);
        addDetailItem('Reason for Rehoming',
            listing.categoryFields['pets_rehoming_reason']);
        break;
      default:
        listing.categoryFields.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            final label = key
                .split('_')
                .map((word) =>
                    word[0].toUpperCase() + word.substring(1).toLowerCase())
                .join(' ');
            addDetailItem(label, value.toString());
          }
        });
    }

    if (fields.isEmpty) {
      return const Text('No additional details available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: fields,
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Inquiry about your listing',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _launchDirections(String locationQuery) async {
    final Uri mapsUri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': locationQuery,
    });
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Could not open map for directions to "$locationQuery"'),
          ),
        );
      }
    }
  }

  Widget _buildMapView(String locationQuery) {
    if (kIsWeb && _googleMapsApiKey.isEmpty) {
      return const Center(
          child: Text(
              'Google Maps API Key not configured. Map cannot be displayed.'));
    }
    
    LatLng targetLocation = const LatLng(37.7749, -122.4194); // Default (e.g., San Francisco)

    final parts = locationQuery.split(',');
    if (parts.length == 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        targetLocation = LatLng(lat, lng);
      }
    } else {
      // Placeholder for actual geocoding if locationQuery is an address string
      print(
          "Geocoding needed for location: $locationQuery. Using default/parsed coordinates for now.");
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: targetLocation,
        zoom: 14.0,
      ),
      markers: {
        Marker(
          markerId: const MarkerId('listingLocation'),
          position: targetLocation,
          infoWindow: InfoWindow(title: locationQuery.split(',').first), // Show part of the location query
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        // _mapController = controller; // Commented out as it's unused for now
      },
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
        if (kIsWeb)
          Factory<EagerGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }
}
