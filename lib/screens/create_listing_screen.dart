import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Added Riverpod
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:provider/provider.dart'; // Removed provider
import 'package:uuid/uuid.dart';

import '../models/category.dart' as models;
import '../models/listing.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../providers/listings_provider.dart';
import '../widgets/app_bar.dart'; // Corrected import for StansListAppBar
import '../widgets/listing_form_panel.dart'; // Import the new form panel

class CreateListingScreen extends ConsumerStatefulWidget {
  // Changed to ConsumerStatefulWidget
  final String? listingId; // Add optional listingId parameter

  const CreateListingScreen({super.key, this.listingId}); // Update constructor

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState(); // Changed to ConsumerState
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  // Changed to extend ConsumerState
  final _formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> _controllers = {
    'title': TextEditingController(),
    'description': TextEditingController(),
    'price': TextEditingController(),
    'location': TextEditingController(),
    'email': TextEditingController(),
    'phone': TextEditingController(),
  };

  String _selectedCategoryId = models.Categories.all.isNotEmpty
      ? models.Categories.all.first.id
      : 'classifieds';
  bool _isSubmitting = false;
  bool _isLoadingData = false; // Renamed for clarity
  Listing? _editingListing;

  List<XFile> _imageFiles = [];
  List<Uint8List?> _imageBytesList = [];

  @override
  void initState() {
    super.initState();
    if (widget.listingId != null) {
      _loadExistingListingData();
    }
    _controllers.forEach((key, controller) {
      controller.addListener(() {
        if (mounted) {
          // Add mounted check
          setState(() {
            // This will trigger a rebuild of the preview
          });
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // final authProvider = Provider.of<AuthProvider>(context, listen: false); // Removed provider
    final authState = ref.watch(authProvider); // Changed to ref.watch
    final currentUser =
        authState.user; // Adjusted to access user from AuthState
    if (widget.listingId == null && // Only auto-populate for new listings
        currentUser?.email != null &&
        _controllers['email']!.text.isEmpty) {
      _controllers['email']!.text = currentUser!.email!;
    }
  }

  Future<void> _loadExistingListingData() async {
    if (widget.listingId == null) return;
    if (mounted) {
      setState(() {
        _isLoadingData = true;
      });
    }

    try {
      // final listing = Provider.of<ListingsProvider>(context, listen: false) // Removed provider
      //     .getListingById(widget.listingId!); // Removed provider
      final listing = ref
          .read(listingsProvider)
          .getListingById(widget.listingId!); // Changed to ref.read
      if (listing != null) {
        _editingListing = listing;
        _controllers['title']!.text = listing.title;
        _controllers['description']!.text = listing.description;
        _controllers['price']!.text =
            listing.price.toStringAsFixed(2); // Ensure correct format
        _controllers['location']!.text = listing.location;
        _controllers['email']!.text = listing.contactEmail;
        _controllers['phone']!.text = listing.contactPhone ?? '';
        _selectedCategoryId = listing.category;

        // Initialize and populate category-specific field controllers
        // The ListingFormPanel is responsible for creating the UI for these fields.
        // This section ensures that if data exists for those fields, the controllers are populated.
        listing.categoryFields.forEach((fieldName, value) {
          final controllerKey =
              '${_selectedCategoryId.replaceAll('-', '_')}_$fieldName';
          // Ensure controller exists. ListingFormPanel should create them,
          // but we can initialize them here if they are accessed before ListingFormPanel builds.
          if (!_controllers.containsKey(controllerKey)) {
            _controllers[controllerKey] = TextEditingController();
            // Add listener for preview updates if these controllers are created on-the-fly
            _controllers[controllerKey]!.addListener(() {
              if (mounted) setState(() {});
            });
          }
          _controllers[controllerKey]!.text = value?.toString() ?? '';
        });

        // Image handling for editing:
        // For now, existing images are not pre-loaded into the picker.
        // The user must re-select images if they want to change them.
        // A more robust solution would display existing images and allow managing them.
        if (listing.images.isNotEmpty) {
          print(
              'Editing listing with ID: ${listing.id}. Existing images: ${listing.images}. User must re-select to change images.');
          // To display existing images in the preview (read-only initially):
          // You might want to fetch and convert image URLs to Uint8List if needed for a consistent preview,
          // or adjust the preview logic to handle URLs directly.
          // For simplicity, _imageBytesList and _imageFiles remain for NEW uploads.
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Listing not found for editing.'),
                backgroundColor: Colors.red),
          );
          context.go('/my-posts');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error loading listing data: $e'),
              backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _onFormDataChanged(String field, dynamic value) {
    setState(() {
      if (field == 'category') {
        _selectedCategoryId = value as String;
        // No need to update 'category_display' controller anymore
      }
      // This will trigger a rebuild of the preview for category-specific fields
      else if (field.startsWith('categoryFields.')) {
        // No need to handle individual fields here as the widget rebuild will show updated values
      }
    });
  }

  // Updated for multiple images
  void _onImagesChanged(
      List<XFile> imageFiles, List<Uint8List?> imageBytesList) {
    setState(() {
      _imageFiles = imageFiles;
      _imageBytesList = imageBytesList;
    });
  }

  // Updated to upload multiple images and return a list of URLs
  Future<List<String>> _uploadImages(List<XFile> imageFiles) async {
    List<String> downloadUrls = [];
    if (imageFiles.isEmpty) return downloadUrls;

    for (XFile imageFile in imageFiles) {
      try {
        final storageRef = FirebaseStorage.instance.ref();
        final String fileName =
            'listings/${const Uuid().v4()}-${imageFile.name}';
        final Reference fileRef = storageRef.child(fileName);
        final bytes = await imageFile.readAsBytes();
        final metadata = SettableMetadata(
          contentType:
              imageFile.mimeType ?? 'image/jpeg', // Use mimeType if available
          customMetadata: {
            'uploaded_by': 'web_app',
            'upload_timestamp': DateTime.now().toIso8601String(),
          },
        );
        final UploadTask uploadTask = fileRef.putData(bytes, metadata);
        final TaskSnapshot snapshot = await uploadTask;
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to upload image ${imageFile.name}: ${e.toString()}. It will be skipped.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        // Optionally add a placeholder or skip this image
        // For now, we just skip it and it won't be in downloadUrls
      }
    }
    return downloadUrls;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (_selectedCategoryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Image check: If editing and no new images are selected, we might want to keep existing ones.
    // If creating, images are required.
    if (_editingListing == null && _imageFiles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image for your listing.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (mounted) setState(() => _isSubmitting = true);

    List<String> imageUrls =
        _editingListing?.images ?? []; // Start with existing images if editing

    // If new images were selected, upload them and replace/add to imageUrls
    if (_imageFiles.isNotEmpty) {
      imageUrls = await _uploadImages(
          _imageFiles); // This will overwrite if new images are picked
      if (imageUrls.isEmpty) {
        // Check if new uploads failed
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Image upload failed for all selected images. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isSubmitting = false);
        }
        return;
      }
    } else if (_editingListing != null && _imageFiles.isEmpty) {
      // No new images selected during edit, keep existing ones
      imageUrls = _editingListing!.images;
    }

    if (imageUrls.isEmpty && _editingListing == null) {
      // Final check: if creating, must have images
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Image upload failed or no images selected. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
      }
      return;
    }

    // final authProvider = Provider.of<AuthProvider>(context, listen: false); // Removed provider
    // final currentUser = authProvider.currentUser; // Removed provider
    final authState = ref.read(authProvider); // Changed to ref.read
    final currentUser =
        authState.user; // Adjusted to access user from AuthState

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to post a listing.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    // Collect category-specific fields
    Map<String, dynamic> categoryFields = {};
    final keyPrefix = _selectedCategoryId.replaceAll('-', '_');

    // Iterate over controllers that match the current category prefix
    _controllers.forEach((key, controller) {
      if (key.startsWith(keyPrefix + "_")) {
        final firestoreFieldName = key.substring(keyPrefix.length + 1);
        if (controller.text.isNotEmpty) {
          // For the 'year' field in 'vehicles' category, always store as String.
          if (_selectedCategoryId == 'vehicles' &&
              firestoreFieldName == 'year') {
            categoryFields[firestoreFieldName] = controller.text;
          } else {
            num? numValue = num.tryParse(controller.text);
            if (numValue != null) {
              categoryFields[firestoreFieldName] = numValue;
            } else {
              categoryFields[firestoreFieldName] = controller.text;
            }
          }
        } else {
          categoryFields[firestoreFieldName] = controller.text;
        }
      }
    });

    final listingToSubmit = Listing(
      id: _editingListing?.id, // Use existing ID if editing
      title: _controllers['title']!.text,
      description: _controllers['description']!.text,
      price: double.tryParse(_controllers['price']!.text) ?? 0.0,
      category: _selectedCategoryId,
      images: imageUrls,
      location: _controllers['location']!.text,
      contactEmail: _controllers['email']!.text,
      contactPhone: _controllers['phone']!.text.isNotEmpty
          ? _controllers['phone']!.text
          : null,
      userId: currentUser.uid,
      datePosted: _editingListing?.datePosted ??
          DateTime.now(), // Preserve original post date if editing
      createdAt: _editingListing?.createdAt ??
          DateTime.now(), // Preserve original creation time if editing
      categoryFields: categoryFields,
      // isActive will default to true in the model if not specified
    );

    try {
      // final listingsProvider = // Removed provider
      //     Provider.of<ListingsProvider>(context, listen: false); // Removed provider
      final listingsNotifier = ref
          .read(listingsProvider.notifier); // Changed to ref.read for notifier
      if (_editingListing != null) {
        // If _editingListing is not null, then listingToSubmit.id is also not null.
        await listingsNotifier.updateListing(
            // Changed to use notifier
            listingToSubmit.id,
            listingToSubmit); // Removed redundant '!'
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/my-posts');
        }
      } else {
        await listingsNotifier
            .addListing(listingToSubmit); // Changed to use notifier
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Listing posted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          context.go('/');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post listing: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Build the category-specific fields preview
  Widget _buildCategorySpecificPreview(BuildContext context) {
    Map<String, dynamic> fieldsToPreview = {};
    final keyPrefix = _selectedCategoryId.replaceAll('-', '_');
    final currentCategoryModel = models.Categories.getById(_selectedCategoryId);

    if (currentCategoryModel == null) return const SizedBox.shrink();

    // Define which fields to show for each category for a cleaner preview
    // This map defines the controller key suffix and the display label.
    Map<String, String> previewFieldDefinitions = {};

    // This is a simplified example. You'll need to expand this based on
    // the fields defined in `_initCategoryControllers` in `listing_form_panel.dart`
    // and decide which ones make sense for a preview.
    switch (_selectedCategoryId) {
      case 'vehicles':
        previewFieldDefinitions = {
          'make': 'Make',
          'model': 'Model',
          'year': 'Year',
          'mileage': 'Mileage',
          'condition': 'Condition',
        };
        break;
      case 'property-rentals':
        previewFieldDefinitions = {
          'property_type': 'Property Type',
          'bedrooms': 'Bedrooms',
          'bathrooms': 'Bathrooms',
          'sqft': 'Sq. Ft.',
        };
        break;
      case 'apparel':
        previewFieldDefinitions = {
          'type': 'Type',
          'size': 'Size',
          'brand': 'Brand',
          'condition': 'Condition',
          'color': 'Color',
        };
        break;
      case 'electronics':
        previewFieldDefinitions = {
          'type': 'Type',
          'brand': 'Brand',
          'model': 'Model',
          'condition': 'Condition',
        };
        break;
      case 'home-sales':
        previewFieldDefinitions = {
          'property_type': 'Property Type',
          'bedrooms': 'Bedrooms',
          'bathrooms': 'Bathrooms',
          'sqft': 'Sq. Ft.',
          'year_built': 'Year Built',
        };
        break;
      // Add cases for all other categories with their relevant preview fields
      // For categories like 'classifieds' or 'free-stuff', the main description might be enough,
      // or you might preview their specific 'description' field if it's different from the main one.
      case 'classifieds':
      case 'free-stuff':
        previewFieldDefinitions = {
          'description':
              'Details', // Assuming 'description' is the key for their specific field
        };
        break;
      // ... add all other categories and their desired preview fields
      default:
        // For categories not explicitly defined, try to show all their specific fields
        // This is a fallback and might not always be ideal.
        _controllers.forEach((key, controller) {
          if (key.startsWith(keyPrefix + "_") && controller.text.isNotEmpty) {
            final fieldName =
                key.substring(keyPrefix.length + 1).replaceAll('_', ' ');
            final displayFieldName =
                fieldName[0].toUpperCase() + fieldName.substring(1);
            fieldsToPreview[displayFieldName] = controller.text;
          }
        });
        break;
    }

    if (previewFieldDefinitions.isNotEmpty) {
      previewFieldDefinitions.forEach((controllerKeySuffix, displayLabel) {
        final controllerKey = '${keyPrefix}_$controllerKeySuffix';
        if (_controllers.containsKey(controllerKey) &&
            _controllers[controllerKey]!.text.isNotEmpty) {
          fieldsToPreview[displayLabel] = _controllers[controllerKey]!.text;
        }
      });
    }

    if (fieldsToPreview.isEmpty) {
      // If no specific fields have text, check the main description if it's a simple category
      if ((_selectedCategoryId == 'classifieds' ||
              _selectedCategoryId == 'free-stuff') &&
          _controllers['description']!.text.isNotEmpty) {
        // Use the general description if category-specific one is empty or not applicable
      } else if (_controllers['description']!.text.isNotEmpty &&
          !_selectedCategoryId.startsWith('classifieds') &&
          !_selectedCategoryId.startsWith('free-stuff')) {
        // For other categories, if no specific fields, don't show "Details" section unless main description has content
        // This avoids showing an empty "Details" section.
      } else {
        return const SizedBox.shrink(); // No specific details to show
      }
    }

    // If fieldsToPreview is still empty but main description has content, show that.
    // This logic is a bit complex due to the interaction of main vs specific descriptions.
    // The goal is to show *something* relevant.

    bool showMainDescriptionAsDetail = fieldsToPreview.isEmpty &&
        _controllers['description']!.text.isNotEmpty &&
        (_selectedCategoryId == 'classifieds' ||
            _selectedCategoryId == 'free-stuff');

    if (fieldsToPreview.isEmpty && !showMainDescriptionAsDetail) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fieldsToPreview.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child:
                Text('Details', style: Theme.of(context).textTheme.titleMedium),
          ),
          ...fieldsToPreview.entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text('${entry.key}: ${entry.value}'),
            );
          }),
        ] else if (showMainDescriptionAsDetail) ...[
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
            child:
                Text('Details', style: Theme.of(context).textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(_controllers['description']!.text),
          )
        ]
      ],
    );
  }

  // Build the main preview card
  Widget _buildPreview(BuildContext context) {
    final selectedCategory = models.Categories.getById(_selectedCategoryId);

    // Use existing image URLs for preview if editing and no new images are selected yet
    List<String> previewImageUrls = _editingListing?.images ?? [];
    bool hasNewWebImages = _imageBytesList.isNotEmpty && kIsWeb;
    bool hasNewNonWebImages = _imageFiles.isNotEmpty && !kIsWeb;

    Widget imagePreviewWidget;

    if (hasNewWebImages) {
      imagePreviewWidget = PageView.builder(
        itemCount: _imageBytesList.length,
        itemBuilder: (context, index) {
          final bytes = _imageBytesList[index];
          return bytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(bytes, fit: BoxFit.contain))
              : Center(
                  child: Icon(Icons.broken_image,
                      size: 50, color: Colors.grey[400]));
        },
      );
    } else if (hasNewNonWebImages) {
      imagePreviewWidget = PageView.builder(
        itemCount: _imageFiles.length,
        itemBuilder: (context, index) {
          final file = _imageFiles[index];
          return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(File(file.path), fit: BoxFit.contain));
        },
      );
    } else if (previewImageUrls.isNotEmpty) {
      imagePreviewWidget = PageView.builder(
        itemCount: previewImageUrls.length,
        itemBuilder: (context, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(previewImageUrls[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(Icons.broken_image,
                        size: 50, color: Colors.grey[400]))),
          );
        },
      );
    } else {
      imagePreviewWidget = Center(
          child: Icon(Icons.camera_alt_outlined,
              size: 50, color: Colors.grey[400]));
    }

    // Get raw price string for parsing
    final String rawPriceString = _controllers['price']!.text;
    String displayPriceText;
    if (rawPriceString.isNotEmpty) {
      final double? parsedPrice = double.tryParse(rawPriceString);
      if (parsedPrice != null) {
        displayPriceText = '\$${parsedPrice.toStringAsFixed(2)}';
      } else {
        displayPriceText = 'Invalid price'; // Or handle as an error
      }
    } else {
      displayPriceText = 'Price not set';
    }

    // Determine which description to show in the main preview area
    String mainPreviewDescription =
        _controllers['description']!.text; // General description

    // For categories like 'classifieds' or 'free-stuff', their specific description
    // might be more relevant as the primary description if the general one is empty.
    if (mainPreviewDescription.isEmpty) {
      final keyPrefix = _selectedCategoryId.replaceAll('-', '_');
      final categorySpecificDescriptionKey = '${keyPrefix}_description';
      if (_controllers.containsKey(categorySpecificDescriptionKey) &&
          _controllers[categorySpecificDescriptionKey]!.text.isNotEmpty) {
        mainPreviewDescription =
            _controllers[categorySpecificDescriptionKey]!.text;
      }
    }

    return Card(
      elevation: 0,
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withAlpha((255 * 0.3).round()),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
            color: Theme.of(context)
                .colorScheme
                .outline
                .withAlpha((255 * 0.5).round())),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: imagePreviewWidget, // Use the dynamic image preview widget
            ),
            const SizedBox(height: 16),
            Text(
              _controllers['title']!.text.isNotEmpty
                  ? _controllers['title']!.text
                  : 'Listing Title Preview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // Price
            if (rawPriceString.isNotEmpty) // Show only if there is a price
              Text(
                displayPriceText, // Use the processed displayPriceText
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            const SizedBox(height: 8),
            if (selectedCategory != null)
              Chip(
                avatar: Text(selectedCategory.icon,
                    style: const TextStyle(fontSize: 16)),
                label: Text(selectedCategory.name),
                backgroundColor: Colors.grey[200],
              ),
            const SizedBox(height: 8),
            if (_controllers['location']!.text.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.location_on_outlined,
                      size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _controllers['location']!.text,
                      style: TextStyle(color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            // Category-specific details
            if (_selectedCategoryId.isNotEmpty) ...[
              Text(
                // Add "Details" title here, ensuring it's only once
                'Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              _buildCategorySpecificPreview(
                  context), // This now only returns the Wrap of fields
            ],

            const SizedBox(height: 16),
            Text(
              mainPreviewDescription, // Use the potentially placeholder description
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              'Contact: ${_controllers['email']!.text.isNotEmpty ? _controllers['email']!.text : "N/A"} ${_controllers['phone']!.text.isNotEmpty ? "| P: " + _controllers['phone']!.text : ""}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the screen is wide enough for side-by-side layout
    final bool isWideScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: StansListAppBar(
          // Title can be customized here if StansListAppBar is modified to accept it
          // For now, keeping it as is.
          // titleText: widget.listingId != null ? 'Edit Listing' : 'Create Listing',
          ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Form Panel (Left Side)
                SizedBox(
                  width: isWideScreen
                      ? 380
                      : MediaQuery.of(context)
                          .size
                          .width, // Full width on small screens
                  child: Form(
                    // Wrap ListingFormPanel with a Form widget
                    key: _formKey, // Assign the _formKey
                    child: ListingFormPanel(
                      key: ValueKey(
                          _selectedCategoryId), // Ensure panel rebuilds on category change for controller init
                      onFormDataChanged: _onFormDataChanged,
                      onImagesChanged: _onImagesChanged, // Pass the callback
                      onSubmit: _submitForm,
                      controllers: _controllers,
                      initialSelectedCategory: _selectedCategoryId,
                      initialImageFiles: _imageFiles, // Pass initial files
                      initialImageBytesList:
                          _imageBytesList, // Pass initial bytes
                      isSubmitting: _isSubmitting,
                      // Pass the form key to ListingFormPanel if it needs to use it
                      // formKey: _formKey, // This would require ListingFormPanel to accept it
                    ), // Closes ListingFormPanel
                  ), // Closes Form
                ), // Closes SizedBox
                // Preview Panel (Right Side - only on wide screens)
                if (isWideScreen)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Live Preview',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _buildPreview(context),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
