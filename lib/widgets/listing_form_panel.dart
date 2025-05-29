import 'dart:io'; // Added import

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/category.dart' as models;

// Define a callback type for when form data changes
typedef FormDataCallback = void Function(String field, dynamic value);
typedef ImageFilesCallback = void Function(
    // Renamed and updated for multiple files
    List<XFile> imageFiles,
    List<Uint8List?> imageBytesList);
typedef SubmitCallback = Future<void> Function();

class ListingFormPanel extends StatefulWidget {
  final FormDataCallback onFormDataChanged;
  final ImageFilesCallback onImagesChanged; // Renamed
  final SubmitCallback onSubmit;
  final Map<String, TextEditingController> controllers;
  final String initialSelectedCategory;
  final List<XFile> initialImageFiles; // Updated
  final List<Uint8List?> initialImageBytesList; // Updated
  final bool isSubmitting;

  const ListingFormPanel({
    super.key,
    required this.onFormDataChanged,
    required this.onImagesChanged, // Renamed
    required this.onSubmit,
    required this.controllers,
    required this.initialSelectedCategory,
    this.initialImageFiles = const [], // Updated
    this.initialImageBytesList = const [], // Updated
    required this.isSubmitting,
  });

  @override
  State<ListingFormPanel> createState() => _ListingFormPanelState();
}

class _ListingFormPanelState extends State<ListingFormPanel> {
  late String _selectedCategory;
  List<XFile> _imageFiles = []; // Updated
  List<Uint8List?> _imageBytesList = []; // Updated
  final ImagePicker _picker = ImagePicker();

  // Helper to get a category ID for controller keys (e.g., 'property-rentals' -> 'property_rentals')
  String _getControllerKeyPrefix(String categoryId) {
    return categoryId.replaceAll('-', '_');
  }

  @override
  void initState() {
    super.initState();
    // Ensure _selectedCategory is a valid one from the new list
    final initialCategory =
        models.Categories.getById(widget.initialSelectedCategory);
    if (initialCategory != null &&
        models.Categories.all.any((cat) => cat.id == initialCategory.id)) {
      _selectedCategory = initialCategory.id;
    } else if (models.Categories.all.isNotEmpty) {
      // Default to 'classifieds' if it exists, otherwise the first category
      var defaultCategory = models.Categories.all.firstWhere(
          (cat) => cat.id == 'classifieds',
          orElse: () => models.Categories.all.first);
      _selectedCategory = defaultCategory.id;
    } else {
      // Fallback if categories list is empty (should not happen)
      _selectedCategory = 'classifieds';
    }

    _imageFiles = List.from(widget.initialImageFiles); // Updated
    _imageBytesList = List.from(widget.initialImageBytesList); // Updated

    // Add listeners to controllers to call onFormDataChanged
    widget.controllers.forEach((key, controller) {
      // Remove listener for 'category_display' if it exists, as it's no longer used
      if (key != 'category_display') {
        controller.addListener(() {
          widget.onFormDataChanged(key, controller.text);
        });
      }
    });
    // Remove 'category_display' controller if it exists
    widget.controllers.remove('category_display');
  }

  Future<void> _pickImages() async {
    // Renamed to _pickImages
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        // Changed to pickMultiImage
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFiles.isNotEmpty) {
        List<Uint8List?> bytesList = [];
        if (kIsWeb) {
          for (var file in pickedFiles) {
            bytesList.add(await file.readAsBytes());
          }
        }
        setState(() {
          _imageFiles.addAll(pickedFiles); // Add to existing list
          _imageBytesList.addAll(bytesList); // Add to existing list
        });
        widget.onImagesChanged(
            _imageFiles, _imageBytesList); // Pass the updated lists
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imageFiles.removeAt(index);
      if (kIsWeb && index < _imageBytesList.length) {
        _imageBytesList.removeAt(index);
      }
    });
    widget.onImagesChanged(_imageFiles, _imageBytesList);
  }

  // Build category-specific form fields based on the selected category
  List<Widget> _buildCategorySpecificFields(String categoryId) {
    _initCategoryControllers(categoryId); // Ensure controllers are ready

    switch (categoryId) {
      case 'vehicles':
        return _buildVehiclesFields();
      case 'property-rentals':
        return _buildPropertyRentalsFields();
      case 'apparel':
        return _buildApparelFields();
      case 'classifieds':
        return _buildClassifiedsFields();
      case 'electronics':
        return _buildElectronicsFields();
      case 'entertainment':
        return _buildEntertainmentFields();
      case 'family':
        return _buildFamilyFields();
      case 'free-stuff':
        return _buildFreeStuffFields();
      case 'garden-outdoor':
        return _buildGardenOutdoorFields();
      case 'hobbies':
        return _buildHobbiesFields();
      case 'home-goods':
        return _buildHomeGoodsFields();
      case 'home-improvement':
        return _buildHomeImprovementFields();
      case 'home-sales':
        return _buildHomeSalesFields();
      case 'musical-instruments':
        return _buildMusicalInstrumentsFields();
      case 'office-supplies':
        return _buildOfficeSuppliesFields();
      case 'pet-supplies':
        return _buildPetSuppliesFields();
      case 'sporting-goods':
        return _buildSportingGoodsFields();
      case 'toys-games':
        return _buildToysGamesFields();
      default:
        return [];
    }
  }

  // Initialize controllers for category-specific fields
  void _initCategoryControllers(String categoryId) {
    final keyPrefix = _getControllerKeyPrefix(categoryId);

    // Helper to add a controller and its listener
    void addController(String fieldKeyName, String firestoreFieldName,
        {String defaultValue = ''}) {
      final controllerKey = '${keyPrefix}_$fieldKeyName';
      if (!widget.controllers.containsKey(controllerKey)) {
        widget.controllers[controllerKey] =
            TextEditingController(text: defaultValue);
        widget.controllers[controllerKey]!.addListener(() {
          widget.onFormDataChanged('categoryFields.$firestoreFieldName',
              widget.controllers[controllerKey]!.text);
        });
      }
    }

    // Clear controllers for other categories to avoid state issues (optional, but good practice)
    // This is a simple way; a more robust way would be to dispose and remove them.
    // For now, we rely on the fact that only relevant controllers are accessed.

    switch (categoryId) {
      case 'vehicles':
        addController('make', 'make');
        addController('model', 'model');
        addController('year', 'year');
        addController('mileage', 'mileage');
        addController('condition', 'condition', defaultValue: 'Used - Good');
        addController('vin', 'vin');
        addController('transmission', 'transmission',
            defaultValue: 'Automatic');
        addController('fuel_type', 'fuelType', defaultValue: 'Gasoline');
        break;
      case 'property-rentals':
        addController('property_type', 'propertyType',
            defaultValue: 'Apartment');
        addController('bedrooms', 'bedrooms');
        addController('bathrooms', 'bathrooms');
        addController('sqft', 'sqft');
        addController('pet_policy', 'petPolicy',
            defaultValue: 'Pets Negotiable');
        addController('lease_term', 'leaseTerm');
        addController('availability_date', 'availabilityDate');
        break;
      case 'apparel':
        addController('type', 'type');
        addController('size', 'size');
        addController('brand', 'brand');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('color', 'color');
        addController('material', 'material');
        break;
      case 'classifieds':
        addController('description', 'description');
        break;
      case 'electronics':
        addController('type', 'type');
        addController('brand', 'brand');
        addController('model', 'model');
        addController('condition', 'condition', defaultValue: 'Good');
        break;
      case 'entertainment':
        addController('type', 'type', defaultValue: 'Movie');
        addController('title', 'title');
        addController('format', 'format');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('genre', 'genre');
        break;
      case 'family':
        addController('item_type', 'itemType');
        addController('age_group', 'ageGroup');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('brand', 'brand');
        break;
      case 'free-stuff':
        addController('description', 'description');
        break;
      case 'garden-outdoor':
        addController('item_type', 'itemType');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('dimensions', 'dimensions');
        addController('material', 'material');
        break;
      case 'hobbies':
        addController('item_type', 'itemType');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('brand', 'brand');
        break;
      case 'home-goods':
        addController('type', 'type');
        addController('material', 'material');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('dimensions', 'dimensions');
        addController('color', 'color');
        break;
      case 'home-improvement':
        addController('item_type', 'itemType');
        addController('condition', 'condition', defaultValue: 'New');
        addController('quantity', 'quantity');
        addController('brand', 'brand');
        break;
      case 'home-sales':
        addController('property_type', 'propertyType', defaultValue: 'House');
        addController('bedrooms', 'bedrooms');
        addController('bathrooms', 'bathrooms');
        addController('sqft', 'sqft');
        addController('lot_size', 'lotSize');
        addController('year_built', 'yearBuilt');
        addController('hoa_fees', 'hoaFees');
        break;
      case 'musical-instruments':
        addController('instrument_type', 'instrumentType');
        addController('brand', 'brand');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('model', 'model');
        break;
      case 'office-supplies':
        addController('item_type', 'itemType');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('quantity', 'quantity');
        addController('brand', 'brand');
        break;
      case 'pet-supplies':
        addController('pet_type', 'petType', defaultValue: 'Dog');
        addController('item_type', 'itemType');
        addController('brand', 'brand');
        addController('condition', 'condition', defaultValue: 'New');
        addController('size', 'size');
        break;
      case 'sporting-goods':
        addController('item_type', 'itemType');
        addController('brand', 'brand');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('size', 'size');
        addController('sport_type', 'sportType');
        break;
      case 'toys-games':
        addController('type', 'type');
        addController('age_range', 'ageRange');
        addController('condition', 'condition', defaultValue: 'Good');
        addController('brand', 'brand');
        break;
    }
  }

  // Helper for creating TextFormField
  Widget _buildTextField(
      String controllerKeyName, String firestoreFieldName, String label,
      {bool isRequired = false,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1,
      String? hintText}) {
    final keyPrefix = _getControllerKeyPrefix(_selectedCategory);
    final fullControllerKey = '${keyPrefix}_$controllerKeyName';
    return TextFormField(
      controller: widget.controllers[fullControllerKey],
      decoration: InputDecoration(
          labelText: '$label${isRequired ? " *" : ""}', hintText: hintText),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'Please enter $label';
        }
        if (keyboardType == TextInputType.number &&
            value != null &&
            value.isNotEmpty &&
            double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  // Helper for creating DropdownButtonFormField
  Widget _buildDropdownField(String controllerKeyName,
      String firestoreFieldName, String label, List<String> items,
      {bool isRequired = false}) {
    final keyPrefix = _getControllerKeyPrefix(_selectedCategory);
    final fullControllerKey = '${keyPrefix}_$controllerKeyName';

    // Ensure the controller's text is a valid item, or use the first item as default if controller is empty/invalid
    String? currentValue = widget.controllers[fullControllerKey]?.text;
    if (currentValue == null || currentValue.isEmpty || !items.contains(currentValue)) {
      // Update controller if it was empty or invalid, so UI and data are in sync
      if (widget.controllers[fullControllerKey] != null) {
        widget.controllers[fullControllerKey]!.text = currentValue ?? '';
      }
    }

    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(labelText: '$label${isRequired ? " *" : ""}'),
      items: items.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          widget.controllers[fullControllerKey]?.text = newValue;
          // Listener attached in _initCategoryControllers will call widget.onFormDataChanged
        }
      },
      validator: (value) => (isRequired && (value == null || value.isEmpty))
          ? 'Please select $label'
          : null,
    );
  }

  List<Widget> _buildVehiclesFields() {
    return [
      _buildTextField('make', 'make', 'Make', isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('model', 'model', 'Model', isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('year', 'year', 'Year',
          isRequired: true, keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildTextField('mileage', 'mileage', 'Mileage',
          keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Used - Like New', 'Used - Good', 'Used - Fair', 'For Parts'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('vin', 'vin', 'VIN (Optional)'),
      const SizedBox(height: 16),
      _buildDropdownField('transmission', 'transmission', 'Transmission',
          ['Automatic', 'Manual', 'Other'],
          isRequired: false),
      const SizedBox(height: 16),
      _buildDropdownField('fuel_type', 'fuelType', 'Fuel Type',
          ['Gasoline', 'Diesel', 'Electric', 'Hybrid', 'Other'],
          isRequired: false),
    ];
  }

  List<Widget> _buildPropertyRentalsFields() {
    return [
      _buildDropdownField('property_type', 'propertyType', 'Property Type',
          ['Apartment', 'House', 'Condo', 'Townhouse', 'Room', 'Other'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('bedrooms', 'bedrooms', 'Bedrooms',
          isRequired: true, keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildTextField('bathrooms', 'bathrooms', 'Bathrooms',
          isRequired: true,
          keyboardType: TextInputType.numberWithOptions(decimal: true)),
      const SizedBox(height: 16),
      _buildTextField('sqft', 'sqft', 'Square Feet',
          keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildDropdownField('pet_policy', 'petPolicy', 'Pet Policy',
          ['Dogs Allowed', 'Cats Allowed', 'No Pets', 'Pets Negotiable'],
          isRequired: false),
      const SizedBox(height: 16),
      _buildTextField(
          'lease_term', 'leaseTerm', 'Lease Term (e.g., 12 months)'),
      const SizedBox(height: 16),
      _buildTextField(
          'availability_date', 'availabilityDate', 'Availability Date',
          hintText: 'YYYY-MM-DD'),
    ];
  }

  List<Widget> _buildApparelFields() {
    return [
      _buildTextField('type', 'type', 'Type (e.g., Shirt, Pants)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('size', 'size', 'Size', isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New with tags', 'New without tags', 'Like New', 'Good', 'Fair'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('color', 'color', 'Color'),
      const SizedBox(height: 16),
      _buildTextField('material', 'material', 'Material'),
    ];
  }

  List<Widget> _buildClassifiedsFields() {
    return [
      _buildTextField('description', 'description', 'Description',
          isRequired: true, maxLines: 3),
    ];
  }

  List<Widget> _buildElectronicsFields() {
    return [
      _buildTextField('type', 'type', 'Type (e.g., Phone, Laptop)',
          isRequired: false),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand', isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('model', 'model', 'Model', isRequired: true),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Poor', 'For Parts'],
          isRequired: true),
    ];
  }

  List<Widget> _buildEntertainmentFields() {
    return [
      _buildDropdownField('type', 'type', 'Type',
          ['Movie', 'Music', 'Book', 'Video Game', 'Tickets', 'Other'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('title', 'title', 'Title', isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('format', 'format', 'Format (e.g., Blu-ray, CD, PS5)'),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Acceptable']),
      const SizedBox(height: 16),
      _buildTextField('genre', 'genre', 'Genre'),
    ];
  }

  List<Widget> _buildFamilyFields() {
    return [
      _buildTextField(
          'item_type', 'itemType', 'Item Type (e.g., Stroller, Crib)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField(
          'age_group', 'ageGroup', 'Age Group (e.g., Newborn, Toddler)'),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
    ];
  }

  List<Widget> _buildFreeStuffFields() {
    return [
      _buildTextField('description', 'description', 'Description',
          isRequired: true, maxLines: 3),
    ];
  }

  List<Widget> _buildGardenOutdoorFields() {
    return [
      _buildTextField('item_type', 'itemType', 'Item Type (e.g., Plant, Tool)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Used'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('dimensions', 'dimensions', 'Dimensions'),
      const SizedBox(height: 16),
      _buildTextField('material', 'material', 'Material'),
    ];
  }

  List<Widget> _buildHobbiesFields() {
    return [
      _buildTextField(
          'item_type', 'itemType', 'Item Type (e.g., Craft Supplies)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Used']),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
    ];
  }

  List<Widget> _buildHomeGoodsFields() {
    return [
      _buildTextField('type', 'type', 'Type (e.g., Sofa, Table)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('material', 'material', 'Material'),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Used'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('dimensions', 'dimensions', 'Dimensions (e.g., HxWxD)'),
      const SizedBox(height: 16),
      _buildTextField('color', 'color', 'Color'),
    ];
  }

  List<Widget> _buildHomeImprovementFields() {
    return [
      _buildTextField(
          'item_type', 'itemType', 'Item Type (e.g., Tools, Lumber)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Used'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('quantity', 'quantity', 'Quantity'),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
    ];
  }

  List<Widget> _buildHomeSalesFields() {
    return [
      _buildDropdownField('property_type', 'propertyType', 'Property Type',
          ['House', 'Condo', 'Townhouse', 'Land', 'Other'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('bedrooms', 'bedrooms', 'Bedrooms',
          isRequired: true, keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildTextField('bathrooms', 'bathrooms', 'Bathrooms',
          isRequired: true,
          keyboardType: TextInputType.numberWithOptions(decimal: true)),
      const SizedBox(height: 16),
      _buildTextField('sqft', 'sqft', 'Square Feet',
          isRequired: true, keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildTextField('lot_size', 'lotSize', 'Lot Size (e.g., 0.5 acres)'),
      const SizedBox(height: 16),
      _buildTextField('year_built', 'yearBuilt', 'Year Built',
          keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      _buildTextField('hoa_fees', 'hoaFees',
          r'HOA Fees (e.g., $100/month)'), // Changed to raw string
    ];
  }

  List<Widget> _buildMusicalInstrumentsFields() {
    return [
      _buildTextField('instrument_type', 'instrumentType', 'Instrument Type',
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Used', 'For Parts'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('model', 'model', 'Model'),
    ];
  }

  List<Widget> _buildOfficeSuppliesFields() {
    return [
      _buildTextField('item_type', 'itemType', 'Item Type (e.g., Desk, Chair)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Used'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('quantity', 'quantity', 'Quantity'),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
    ];
  }

  List<Widget> _buildPetSuppliesFields() {
    return [
      _buildDropdownField('pet_type', 'petType', 'For Pet Type',
          ['Dog', 'Cat', 'Bird', 'Fish', 'Small Animal', 'Reptile', 'Other'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('item_type', 'itemType', 'Item Type (e.g., Food, Toy)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
      const SizedBox(height: 16),
      _buildDropdownField(
          'condition', 'condition', 'Condition', ['New', 'Used']),
      const SizedBox(height: 16),
      _buildTextField('size', 'size', 'Size (e.g., Small, for S dog)'),
    ];
  }

  List<Widget> _buildSportingGoodsFields() {
    return [
      _buildTextField(
          'item_type', 'itemType', 'Item Type (e.g., Bicycle, Skis)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Used'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('size', 'size', 'Size'),
      const SizedBox(height: 16),
      _buildTextField(
          'sport_type', 'sportType', 'Sport Type (e.g., Cycling, Skiing)'),
    ];
  }

  List<Widget> _buildToysGamesFields() {
    return [
      _buildTextField('type', 'type', 'Type (e.g., Board Game, Doll)',
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('age_range', 'ageRange', 'Age Range (e.g., 3-5 years)'),
      const SizedBox(height: 16),
      _buildDropdownField('condition', 'condition', 'Condition',
          ['New', 'Like New', 'Good', 'Fair', 'Used'],
          isRequired: true),
      const SizedBox(height: 16),
      _buildTextField('brand', 'brand', 'Brand'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360, // Adjust width as needed
      color: Theme.of(context).canvasColor, // Or a specific panel color
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Form(
          // Consider passing a GlobalKey<FormState> if validation needs to be triggered from parent
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create new listing',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Category Dropdown (Moved to top)
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: models.Categories.all.map((models.Category category) {
                  return DropdownMenuItem<String>(
                    value: category.id,
                    child: Row(
                      children: [
                        Text(category.icon,
                            style:
                                const TextStyle(fontSize: 18)), // Display icon
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                      // Re-initialize controllers for the new category
                      _initCategoryControllers(_selectedCategory);
                    });
                    widget.onFormDataChanged('category', newValue);
                  }
                },
                validator: (value) => value == null || value.isEmpty
                    ? 'Please select a category'
                    : null,
              ),
              const SizedBox(height: 16),

              // Category Specific Fields (Appears after Category)
              ..._buildCategorySpecificFields(_selectedCategory),
              if (_buildCategorySpecificFields(_selectedCategory).isNotEmpty)
                const SizedBox(height: 16),

              // Title
              TextFormField(
                controller: widget.controllers['title'],
                decoration: const InputDecoration(labelText: 'Title *'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),

              // Main Description (now optional, as category-specific might cover it)
              TextFormField(
                controller:
                    widget.controllers['description'], // General description
                decoration: const InputDecoration(
                    labelText: 'General Description (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: widget.controllers['price'],
                decoration:
                    const InputDecoration(labelText: 'Price', prefixText: '\$'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final price = double.tryParse(value);
                    if (price == null) {
                      return 'Please enter a valid price.';
                    }
                    if (price < 0) {
                      return 'Price cannot be negative.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: widget.controllers['location'],
                decoration: const InputDecoration(labelText: 'Location *'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Please enter a location'
                    : null,
              ),
              const SizedBox(height: 16),

              // Contact Email
              TextFormField(
                controller: widget.controllers['email'],
                decoration: const InputDecoration(labelText: 'Contact Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an email';
                  }
                  // Regex for basic email validation
                  if (!RegExp(
                          r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")
                      .hasMatch(value)) {
                    // Changed regex
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Contact Phone
              TextFormField(
                controller: widget.controllers['phone'],
                decoration: const InputDecoration(
                    labelText: 'Contact Phone (Optional)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),

              // Image Picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: const Text('Add Images'),
                  ),
                  const SizedBox(height: 10),
                  if (_imageFiles.isNotEmpty)
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _imageFiles.asMap().entries.map((entry) {
                        final index = entry.key;
                        final file = entry.value;
                        final bytes = (kIsWeb && index < _imageBytesList.length)
                            ? _imageBytesList[index]
                            : null;
                        return Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: kIsWeb && bytes != null
                                      ? Image.memory(bytes, fit: BoxFit.cover)
                                      : (kIsWeb
                                          ? Center(
                                              child: Text(file.name,
                                                  style: const TextStyle(
                                                      fontSize: 10),
                                                  textAlign: TextAlign.center,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2))
                                          : Image.file(File(file.path),
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Center(
                                                      child: Text(file.name,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 10),
                                                          textAlign:
                                                              TextAlign.center,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines:
                                                              2)))) // Changed Image.asset to Image.file(File())
                                  ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.redAccent),
                                onPressed: () => _removeImage(index),
                                tooltip: 'Remove Image',
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  if (_imageFiles.isNotEmpty) const SizedBox(height: 10),
                  Text(
                    _imageFiles.isEmpty
                        ? 'No images selected.'
                        : '${_imageFiles.length} image(s) selected.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.isSubmitting ? null : widget.onSubmit,
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: widget.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Post Listing'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
