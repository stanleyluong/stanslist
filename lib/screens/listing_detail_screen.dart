import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/category.dart';
import '../models/listing.dart';
import '../providers/listings_provider.dart';
import '../widgets/app_bar.dart';
import '../widgets/side_panel.dart';

class ListingDetailScreen extends StatefulWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();
  bool _isFetchingListing = false; // To prevent multiple fetches

  @override
  void initState() {
    super.initState();
    // Attempt to fetch the listing if not already available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ListingsProvider>(context, listen: false);
      final listing = provider.getListingById(widget.listingId);
      if (listing == null && !provider.isLoading && !_isFetchingListing) {
        setState(() {
          _isFetchingListing = true;
        });
        provider.refreshListings().then((_) {
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
    // Threshold for showing details in a separate right-hand column.
    // Adjusted to 1050px to give more space for image + details when side panel is present.
    final bool showDetailsPanelAside = screenWidth >= 1050;

    return Scaffold(
      appBar: const StansListAppBar(),
      body: Consumer<ListingsProvider>(
        builder: (context, provider, child) {
          // If listings are still loading from the initState call, show loading indicator
          if (_isFetchingListing ||
              (provider.isLoading && provider.listings.isEmpty)) {
            return const Center(child: CircularProgressIndicator());
          }

          final listing = provider.getListingById(widget.listingId);

          if (listing == null) {
            return const Center(
              child: Text('Listing not found'),
            );
          }

          final images = listing.images.isEmpty
              ? ['assets/images/placeholder-image.jpg']
              : listing.images;

          // Define the details content widget once
          Widget detailsContentColumn = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                listing.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Price
              Text(
                NumberFormat.currency(
                        symbol: '\$',
                        decimalDigits: 0) // Corrected: removed extra backslash
                    .format(listing.price),
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
                            Categories.getById(listing.category)?.icon ?? '📦',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              Categories.getById(listing.category)?.name ??
                                  listing.category,
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
                      listing.location,
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
                    "Posted ${DateFormat.yMMMd().format(listing.createdAt)}",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const Divider(height: 30),

              // Category-specific details (if available)
              if (listing.categoryFields.isNotEmpty) ...[
                Text(
                  'Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                _buildCategorySpecificDetails(context, listing),
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
                listing.description,
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
                  onPressed: () => _launchEmail(listing.contactEmail),
                  icon: const Icon(Icons.email),
                  label: Text('Email: ${listing.contactEmail}'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),

              // Phone button (if available)
              if (listing.contactPhone != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _launchPhone(listing.contactPhone!),
                    icon: const Icon(Icons.phone),
                    label: Text('Call: ${listing.contactPhone}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ],
          );

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showSidePanel)
                const SidePanel(), // Conditionally show SidePanel
              Expanded(
                child: SingleChildScrollView(
                  // Main content area (image + potentially details)
                  padding: const EdgeInsets.all(
                      16.0), // Padding for the content within this scroll view
                  child: Column(
                    children: [
                      // Image Display Section (using existing LayoutBuilder for margins)
                      LayoutBuilder(builder: (context, constraints) {
                        // Adjust isNarrow threshold if needed, based on constraints.maxWidth
                        final bool isNarrow = constraints.maxWidth <
                            400; // Reduced threshold slightly
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              // Main Image
                              constraints: const BoxConstraints(
                                maxHeight: 500,
                                // maxWidth: 700, // MaxWidth is less critical here as parent constrains it
                              ),
                              margin: EdgeInsets.symmetric(
                                vertical: 20,
                                // Horizontal margin is 0 if narrow (padding handles it), else a small margin
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image(
                                            image: images[index]
                                                    .startsWith('assets/')
                                                ? AssetImage(images[index])
                                                : NetworkImage(images[index])
                                                    as ImageProvider,
                                            fit: BoxFit.contain,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  size: 64,
                                                  color: Colors.grey,
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
                            if (images.length > 1) // Thumbnails
                              Container(
                                height: 80,
                                margin: EdgeInsets.symmetric(
                                  horizontal: isNarrow
                                      ? 0
                                      : 8, // Consistent with image margin
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
                                            duration: const Duration(
                                                milliseconds: 300),
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
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                    0.1), // Corrected withOpacity
                                                spreadRadius: 0,
                                                blurRadius: 3,
                                                offset: const Offset(0, 1),
                                              )
                                            ]),
                                        child: Opacity(
                                          opacity: _selectedImageIndex == index
                                              ? 1.0
                                              : 0.7, // Corrected opacity
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(6),
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
                        // If details are not in a separate column, show them here
                        const Divider(
                            height: 40,
                            thickness: 1,
                            indent: 16,
                            endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal:
                                  8.0), // Add some horizontal padding for stacked details
                          child: detailsContentColumn,
                        ),
                      ]
                    ],
                  ),
                ),
              ),
              if (showDetailsPanelAside) // Conditionally show the right-hand details panel
                Container(
                  width: 350,
                  height: MediaQuery.of(context)
                      .size
                      .height, // Make it fill the height
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor, // Added background color
                    border: Border(
                      left: BorderSide(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(child: detailsContentColumn),
                ),
            ],
          );
        },
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
        addDetailItem(
            'Year',
            listing.categoryFields[
                'year']); // Will be converted to String by addDetailItem
        addDetailItem(
            'Mileage',
            listing.categoryFields[
                'mileage']); // Will be converted to String by addDetailItem
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
        // For any other category or if categoryFields is generic
        listing.categoryFields.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            // Convert key from snake_case to Title Case for display
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

  // Helper to build a single detail item
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

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
