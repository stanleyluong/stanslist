#!/usr/bin/env python3
"""
Realistic data seeding script for marketplace app.
Generates category-specific listings with proper Firebase Storage URLs.
Requires: pip install firebase-admin faker
"""

import firebase_admin
from firebase_admin import credentials, firestore
from faker import Faker
import random
import sys
import os
from datetime import datetime

fake = Faker()

# Firebase Storage base URL pattern
FIREBASE_STORAGE_BASE = "https://firebasestorage.googleapis.com/v0/b/stan-s-list.firebasestorage.app/o/"

# Sample images for each category (using realistic Firebase Storage URLs)
CATEGORY_IMAGES = {
    'vehicles': [
        f"{FIREBASE_STORAGE_BASE}vehicles%2Fcar1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}vehicles%2Fcar2.jpg?alt=media", 
        f"{FIREBASE_STORAGE_BASE}vehicles%2Ftruck1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}vehicles%2Fmotorcycle1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}vehicles%2Fsuv1.jpg?alt=media",
    ],
    'property-rentals': [
        f"{FIREBASE_STORAGE_BASE}property%2Fapartment1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}property%2Fhouse1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}property%2Fcondo1.jpg?alt=media", 
        f"{FIREBASE_STORAGE_BASE}property%2Fstudio1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}property%2Floft1.jpg?alt=media",
    ],
    'electronics': [
        f"{FIREBASE_STORAGE_BASE}electronics%2Flaptop1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}electronics%2Fphone1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}electronics%2Ftablet1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}electronics%2Fcamera1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}electronics%2Fheadphones1.jpg?alt=media",
    ],
    'apparel': [
        f"{FIREBASE_STORAGE_BASE}apparel%2Fjacket1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}apparel%2Fshoes1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}apparel%2Fdress1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}apparel%2Fjeans1.jpg?alt=media",
        f"{FIREBASE_STORAGE_BASE}apparel%2Fshirt1.jpg?alt=media",
    ]
}

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        service_account_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
        
        if not os.path.exists(service_account_path):
            print(f"❌ Service account key not found at: {service_account_path}")
            return None
            
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'stan-s-list.firebasestorage.app'
        })
        
        return firestore.client()
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        return None

def generate_vehicle_listing():
    """Generate realistic vehicle listing data"""
    car_makes = ['Toyota', 'Honda', 'Ford', 'Chevrolet', 'BMW', 'Mercedes', 'Audi', 'Nissan', 'Subaru', 'Volkswagen']
    car_models = {
        'Toyota': ['Camry', 'Corolla', 'RAV4', 'Prius', 'Highlander'],
        'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Fit'],
        'Ford': ['F-150', 'Mustang', 'Explorer', 'Focus', 'Escape'],
        'Chevrolet': ['Silverado', 'Malibu', 'Equinox', 'Tahoe', 'Camaro'],
        'BMW': ['3 Series', '5 Series', 'X3', 'X5', 'i3'],
        'Mercedes': ['C-Class', 'E-Class', 'GLE', 'A-Class', 'S-Class'],
        'Audi': ['A4', 'A6', 'Q5', 'Q7', 'A3'],
        'Nissan': ['Altima', 'Sentra', 'Rogue', 'Pathfinder', 'Leaf'],
        'Subaru': ['Outback', 'Forester', 'Impreza', 'Legacy', 'Crosstrek'],
        'Volkswagen': ['Jetta', 'Passat', 'Golf', 'Tiguan', 'Atlas']
    }
    
    make = random.choice(car_makes)
    model = random.choice(car_models[make])
    year = random.randint(2015, 2024)
    mileage = random.randint(5000, 150000)
    
    title = f"{year} {make} {model}"
    description = f"Well-maintained {year} {make} {model} with {mileage:,} miles. " + \
                 f"Great condition, regular maintenance, clean title. " + \
                 fake.text(max_nb_chars=200)
    
    return {
        'title': title,
        'description': description,
        'price': random.randint(8000, 45000),
        'make': make,
        'model': model,
        'year': year,
        'mileage': mileage,
        'condition': random.choice(['Excellent', 'Good', 'Fair']),
        'transmission': random.choice(['Automatic', 'Manual']),
        'fuelType': random.choice(['Gasoline', 'Hybrid', 'Electric', 'Diesel']),
        'images': [random.choice(CATEGORY_IMAGES['vehicles'])]
    }

def generate_property_listing():
    """Generate realistic property rental listing data"""
    property_types = ['Apartment', 'House', 'Condo', 'Studio', 'Townhouse', 'Loft']
    neighborhoods = ['Downtown', 'Midtown', 'Uptown', 'Riverside', 'Hillside', 'Oakwood', 'Maplewood', 'Sunset District']
    
    prop_type = random.choice(property_types)
    bedrooms = random.randint(0, 4) if prop_type != 'Studio' else 0
    bathrooms = random.choice([1, 1.5, 2, 2.5, 3])
    sqft = random.randint(400, 2500)
    neighborhood = random.choice(neighborhoods)
    
    title = f"{bedrooms}BR/{bathrooms}BA {prop_type} in {neighborhood}" if bedrooms > 0 else f"Studio {prop_type} in {neighborhood}"
    
    amenities = random.sample([
        'In-unit laundry', 'Parking included', 'Pet-friendly', 'Gym access', 
        'Pool', 'Balcony', 'Dishwasher', 'Air conditioning', 'Hardwood floors'
    ], random.randint(2, 5))
    
    description = f"Beautiful {prop_type.lower()} in {neighborhood}. {sqft} sq ft with " + \
                 f"modern amenities including: {', '.join(amenities)}. " + \
                 fake.text(max_nb_chars=150)
    
    return {
        'title': title,
        'description': description,
        'price': random.randint(1200, 4500),
        'propertyType': prop_type,
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'squareFootage': sqft,
        'furnished': random.choice([True, False]),
        'petFriendly': random.choice([True, False]),
        'parking': random.choice([True, False]),
        'images': [random.choice(CATEGORY_IMAGES['property-rentals'])]
    }

def generate_electronics_listing():
    """Generate realistic electronics listing data"""
    electronics = {
        'Laptop': {
            'brands': ['Apple', 'Dell', 'HP', 'Lenovo', 'ASUS', 'Acer'],
            'models': ['MacBook Pro', 'XPS 13', 'Pavilion', 'ThinkPad', 'ZenBook', 'Aspire']
        },
        'Smartphone': {
            'brands': ['Apple', 'Samsung', 'Google', 'OnePlus', 'Xiaomi'],
            'models': ['iPhone 14', 'Galaxy S23', 'Pixel 7', 'OnePlus 11', 'Mi 13']
        },
        'Tablet': {
            'brands': ['Apple', 'Samsung', 'Microsoft', 'Amazon'],
            'models': ['iPad Pro', 'Galaxy Tab', 'Surface Pro', 'Fire HD']
        },
        'Camera': {
            'brands': ['Canon', 'Nikon', 'Sony', 'Fujifilm'],
            'models': ['EOS R6', 'D850', 'A7 IV', 'X-T5']
        },
        'Headphones': {
            'brands': ['Sony', 'Bose', 'Apple', 'Sennheiser'],
            'models': ['WH-1000XM5', 'QuietComfort', 'AirPods Pro', 'HD 660S']
        }
    }
    
    category = random.choice(list(electronics.keys()))
    brand = random.choice(electronics[category]['brands'])
    model = random.choice(electronics[category]['models'])
    
    title = f"{brand} {model}"
    description = f"{brand} {model} in excellent condition. " + \
                 f"Comes with original box and accessories. " + \
                 fake.text(max_nb_chars=150)
    
    return {
        'title': title,
        'description': description,
        'price': random.randint(200, 2500),
        'brand': brand,
        'model': model,
        'condition': random.choice(['New', 'Like New', 'Good', 'Fair']),
        'warranty': random.choice([True, False]),
        'storage': random.choice(['64GB', '128GB', '256GB', '512GB', '1TB']) if category in ['Smartphone', 'Tablet', 'Laptop'] else None,
        'images': [random.choice(CATEGORY_IMAGES['electronics'])]
    }

def generate_apparel_listing():
    """Generate realistic apparel listing data"""
    clothing_types = ['Jacket', 'Jeans', 'Dress', 'Shirt', 'Shoes', 'Sweater', 'Pants', 'Skirt']
    brands = ['Nike', 'Adidas', 'Levi\'s', 'Zara', 'H&M', 'Uniqlo', 'Gap', 'Calvin Klein']
    sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL']
    colors = ['Black', 'White', 'Blue', 'Red', 'Green', 'Gray', 'Navy', 'Brown']
    
    item_type = random.choice(clothing_types)
    brand = random.choice(brands)
    size = random.choice(sizes)
    color = random.choice(colors)
    
    title = f"{brand} {color} {item_type} - Size {size}"
    description = f"{brand} {item_type} in {color.lower()}. Size {size}. " + \
                 f"Great condition, worn only a few times. " + \
                 fake.text(max_nb_chars=100)
    
    return {
        'title': title,
        'description': description,
        'price': random.randint(15, 150),
        'brand': brand,
        'size': size,
        'color': color,
        'condition': random.choice(['New with tags', 'Like new', 'Good', 'Fair']),
        'material': random.choice(['Cotton', 'Polyester', 'Wool', 'Denim', 'Leather', 'Silk']),
        'gender': random.choice(['Men', 'Women', 'Unisex']),
        'images': [random.choice(CATEGORY_IMAGES['apparel'])]
    }

def generate_base_listing_data(category):
    """Generate base listing data common to all categories"""
    return {
        'sellerId': fake.uuid4(),
        'sellerName': fake.name(),
        'location': f"{fake.city()}, {fake.state_abbr()}",
        'category': category,
        'createdAt': datetime.now(),
        'updatedAt': datetime.now(),
        'featured': random.choice([True, False]),
        'status': 'active'
    }

def seed_listings():
    """Main seeding function"""
    print("🔍 Initializing Firebase connection...")
    
    db = initialize_firebase()
    if not db:
        return False
    
    try:
        categories = {
            'vehicles': generate_vehicle_listing,
            'property-rentals': generate_property_listing,
            'electronics': generate_electronics_listing,
            'apparel': generate_apparel_listing
        }
        
        total_created = 0
        
        for category, generator_func in categories.items():
            print(f"\n📝 Creating listings for category: {category}")
            
            for i in range(10):  # 10 listings per category
                # Generate category-specific data
                specific_data = generator_func()
                
                # Generate base data
                base_data = generate_base_listing_data(category)
                
                # Combine data
                listing_data = {**base_data, **specific_data}
                
                # Add to Firestore
                doc_ref = db.collection('listings').add(listing_data)
                total_created += 1
                
                print(f"  ✅ Created: {specific_data['title']}")
        
        print(f"\n🎉 Successfully created {total_created} realistic listings!")
        print(f"📊 {total_created // 4} listings per category")
        
        return True
        
    except Exception as e:
        print(f"❌ Error during seeding: {e}")
        return False

if __name__ == "__main__":
    print("🌱 Starting realistic data seeding...")
    
    # Install faker if not available
    try:
        from faker import Faker
    except ImportError:
        print("📦 Installing faker...")
        os.system("pip install faker")
        from faker import Faker
    
    success = seed_listings()
    
    if success:
        print("✅ Seeding completed successfully!")
        sys.exit(0)
    else:
        print("❌ Seeding failed!")
        sys.exit(1)
