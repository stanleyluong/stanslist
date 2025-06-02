#!/usr/bin/env python3
"""
Seeding script with proper Firebase Storage URLs that include tokens.
Creates realistic dummy data for all categories.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
import uuid
from datetime import datetime, timedelta
import random

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        service_account_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
        
        if not os.path.exists(service_account_path):
            print(f"❌ Service account key not found at: {service_account_path}")
            return None
            
        # Check if Firebase is already initialized
        try:
            firebase_admin.get_app()
        except ValueError:
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred, {
                'storageBucket': 'stan-s-list.firebasestorage.app'
            })
        
        return firestore.client()
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        return None

def generate_firebase_url(category, filename):
    """Generate a Firebase Storage URL with token"""
    # Generate a realistic UUID token
    token = str(uuid.uuid4())
    base_url = "https://firebasestorage.googleapis.com/v0/b/stan-s-list.firebasestorage.app/o"
    encoded_path = f"{category}%2F{filename}"
    return f"{base_url}/{encoded_path}?alt=media&token={token}"

def create_vehicles_listings():
    """Create vehicle listings with realistic data"""
    vehicles = [
        {
            "title": "2018 Honda Civic - Excellent Condition",
            "description": "Well-maintained 2018 Honda Civic with low mileage. Clean interior, no accidents, regular oil changes. Perfect for daily commuting or first-time car buyers.",
            "price": 18500,
            "make": "Honda",
            "model": "Civic",
            "year": 2018,
            "mileage": 45000,
            "condition": "excellent",
            "transmission": "manual",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "honda_civic_2018.jpg")]
        },
        {
            "title": "2020 Toyota Camry Hybrid - Fuel Efficient",
            "description": "2020 Toyota Camry Hybrid in pristine condition. Excellent fuel economy, advanced safety features, and comfortable interior. Owner moving overseas.",
            "price": 24000,
            "make": "Toyota",
            "model": "Camry",
            "year": 2020,
            "mileage": 32000,
            "condition": "excellent",
            "transmission": "automatic",
            "fuelType": "hybrid",
            "images": [generate_firebase_url("vehicles", "toyota_camry_hybrid.jpg")]
        },
        {
            "title": "2016 Ford F-150 Pickup Truck",
            "description": "Reliable 2016 Ford F-150 with extended cab. Perfect for work or recreation. Some wear but mechanically sound. Great for hauling and towing.",
            "price": 22000,
            "make": "Ford",
            "model": "F-150",
            "year": 2016,
            "mileage": 75000,
            "condition": "good",
            "transmission": "automatic",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "ford_f150_2016.jpg")]
        },
        {
            "title": "2019 Tesla Model 3 - Electric Vehicle",
            "description": "2019 Tesla Model 3 Standard Range Plus. Autopilot included, over-the-air updates, supercharging network access. Clean title, no accidents.",
            "price": 32000,
            "make": "Tesla",
            "model": "Model 3",
            "year": 2019,
            "mileage": 28000,
            "condition": "excellent",
            "transmission": "automatic",
            "fuelType": "electric",
            "images": [generate_firebase_url("vehicles", "tesla_model3_2019.jpg")]
        },
        {
            "title": "2017 BMW 3 Series - Luxury Sedan",
            "description": "2017 BMW 3 Series with premium package. Leather seats, navigation system, parking sensors. Well-maintained with service records available.",
            "price": 26500,
            "make": "BMW",
            "model": "3 Series",
            "year": 2017,
            "mileage": 52000,
            "condition": "good",
            "transmission": "automatic",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "bmw_3series_2017.jpg")]
        },
        {
            "title": "2015 Jeep Wrangler - Off-Road Ready",
            "description": "2015 Jeep Wrangler Unlimited with lifted suspension and all-terrain tires. Perfect for adventure seekers. Some cosmetic wear from outdoor use.",
            "price": 28000,
            "make": "Jeep",
            "model": "Wrangler",
            "year": 2015,
            "mileage": 68000,
            "condition": "good",
            "transmission": "manual",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "jeep_wrangler_2015.jpg")]
        },
        {
            "title": "2021 Hyundai Elantra - Like New",
            "description": "Nearly new 2021 Hyundai Elantra with warranty remaining. Bluetooth, backup camera, excellent fuel economy. Moving to a different state, must sell.",
            "price": 21000,
            "make": "Hyundai",
            "model": "Elantra",
            "year": 2021,
            "mileage": 15000,
            "condition": "excellent",
            "transmission": "automatic",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "hyundai_elantra_2021.jpg")]
        },
        {
            "title": "2014 Subaru Outback - Adventure Wagon",
            "description": "2014 Subaru Outback with all-wheel drive. Great for camping and outdoor activities. Regular maintenance, some minor scratches but runs great.",
            "price": 16000,
            "make": "Subaru",
            "model": "Outback",
            "year": 2014,
            "mileage": 95000,
            "condition": "fair",
            "transmission": "automatic",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "subaru_outback_2014.jpg")]
        },
        {
            "title": "2019 Nissan Altima - Sedan",
            "description": "2019 Nissan Altima with modern features and comfortable interior. Excellent for daily driving, good gas mileage, clean maintenance record.",
            "price": 19500,
            "make": "Nissan",
            "model": "Altima",
            "year": 2019,
            "mileage": 41000,
            "condition": "excellent",
            "transmission": "automatic",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "nissan_altima_2019.jpg")]
        },
        {
            "title": "2016 Mazda CX-5 - Compact SUV",
            "description": "2016 Mazda CX-5 with AWD. Sporty handling, reliable performance, and great value. Perfect size for city driving with cargo space for weekends.",
            "price": 17500,
            "make": "Mazda",
            "model": "CX-5",
            "year": 2016,
            "mileage": 72000,
            "condition": "good",
            "transmission": "automatic",
            "fuelType": "gasoline",
            "images": [generate_firebase_url("vehicles", "mazda_cx5_2016.jpg")]
        }
    ]
    return vehicles

def create_property_listings():
    """Create property rental listings with realistic data"""
    properties = [
        {
            "title": "Spacious 2BR Apartment Downtown",
            "description": "Beautiful 2-bedroom apartment in the heart of downtown. Walking distance to restaurants, shops, and public transit. Hardwood floors, updated kitchen, in-unit laundry.",
            "price": 2200,
            "bedrooms": 2,
            "bathrooms": 1,
            "squareFootage": 950,
            "propertyType": "apartment",
            "furnished": False,
            "petsAllowed": True,
            "parkingIncluded": False,
            "images": [generate_firebase_url("property-rentals", "downtown_2br_apt.jpg")]
        },
        {
            "title": "Cozy 1BR Studio - Perfect for Students",
            "description": "Affordable studio apartment near university campus. All utilities included, perfect for students or young professionals. Quiet neighborhood with easy parking.",
            "price": 1200,
            "bedrooms": 1,
            "bathrooms": 1,
            "squareFootage": 450,
            "propertyType": "studio",
            "furnished": True,
            "petsAllowed": False,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "student_studio.jpg")]
        },
        {
            "title": "Modern 3BR House with Yard",
            "description": "Newly renovated 3-bedroom house with large backyard. Perfect for families, close to schools and parks. Two-car garage, updated appliances, central air.",
            "price": 2800,
            "bedrooms": 3,
            "bathrooms": 2,
            "squareFootage": 1650,
            "propertyType": "house",
            "furnished": False,
            "petsAllowed": True,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "modern_3br_house.jpg")]
        },
        {
            "title": "Luxury 2BR Condo - High Rise",
            "description": "Luxury 2-bedroom condo on the 15th floor with city views. Amenities include gym, pool, concierge. Premium finishes throughout, floor-to-ceiling windows.",
            "price": 3500,
            "bedrooms": 2,
            "bathrooms": 2,
            "squareFootage": 1200,
            "propertyType": "condo",
            "furnished": False,
            "petsAllowed": False,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "luxury_condo.jpg")]
        },
        {
            "title": "Charming 1BR Garden Apartment",
            "description": "Charming ground-floor apartment with private garden access. Quiet residential area, perfect for someone who loves gardening. Updated bathroom and kitchen.",
            "price": 1600,
            "bedrooms": 1,
            "bathrooms": 1,
            "squareFootage": 700,
            "propertyType": "apartment",
            "furnished": False,
            "petsAllowed": True,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "garden_apartment.jpg")]
        },
        {
            "title": "4BR Family Home - Suburban",
            "description": "Spacious 4-bedroom family home in quiet suburban neighborhood. Large kitchen, finished basement, two-car garage. Great schools nearby.",
            "price": 3200,
            "bedrooms": 4,
            "bathrooms": 3,
            "squareFootage": 2200,
            "propertyType": "house",
            "furnished": False,
            "petsAllowed": True,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "suburban_family_home.jpg")]
        },
        {
            "title": "Converted Loft - Artist Space",
            "description": "Unique converted loft space perfect for artists or creative professionals. High ceilings, lots of natural light, industrial charm. Open floor plan.",
            "price": 2000,
            "bedrooms": 1,
            "bathrooms": 1,
            "squareFootage": 1100,
            "propertyType": "loft",
            "furnished": False,
            "petsAllowed": True,
            "parkingIncluded": False,
            "images": [generate_firebase_url("property-rentals", "artist_loft.jpg")]
        },
        {
            "title": "Shared 3BR House - Room Available",
            "description": "Furnished room available in shared 3-bedroom house. Common areas include full kitchen, living room, backyard. Looking for clean, responsible roommate.",
            "price": 900,
            "bedrooms": 1,
            "bathrooms": 1,
            "squareFootage": 300,
            "propertyType": "room",
            "furnished": True,
            "petsAllowed": False,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "shared_house_room.jpg")]
        },
        {
            "title": "Beachfront 2BR Vacation Rental",
            "description": "Beautiful beachfront apartment available for long-term rental. Wake up to ocean views every day. Fully furnished, perfect for remote workers.",
            "price": 2600,
            "bedrooms": 2,
            "bathrooms": 2,
            "squareFootage": 1000,
            "propertyType": "apartment",
            "furnished": True,
            "petsAllowed": False,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "beachfront_apartment.jpg")]
        },
        {
            "title": "Tiny House - Minimalist Living",
            "description": "Unique tiny house for rent. Perfect for someone wanting to try minimalist living. All necessities included in efficient 400 sq ft space. Eco-friendly features.",
            "price": 1400,
            "bedrooms": 1,
            "bathrooms": 1,
            "squareFootage": 400,
            "propertyType": "house",
            "furnished": True,
            "petsAllowed": True,
            "parkingIncluded": True,
            "images": [generate_firebase_url("property-rentals", "tiny_house.jpg")]
        }
    ]
    return properties

def create_electronics_listings():
    """Create electronics listings with realistic data"""
    electronics = [
        {
            "title": "iPhone 13 Pro - 256GB Unlocked",
            "description": "iPhone 13 Pro in excellent condition. 256GB storage, unlocked for any carrier. Includes original box, charger, and screen protector already applied. No scratches.",
            "price": 750,
            "brand": "Apple",
            "model": "iPhone 13 Pro",
            "condition": "excellent",
            "storage": "256GB",
            "connectivity": "unlocked",
            "images": [generate_firebase_url("electronics", "iphone13_pro.jpg")]
        },
        {
            "title": "MacBook Air M2 - Perfect for Students",
            "description": "2022 MacBook Air with M2 chip. 8GB RAM, 256GB SSD. Perfect for students and professionals. Excellent battery life, barely used. Includes original charger.",
            "price": 999,
            "brand": "Apple",
            "model": "MacBook Air M2",
            "condition": "excellent",
            "storage": "256GB",
            "connectivity": "wifi",
            "images": [generate_firebase_url("electronics", "macbook_air_m2.jpg")]
        },
        {
            "title": "Samsung 65\" 4K Smart TV",
            "description": "Samsung 65-inch 4K UHD Smart TV. Excellent picture quality, includes all smart TV features. Perfect for movie nights. Moving sale, must go quickly.",
            "price": 600,
            "brand": "Samsung",
            "model": "UN65AU8000",
            "condition": "good",
            "storage": "32GB",
            "connectivity": "wifi",
            "images": [generate_firebase_url("electronics", "samsung_65_4k_tv.jpg")]
        },
        {
            "title": "PlayStation 5 Console - Like New",
            "description": "PlayStation 5 console in like-new condition. Barely used, includes one controller and all original cables. Perfect for gaming enthusiasts.",
            "price": 450,
            "brand": "Sony",
            "model": "PlayStation 5",
            "condition": "excellent",
            "storage": "825GB",
            "connectivity": "wifi",
            "images": [generate_firebase_url("electronics", "playstation5.jpg")]
        },
        {
            "title": "Canon EOS R6 Camera Body",
            "description": "Canon EOS R6 mirrorless camera body. Professional-grade camera perfect for photography enthusiasts. Low shutter count, excellent condition.",
            "price": 1800,
            "brand": "Canon",
            "model": "EOS R6",
            "condition": "excellent",
            "storage": "64GB",
            "connectivity": "wifi",
            "images": [generate_firebase_url("electronics", "canon_eos_r6.jpg")]
        },
        {
            "title": "iPad Pro 12.9\" with Apple Pencil",
            "description": "iPad Pro 12.9-inch with Apple Pencil included. Perfect for digital art, note-taking, or entertainment. 128GB storage, excellent battery life.",
            "price": 850,
            "brand": "Apple",
            "model": "iPad Pro 12.9",
            "condition": "good",
            "storage": "128GB",
            "connectivity": "wifi",
            "images": [generate_firebase_url("electronics", "ipad_pro_129.jpg")]
        },
        {
            "title": "Gaming PC - RTX 3070 Build",
            "description": "Custom gaming PC with RTX 3070, Ryzen 7 processor, 32GB RAM, 1TB NVMe SSD. Perfect for gaming and content creation. Runs all modern games smoothly.",
            "price": 1200,
            "brand": "Custom",
            "model": "Gaming PC",
            "condition": "excellent",
            "storage": "1TB",
            "connectivity": "ethernet",
            "images": [generate_firebase_url("electronics", "gaming_pc_rtx3070.jpg")]
        },
        {
            "title": "AirPods Pro 2nd Generation",
            "description": "Apple AirPods Pro 2nd generation with active noise cancellation. Includes charging case and all original accessories. Perfect sound quality.",
            "price": 200,
            "brand": "Apple",
            "model": "AirPods Pro 2",
            "condition": "excellent",
            "storage": "N/A",
            "connectivity": "bluetooth",
            "images": [generate_firebase_url("electronics", "airpods_pro_2.jpg")]
        },
        {
            "title": "Nintendo Switch OLED - Animal Crossing",
            "description": "Nintendo Switch OLED model with Animal Crossing game included. Barely used, perfect for portable gaming. Includes dock, controllers, and carrying case.",
            "price": 300,
            "brand": "Nintendo",
            "model": "Switch OLED",
            "condition": "excellent",
            "storage": "64GB",
            "connectivity": "wifi",
            "images": [generate_firebase_url("electronics", "nintendo_switch_oled.jpg")]
        },
        {
            "title": "Dell 27\" 4K Monitor - Professional",
            "description": "Dell UltraSharp 27-inch 4K monitor. Perfect for professional work, excellent color accuracy. USB-C connectivity, height adjustable stand.",
            "price": 400,
            "brand": "Dell",
            "model": "S2722DC",
            "condition": "good",
            "storage": "N/A",
            "connectivity": "usb-c",
            "images": [generate_firebase_url("electronics", "dell_27_4k_monitor.jpg")]
        }
    ]
    return electronics

def create_apparel_listings():
    """Create apparel listings with realistic data"""
    apparel = [
        {
            "title": "Levi's 501 Jeans - Vintage Wash",
            "description": "Classic Levi's 501 jeans in vintage wash. Size 32x32, excellent condition. Timeless style that never goes out of fashion. Slight fading for authentic vintage look.",
            "price": 45,
            "brand": "Levi's",
            "size": "32x32",
            "condition": "good",
            "color": "blue",
            "material": "denim",
            "images": [generate_firebase_url("apparel", "levis_501_vintage.jpg")]
        },
        {
            "title": "North Face Puffer Jacket - Women's M",
            "description": "North Face puffer jacket in excellent condition. Women's size Medium. Perfect for cold weather, very warm and lightweight. Black color goes with everything.",
            "price": 120,
            "brand": "The North Face",
            "size": "M",
            "condition": "excellent",
            "color": "black",
            "material": "nylon",
            "images": [generate_firebase_url("apparel", "northface_puffer_womens.jpg")]
        },
        {
            "title": "Nike Air Jordan 1 - Size 10",
            "description": "Nike Air Jordan 1 sneakers in size 10. Good condition with some wear on soles. Classic colorway, authentic Nike product. Great for casual wear or collecting.",
            "price": 150,
            "brand": "Nike",
            "size": "10",
            "condition": "good",
            "color": "black/red",
            "material": "leather",
            "images": [generate_firebase_url("apparel", "jordan1_size10.jpg")]
        },
        {
            "title": "Patagonia Fleece Vest - Unisex L",
            "description": "Patagonia fleece vest in excellent condition. Unisex size Large. Perfect for layering, very warm and comfortable. Great for outdoor activities.",
            "price": 65,
            "brand": "Patagonia",
            "size": "L",
            "condition": "excellent",
            "color": "navy",
            "material": "fleece",
            "images": [generate_firebase_url("apparel", "patagonia_fleece_vest.jpg")]
        },
        {
            "title": "Vintage Band T-Shirt - The Beatles",
            "description": "Vintage The Beatles t-shirt from the 90s. Size Large, soft cotton material. Some vintage wear adds to authenticity. Perfect for music lovers and collectors.",
            "price": 35,
            "brand": "Vintage",
            "size": "L",
            "condition": "fair",
            "color": "black",
            "material": "cotton",
            "images": [generate_firebase_url("apparel", "beatles_vintage_tshirt.jpg")]
        },
        {
            "title": "Lululemon Leggings - Women's 6",
            "description": "Lululemon Align leggings in women's size 6. Excellent condition, barely worn. Super comfortable and flattering fit. Perfect for yoga or everyday wear.",
            "price": 85,
            "brand": "Lululemon",
            "size": "6",
            "condition": "excellent",
            "color": "black",
            "material": "nylon",
            "images": [generate_firebase_url("apparel", "lululemon_align_leggings.jpg")]
        },
        {
            "title": "Carhartt Work Jacket - Men's XL",
            "description": "Carhartt work jacket in men's size XL. Heavy-duty construction, perfect for outdoor work. Some wear from use but still very functional and warm.",
            "price": 75,
            "brand": "Carhartt",
            "size": "XL",
            "condition": "good",
            "color": "brown",
            "material": "canvas",
            "images": [generate_firebase_url("apparel", "carhartt_work_jacket.jpg")]
        },
        {
            "title": "Adidas Ultraboost - Women's 8",
            "description": "Adidas Ultraboost running shoes in women's size 8. Great for running or casual wear. Some wear on soles but still plenty of life left. Very comfortable.",
            "price": 90,
            "brand": "Adidas",
            "size": "8",
            "condition": "good",
            "color": "white",
            "material": "mesh",
            "images": [generate_firebase_url("apparel", "adidas_ultraboost_womens.jpg")]
        },
        {
            "title": "Supreme Box Logo Hoodie - Size M",
            "description": "Authentic Supreme box logo hoodie in size Medium. Excellent condition, rarely worn. Classic red colorway. Perfect for streetwear enthusiasts.",
            "price": 400,
            "brand": "Supreme",
            "size": "M",
            "condition": "excellent",
            "color": "red",
            "material": "cotton",
            "images": [generate_firebase_url("apparel", "supreme_box_logo_hoodie.jpg")]
        },
        {
            "title": "Formal Dress Shirt - Men's 16/34",
            "description": "Men's formal dress shirt in size 16 neck, 34 sleeve. White color, perfect for business or formal events. Iron-free material, excellent condition.",
            "price": 25,
            "brand": "Brooks Brothers",
            "size": "16/34",
            "condition": "excellent",
            "color": "white",
            "material": "cotton",
            "images": [generate_firebase_url("apparel", "formal_dress_shirt.jpg")]
        }
    ]
    return apparel

def create_listing(db, listing_data, category, user_id):
    """Create a single listing in Firestore"""
    # Common fields for all listings
    base_data = {
        'category': category,
        'userId': user_id,
        'location': 'San Francisco, CA',
        'createdAt': datetime.now(),
        'updatedAt': datetime.now(),
        'status': 'active',
        'views': random.randint(5, 50),
        'favoriteCount': random.randint(0, 10)
    }
    
    # Merge with category-specific data
    final_data = {**base_data, **listing_data}
    
    # Add the listing to Firestore
    doc_ref = db.collection('listings').document()
    doc_ref.set(final_data)
    return doc_ref.id

def seed_realistic_data():
    """Main function to seed realistic data"""
    db = initialize_firebase()
    if not db:
        return
    
    print("🌱 Starting realistic data seeding with proper Firebase URLs...")
    
    # Fake user IDs for different sellers
    user_ids = [
        'user_john_doe',
        'user_jane_smith', 
        'user_mike_johnson',
        'user_sarah_wilson',
        'user_david_brown',
        'user_lisa_davis',
        'user_chris_garcia',
        'user_emma_taylor',
        'user_ryan_martinez',
        'user_amanda_anderson'
    ]
    
    categories_data = {
        'vehicles': create_vehicles_listings(),
        'property-rentals': create_property_listings(),
        'electronics': create_electronics_listings(),
        'apparel': create_apparel_listings()
    }
    
    total_created = 0
    
    for category, listings in categories_data.items():
        print(f"\n📁 Creating {category} listings...")
        category_count = 0
        
        for i, listing_data in enumerate(listings):
            user_id = user_ids[i % len(user_ids)]  # Rotate through users
            listing_id = create_listing(db, listing_data, category, user_id)
            category_count += 1
            total_created += 1
            print(f"  ✅ Created: {listing_data['title']}")
        
        print(f"  📊 {category}: {category_count} listings created")
    
    print(f"\n🎉 Successfully created {total_created} realistic listings!")
    print(f"📊 All listings include proper Firebase Storage URLs with tokens")

if __name__ == "__main__":
    seed_realistic_data()
