#!/usr/bin/env python3
"""
Perfect Image Matching System
Creates a sophisticated matching algorithm that assigns unique, perfectly matched images
to each listing based on detailed content analysis.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import re
from typing import Dict, List, Tuple, Set
import requests
import time

# Initialize Firebase Admin
if not firebase_admin._apps:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

def create_comprehensive_image_database() -> Dict[str, Dict]:
    """Create a comprehensive database of images with detailed keywords and categories."""
    
    return {
        # VEHICLES - Cars
        "bmw_3_series": {
            "url": "https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&h=600&fit=crop",
            "keywords": ["bmw", "3 series", "luxury sedan", "german car", "premium"],
            "category": "vehicles",
            "type": "car",
            "brand": "bmw"
        },
        "honda_civic": {
            "url": "https://images.unsplash.com/photo-1550355291-bbee04a92027?w=800&h=600&fit=crop",
            "keywords": ["honda", "civic", "sedan", "reliable", "compact"],
            "category": "vehicles", 
            "type": "car",
            "brand": "honda"
        },
        "toyota_camry": {
            "url": "https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop",
            "keywords": ["toyota", "camry", "sedan", "family car", "reliable"],
            "category": "vehicles",
            "type": "car", 
            "brand": "toyota"
        },
        "ford_mustang": {
            "url": "https://images.unsplash.com/photo-1494976688530-79aaec4325fb?w=800&h=600&fit=crop",
            "keywords": ["ford", "mustang", "sports car", "muscle car", "american"],
            "category": "vehicles",
            "type": "car",
            "brand": "ford"
        },
        "jeep_wrangler": {
            "url": "https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=800&h=600&fit=crop",
            "keywords": ["jeep", "wrangler", "suv", "off-road", "4x4"],
            "category": "vehicles",
            "type": "suv",
            "brand": "jeep"
        },
        "tesla_model_3": {
            "url": "https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=800&h=600&fit=crop",
            "keywords": ["tesla", "model 3", "electric", "ev", "modern"],
            "category": "vehicles",
            "type": "car",
            "brand": "tesla"
        },
        "pickup_truck": {
            "url": "https://images.unsplash.com/photo-1553440569-bcc63803a83d?w=800&h=600&fit=crop",
            "keywords": ["pickup", "truck", "f-150", "silverado", "ram"],
            "category": "vehicles",
            "type": "truck",
            "brand": "generic"
        },
        "motorcycle": {
            "url": "https://images.unsplash.com/photo-1558618047-3c8c76ca7d13?w=800&h=600&fit=crop",
            "keywords": ["motorcycle", "bike", "harley", "yamaha", "kawasaki"],
            "category": "vehicles",
            "type": "motorcycle",
            "brand": "generic"
        },
        "luxury_car": {
            "url": "https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&h=600&fit=crop",
            "keywords": ["luxury", "premium", "mercedes", "audi", "lexus"],
            "category": "vehicles",
            "type": "car",
            "brand": "luxury"
        },
        "compact_car": {
            "url": "https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop",
            "keywords": ["compact", "small car", "city car", "hatchback"],
            "category": "vehicles",
            "type": "car",
            "brand": "generic"
        },
        
        # PROPERTY RENTALS
        "modern_apartment": {
            "url": "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop",
            "keywords": ["apartment", "modern", "city", "downtown", "loft"],
            "category": "property-rentals",
            "type": "apartment"
        },
        "luxury_condo": {
            "url": "https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop",
            "keywords": ["luxury", "condo", "penthouse", "high-rise", "premium"],
            "category": "property-rentals",
            "type": "condo"
        },
        "cozy_studio": {
            "url": "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop",
            "keywords": ["studio", "cozy", "small", "efficient", "compact"],
            "category": "property-rentals",
            "type": "studio"
        },
        "family_house": {
            "url": "https://images.unsplash.com/photo-1505843513577-22bb7d21e455?w=800&h=600&fit=crop",
            "keywords": ["house", "family", "suburban", "yard", "neighborhood"],
            "category": "property-rentals",
            "type": "house"
        },
        "beachfront_condo": {
            "url": "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&h=600&fit=crop",
            "keywords": ["beachfront", "ocean", "beach", "waterfront", "resort"],
            "category": "property-rentals",
            "type": "condo"
        },
        "downtown_loft": {
            "url": "https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop",
            "keywords": ["loft", "downtown", "industrial", "exposed brick", "open"],
            "category": "property-rentals",
            "type": "loft"
        },
        "spacious_apartment": {
            "url": "https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop",
            "keywords": ["spacious", "large", "bright", "airy", "open floor"],
            "category": "property-rentals",
            "type": "apartment"
        },
        "furnished_rental": {
            "url": "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=600&fit=crop",
            "keywords": ["furnished", "ready", "move-in", "complete", "equipped"],
            "category": "property-rentals",
            "type": "apartment"
        },
        "garden_apartment": {
            "url": "https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=800&h=600&fit=crop",
            "keywords": ["garden", "ground floor", "patio", "outdoor space"],
            "category": "property-rentals",
            "type": "apartment"
        },
        "penthouse_view": {
            "url": "https://images.unsplash.com/photo-1512917774080-9991f1c4c750?w=800&h=600&fit=crop",
            "keywords": ["penthouse", "view", "city view", "high floor", "panoramic"],
            "category": "property-rentals",
            "type": "penthouse"
        },
        
        # ELECTRONICS
        "iphone_15": {
            "url": "https://images.unsplash.com/photo-1592286499817-a40d5d8b4f71?w=800&h=600&fit=crop",
            "keywords": ["iphone", "iphone 15", "apple", "smartphone", "ios"],
            "category": "electronics",
            "type": "phone",
            "brand": "apple"
        },
        "macbook_pro": {
            "url": "https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop",
            "keywords": ["macbook", "macbook pro", "apple", "laptop", "mac"],
            "category": "electronics",
            "type": "laptop",
            "brand": "apple"
        },
        "gaming_laptop": {
            "url": "https://images.unsplash.com/photo-1603302576837-37561b2e2302?w=800&h=600&fit=crop",
            "keywords": ["gaming laptop", "gaming", "rgb", "asus", "msi"],
            "category": "electronics",
            "type": "laptop",
            "brand": "gaming"
        },
        "playstation_5": {
            "url": "https://images.unsplash.com/photo-1606813907291-d86efa9b94db?w=800&h=600&fit=crop",
            "keywords": ["playstation", "ps5", "playstation 5", "sony", "gaming console"],
            "category": "electronics",
            "type": "console",
            "brand": "sony"
        },
        "nintendo_switch": {
            "url": "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop",
            "keywords": ["nintendo", "switch", "nintendo switch", "handheld", "portable"],
            "category": "electronics",
            "type": "console",
            "brand": "nintendo"
        },
        "samsung_tv": {
            "url": "https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop",
            "keywords": ["samsung", "tv", "smart tv", "4k", "television"],
            "category": "electronics",
            "type": "tv",
            "brand": "samsung"
        },
        "ipad_pro": {
            "url": "https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&h=600&fit=crop",
            "keywords": ["ipad", "ipad pro", "tablet", "apple", "touch"],
            "category": "electronics",
            "type": "tablet",
            "brand": "apple"
        },
        "airpods": {
            "url": "https://images.unsplash.com/photo-1600294037681-c80b4cb5b434?w=800&h=600&fit=crop",
            "keywords": ["airpods", "apple", "wireless", "earbuds", "headphones"],
            "category": "electronics",
            "type": "audio",
            "brand": "apple"
        },
        "smartwatch": {
            "url": "https://images.unsplash.com/photo-1551816230-ef5deaed4a26?w=800&h=600&fit=crop",
            "keywords": ["smartwatch", "apple watch", "fitness", "wearable"],
            "category": "electronics",
            "type": "watch",
            "brand": "apple"
        },
        "camera_dslr": {
            "url": "https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop",
            "keywords": ["camera", "dslr", "photography", "canon", "nikon"],
            "category": "electronics",
            "type": "camera",
            "brand": "generic"
        },
        
        # APPAREL
        "leather_jacket": {
            "url": "https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop",
            "keywords": ["leather jacket", "jacket", "leather", "motorcycle", "black"],
            "category": "apparel",
            "type": "jacket"
        },
        "vintage_jeans": {
            "url": "https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop",
            "keywords": ["vintage", "jeans", "denim", "classic", "retro"],
            "category": "apparel",
            "type": "pants"
        },
        "designer_dress": {
            "url": "https://images.unsplash.com/photo-1496747611176-843222e1e57c?w=800&h=600&fit=crop",
            "keywords": ["designer", "dress", "elegant", "formal", "fashion"],
            "category": "apparel",
            "type": "dress"
        },
        "nike_sneakers": {
            "url": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=800&h=600&fit=crop",
            "keywords": ["nike", "sneakers", "shoes", "athletic", "running"],
            "category": "apparel",
            "type": "shoes",
            "brand": "nike"
        },
        "winter_coat": {
            "url": "https://images.unsplash.com/photo-1539533018447-63fcce2678e3?w=800&h=600&fit=crop",
            "keywords": ["winter coat", "coat", "warm", "puffer", "down"],
            "category": "apparel",
            "type": "coat"
        },
        "summer_dress": {
            "url": "https://images.unsplash.com/photo-1515372039744-b8f02a3ae446?w=800&h=600&fit=crop",
            "keywords": ["summer dress", "light", "casual", "sundress", "flowing"],
            "category": "apparel",
            "type": "dress"
        },
        "business_suit": {
            "url": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=600&fit=crop",
            "keywords": ["suit", "business", "formal", "professional", "blazer"],
            "category": "apparel",
            "type": "suit"
        },
        "casual_tshirt": {
            "url": "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop",
            "keywords": ["t-shirt", "casual", "cotton", "comfortable", "everyday"],
            "category": "apparel",
            "type": "shirt"
        },
        "luxury_handbag": {
            "url": "https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800&h=600&fit=crop",
            "keywords": ["handbag", "luxury", "designer", "bag", "purse"],
            "category": "apparel",
            "type": "accessory"
        },
        "hiking_boots": {
            "url": "https://images.unsplash.com/photo-1544966503-7cc5ac882d5f?w=800&h=600&fit=crop",
            "keywords": ["hiking boots", "boots", "outdoor", "sturdy", "leather"],
            "category": "apparel",
            "type": "shoes"
        }
    }

def calculate_match_score(listing_text: str, image_data: Dict) -> int:
    """Calculate a sophisticated match score between listing and image."""
    score = 0
    text_lower = listing_text.lower()
    
    # Primary keyword matching (high weight)
    for keyword in image_data["keywords"]:
        if keyword.lower() in text_lower:
            # Exact phrase match gets highest score
            if keyword.lower() == text_lower or f" {keyword.lower()} " in f" {text_lower} ":
                score += 100
            # Partial match gets medium score
            else:
                score += 50
    
    # Brand matching (very high weight for exact matches)
    if "brand" in image_data:
        brand = image_data["brand"].lower()
        if brand != "generic" and brand in text_lower:
            score += 150
    
    # Category matching (ensures basic compatibility)
    if image_data["category"] in text_lower:
        score += 25
    
    # Type matching (moderate weight)
    if "type" in image_data and image_data["type"].lower() in text_lower:
        score += 75
    
    return score

def verify_image_url(url: str) -> bool:
    """Verify that an image URL is accessible."""
    try:
        response = requests.head(url, timeout=5)
        return response.status_code == 200
    except:
        return False

def assign_perfect_images():
    """Assign perfectly matched, unique images to all listings."""
    
    print("🎯 Starting Perfect Image Matching System...")
    
    # Get all listings
    listings_ref = db.collection('listings')
    listings = listings_ref.stream()
    
    # Convert to list for processing
    all_listings = []
    for listing in listings:
        data = listing.to_dict()
        data['id'] = listing.id
        all_listings.append(data)
    
    print(f"📊 Found {len(all_listings)} listings to process")
    
    # Get image database
    image_db = create_comprehensive_image_database()
    used_images = set()
    
    # First, verify all image URLs
    print("🔍 Verifying image URLs...")
    valid_images = {}
    for img_id, img_data in image_db.items():
        if verify_image_url(img_data["url"]):
            valid_images[img_id] = img_data
        else:
            print(f"❌ Invalid URL for {img_id}: {img_data['url']}")
    
    print(f"✅ {len(valid_images)} valid images available")
    
    # Process each listing
    assignments = []
    
    for listing in all_listings:
        title = listing.get('title', '')
        description = listing.get('description', '')
        category = listing.get('category', '')
        
        # Combine title and description for matching
        combined_text = f"{title} {description} {category}"
        
        print(f"\n🔍 Processing: {title}")
        
        # Find best matches
        matches = []
        for img_id, img_data in valid_images.items():
            if img_id not in used_images:  # Only unused images
                score = calculate_match_score(combined_text, img_data)
                if score > 0:  # Only consider actual matches
                    matches.append((score, img_id, img_data))
        
        # Sort by score (highest first)
        matches.sort(reverse=True, key=lambda x: x[0])
        
        if matches:
            score, best_img_id, best_img_data = matches[0]
            used_images.add(best_img_id)
            
            assignments.append({
                'listing_id': listing['id'],
                'title': title,
                'image_id': best_img_id,
                'image_url': best_img_data['url'],
                'score': score,
                'keywords_matched': [kw for kw in best_img_data['keywords'] if kw.lower() in combined_text.lower()]
            })
            
            print(f"  ✅ Matched with: {best_img_id} (score: {score})")
            print(f"     Keywords matched: {[kw for kw in best_img_data['keywords'] if kw.lower() in combined_text.lower()]}")
        else:
            print(f"  ❌ No suitable matches found")
    
    print(f"\n📈 Assignment Summary:")
    print(f"  Total listings: {len(all_listings)}")
    print(f"  Successfully matched: {len(assignments)}")
    print(f"  Unique images used: {len(used_images)}")
    print(f"  Uniqueness rate: {len(used_images)/len(assignments)*100:.1f}%")
    
    # Apply assignments to Firestore
    print(f"\n💾 Applying assignments to Firestore...")
    
    for assignment in assignments:
        try:
            listing_ref = db.collection('listings').document(assignment['listing_id'])
            listing_ref.update({
                'images': [assignment['image_url']]
            })
            print(f"  ✅ Updated {assignment['title']}")
            
        except Exception as e:
            print(f"  ❌ Failed to update {assignment['title']}: {e}")
    
    print(f"\n🎉 Perfect image matching complete!")
    print(f"📊 Final stats:")
    print(f"  - {len(assignments)} listings updated")
    print(f"  - 100% unique images")
    print(f"  - Content-specific matching")
    
    # Print detailed results
    print(f"\n📋 Detailed Results:")
    for assignment in sorted(assignments, key=lambda x: x['score'], reverse=True):
        print(f"  {assignment['title'][:40]:<40} → {assignment['image_id']:<20} (score: {assignment['score']})")

if __name__ == "__main__":
    assign_perfect_images()
