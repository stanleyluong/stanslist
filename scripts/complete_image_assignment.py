#!/usr/bin/env python3
"""
Complete Image Assignment System
Handles remaining unmatched listings and fixes any broken URLs
"""

import firebase_admin
from firebase_admin import credentials, firestore
import requests

# Initialize Firebase Admin
if not firebase_admin._apps:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

def get_additional_images() -> dict:
    """Get additional verified working images for remaining listings."""
    
    return {
        "hyundai_elantra": {
            "url": "https://images.unsplash.com/photo-1605559424843-9e4c228bf1c2?w=800&h=600&fit=crop",
            "keywords": ["hyundai", "elantra", "sedan", "korean car", "compact"],
            "category": "vehicles"
        },
        "subaru_outback": {
            "url": "https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop", 
            "keywords": ["subaru", "outback", "wagon", "adventure", "all-wheel"],
            "category": "vehicles"
        },
        "toyota_camry_hybrid": {
            "url": "https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop",
            "keywords": ["toyota", "camry", "hybrid", "fuel efficient", "eco"],
            "category": "vehicles"
        },
        "cybertruck": {
            "url": "https://images.unsplash.com/photo-1571068316344-75bc76f77890?w=800&h=600&fit=crop",
            "keywords": ["cybertruck", "tesla", "electric truck", "futuristic"],
            "category": "vehicles"
        },
        "student_studio": {
            "url": "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop",
            "keywords": ["studio", "student", "cozy", "small", "affordable"],
            "category": "property-rentals"
        },
        "downtown_apartment": {
            "url": "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop",
            "keywords": ["apartment", "downtown", "spacious", "urban", "modern"],
            "category": "property-rentals"
        },
        "garden_apartment_2": {
            "url": "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&h=600&fit=crop",
            "keywords": ["garden", "apartment", "charming", "ground floor", "patio"],
            "category": "property-rentals"
        },
        "cat_toy": {
            "url": "https://images.unsplash.com/photo-1574158622682-e40e69881006?w=800&h=600&fit=crop",
            "keywords": ["cat", "toy", "pet", "accessories", "play"],
            "category": "electronics"
        },
        "computer_monitor": {
            "url": "https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&h=600&fit=crop",
            "keywords": ["monitor", "dell", "4k", "professional", "display"],
            "category": "electronics"
        },
        "fairy_garden": {
            "url": "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop",
            "keywords": ["fairy", "garden", "miniature", "decorative", "cute"],
            "category": "other"
        }
    }

def verify_image_url(url: str) -> bool:
    """Verify that an image URL is accessible."""
    try:
        response = requests.head(url, timeout=5)
        return response.status_code == 200
    except:
        return False

def assign_remaining_images():
    """Assign images to remaining unmatched listings."""
    
    print("🔧 Completing image assignments for remaining listings...")
    
    # Get listings without images or with broken images
    listings_ref = db.collection('listings')
    listings = listings_ref.stream()
    
    unmatched_listings = []
    for listing in listings:
        data = listing.to_dict()
        data['id'] = listing.id
        
        # Check if listing needs an image
        images = data.get('images', [])
        needs_image = False
        
        if not images:
            needs_image = True
        else:
            # Check if current image is broken
            for img_url in images:
                if not verify_image_url(img_url):
                    needs_image = True
                    break
        
        if needs_image:
            unmatched_listings.append(data)
    
    print(f"📊 Found {len(unmatched_listings)} listings needing images")
    
    # Get additional image options
    additional_images = get_additional_images()
    
    # Verify additional images
    valid_additional = {}
    for img_id, img_data in additional_images.items():
        if verify_image_url(img_data["url"]):
            valid_additional[img_id] = img_data
        else:
            print(f"❌ Invalid additional URL for {img_id}")
    
    print(f"✅ {len(valid_additional)} additional valid images available")
    
    # Manual assignments for specific listings
    manual_assignments = {
        "2021 Hyundai Elantra - Like New": "hyundai_elantra",
        "2014 Subaru Outback - Adventure Wagon": "subaru_outback", 
        "2020 Toyota Camry Hybrid - Fuel Efficient": "toyota_camry_hybrid",
        "Cybertruck": "cybertruck",
        "Cozy 1BR Studio - Perfect for Students": "student_studio",
        "Spacious 2BR Apartment Downtown": "downtown_apartment",
        "Charming 1BR Garden Apartment": "garden_apartment_2",
        "cat toy for sale": "cat_toy",
        "Fairy garden": "fairy_garden"
    }
    
    # Apply assignments
    assigned_count = 0
    
    for listing in unmatched_listings:
        title = listing.get('title', '')
        
        # Check for manual assignment first
        assigned_image = None
        for target_title, img_id in manual_assignments.items():
            if target_title.lower() in title.lower() or title.lower() in target_title.lower():
                if img_id in valid_additional:
                    assigned_image = valid_additional[img_id]
                    break
        
        # For "Dell 27" 4K Monitor", use computer_monitor
        if "dell" in title.lower() and "monitor" in title.lower():
            assigned_image = valid_additional.get("computer_monitor")
        
        # If still no assignment, use a generic fallback
        if not assigned_image and valid_additional:
            # Use first available image as fallback
            img_id = list(valid_additional.keys())[0]
            assigned_image = valid_additional[img_id]
            del valid_additional[img_id]  # Remove to maintain uniqueness
        
        if assigned_image:
            try:
                listing_ref = db.collection('listings').document(listing['id'])
                listing_ref.update({
                    'images': [assigned_image['url']]
                })
                assigned_count += 1
                print(f"  ✅ Updated '{title}' with image")
                
            except Exception as e:
                print(f"  ❌ Failed to update '{title}': {e}")
        else:
            print(f"  ⚠️  No image available for '{title}'")
    
    print(f"\n🎉 Assignment complete!")
    print(f"📊 Updated {assigned_count} additional listings")
    
    # Final verification
    print(f"\n🔍 Running final verification...")
    
    total_listings = 0
    total_with_images = 0
    broken_images = 0
    
    listings = db.collection('listings').stream()
    for listing in listings:
        data = listing.to_dict()
        total_listings += 1
        
        images = data.get('images', [])
        if images:
            total_with_images += 1
            for img_url in images:
                if not verify_image_url(img_url):
                    broken_images += 1
                    print(f"  ❌ Broken image in '{data.get('title', 'Unknown')}': {img_url}")
    
    print(f"\n📈 Final Statistics:")
    print(f"  Total listings: {total_listings}")
    print(f"  Listings with images: {total_with_images}")
    print(f"  Image coverage: {total_with_images/total_listings*100:.1f}%")
    print(f"  Broken images: {broken_images}")
    
    if broken_images == 0:
        print(f"  🎉 All images are working correctly!")

if __name__ == "__main__":
    assign_remaining_images()
