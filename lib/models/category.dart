class Category {
  final String id;
  final String name;
  final String description;
  final String icon;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class Categories {
  static const List<Category> all = [
    Category(
      id: 'vehicles',
      name: 'Vehicles',
      description: 'Cars, trucks, motorcycles, and more',
      icon: '🚗',
    ),
    Category(
      id: 'property-rentals',
      name: 'Property Rentals',
      description: 'Apartments, houses, and rooms for rent',
      icon: '🏘️',
    ),
    Category(
      id: 'apparel',
      name: 'Apparel',
      description: 'Clothing, shoes, and accessories',
      icon: '👕',
    ),
    Category(
      id: 'classifieds',
      name: 'Classifieds',
      description: 'Miscellaneous items and general ads',
      icon: '📰',
    ),
    Category(
      id: 'electronics',
      name: 'Electronics',
      description: 'Computers, phones, TVs, and gadgets',
      icon: '📱',
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      description: 'Movies, music, books, and tickets',
      icon: '🎬',
    ),
    Category(
      id: 'family',
      name: 'Family',
      description: 'Items for babies, kids, and family needs',
      icon: '👨‍👩‍👧‍👦',
    ),
    Category(
      id: 'free-stuff',
      name: 'Free Stuff',
      description: 'Items offered for free',
      icon: '🆓',
    ),
    Category(
      id: 'garden-outdoor',
      name: 'Garden & Outdoor',
      description: 'Plants, tools, and outdoor furniture',
      icon: '🌳',
    ),
    Category(
      id: 'hobbies',
      name: 'Hobbies',
      description: 'Items for various hobbies and crafts',
      icon: '🎨',
    ),
    Category(
      id: 'home-goods',
      name: 'Home Goods',
      description: 'Furniture, decor, and household items',
      icon: '🛋️',
    ),
    Category(
      id: 'home-improvement',
      name: 'Home Improvement Supplies',
      description: 'Tools, materials, and supplies for home projects',
      icon: '🛠️',
    ),
    Category(
      id: 'home-sales',
      name: 'Home Sales',
      description: 'Houses and properties for sale',
      icon: '🏡',
    ),
    Category(
      id: 'musical-instruments',
      name: 'Musical Instruments',
      description: 'Guitars, keyboards, drums, and more',
      icon: '🎸',
    ),
    Category(
      id: 'office-supplies',
      name: 'Office Supplies',
      description: 'Supplies for home or business offices',
      icon: '📎',
    ),
    Category(
      id: 'pet-supplies',
      name: 'Pet Supplies',
      description: 'Food, toys, and accessories for pets',
      icon: '🦴',
    ),
    Category(
      id: 'sporting-goods',
      name: 'Sporting Goods',
      description: 'Equipment for various sports and activities',
      icon: '⚽',
    ),
    Category(
      id: 'toys-games',
      name: 'Toys & Games',
      description: 'Toys, board games, and video games',
      icon: '🎮',
    ),
  ];

  static Category? getById(String id) {
    try {
      return all.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }
}
