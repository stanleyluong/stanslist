#!/usr/bin/env python3
"""
Refined smart image matching with better keyword prioritization and conflict resolution.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
import re

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

def get_refined_image_mapping():
    """Get refined keyword to image mapping with priority-based matching"""
    return {
        # VEHICLES - Brand/Model specific (high priority)
        'bmw 3 series': ('https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&h=600&fit=crop', 10),
        'bmw': ('https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&h=600&fit=crop', 8),
        'ford f-150': ('https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop', 10),
        'f-150': ('https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop', 9),
        'pickup truck': ('https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop', 8),
        'honda civic': ('https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop', 10),
        'civic': ('https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop', 9),
        'honda': ('https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop', 7),
        'tesla model 3': ('https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop', 10),
        'tesla': ('https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop', 8),
        'model 3': ('https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop', 8),
        'jeep wrangler': ('https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=800&h=600&fit=crop', 10),
        'wrangler': ('https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=800&h=600&fit=crop', 9),
        'jeep': ('https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=800&h=600&fit=crop', 8),
        'mazda cx-5': ('https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop', 10),
        'cx-5': ('https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop', 9),
        'mazda': ('https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop', 7),
        'nissan altima': ('https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop', 10),
        'altima': ('https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop', 9),
        'nissan': ('https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop', 7),
        'hyundai elantra': ('https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&h=600&fit=crop', 10),
        'elantra': ('https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&h=600&fit=crop', 9),
        'hyundai': ('https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&h=600&fit=crop', 7),
        'subaru outback': ('https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&h=600&fit=crop', 10),
        'outback': ('https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&h=600&fit=crop', 9),
        'subaru': ('https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&h=600&fit=crop', 7),
        'toyota camry': ('https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=800&h=600&fit=crop', 10),
        'camry': ('https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=800&h=600&fit=crop', 9),
        'toyota': ('https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=800&h=600&fit=crop', 7),
        'cybertruck': ('https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&h=600&fit=crop', 10),
        
        # ELECTRONICS - Device specific (high priority)
        'playstation 5': ('https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=800&h=600&fit=crop', 10),
        'ps5': ('https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=800&h=600&fit=crop', 10),
        'playstation': ('https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=800&h=600&fit=crop', 8),
        'macbook air': ('https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop', 10),
        'macbook': ('https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop', 9),
        'gaming pc': ('https://images.unsplash.com/photo-1587831990711-23ca6441447b?w=800&h=600&fit=crop', 10),
        'rtx 3070': ('https://images.unsplash.com/photo-1587831990711-23ca6441447b?w=800&h=600&fit=crop', 9),
        'canon eos': ('https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop', 10),
        'canon': ('https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop', 8),
        'camera': ('https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop', 7),
        'airpods pro': ('https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=800&h=600&fit=crop', 10),
        'airpods': ('https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=800&h=600&fit=crop', 9),
        'iphone 13': ('https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=800&h=600&fit=crop', 10),
        'iphone': ('https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=800&h=600&fit=crop', 8),
        'nintendo switch': ('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop', 10),
        'switch': ('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop', 8),
        'nintendo': ('https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop', 7),
        'samsung tv': ('https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop', 10),
        'samsung': ('https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop', 7),
        'smart tv': ('https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop', 8),
        'ipad pro': ('https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&h=600&fit=crop', 10),
        'ipad': ('https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&h=600&fit=crop', 8),
        'dell monitor': ('https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&h=600&fit=crop', 10),
        'dell': ('https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&h=600&fit=crop', 8),
        'monitor': ('https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&h=600&fit=crop', 7),
        
        # APPAREL - Item specific (high priority)
        "levi's 501": ('https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop', 10),
        'levi': ('https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop', 8),
        'jeans': ('https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop', 7),
        'north face': ('https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop', 10),
        'puffer jacket': ('https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop', 9),
        'air jordan': ('https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop', 10),
        'nike': ('https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop', 8),
        'jordan': ('https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop', 8),
        'beatles': ('https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop', 10),
        't-shirt': ('https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop', 7),
        'carhartt': ('https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800&h=600&fit=crop', 10),
        'work jacket': ('https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800&h=600&fit=crop', 9),
        'lululemon': ('https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&h=600&fit=crop', 10),
        'leggings': ('https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&h=600&fit=crop', 8),
        'dress shirt': ('https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=600&fit=crop', 10),
        'formal': ('https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=600&fit=crop', 7),
        'supreme': ('https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&h=600&fit=crop', 10),
        'hoodie': ('https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&h=600&fit=crop', 8),
        'adidas ultraboost': ('https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop', 10),
        'ultraboost': ('https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop', 9),
        'adidas': ('https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop', 8),
        'patagonia': ('https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop', 10),
        'fleece vest': ('https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop', 9),
        
        # PROPERTY RENTALS - Type specific (high priority)
        'beachfront': ('https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop', 10),
        'vacation rental': ('https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop', 9),
        'family home': ('https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop', 10),
        'suburban': ('https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop', 8),
        'converted loft': ('https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop', 10),
        'artist space': ('https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop', 9),
        'loft': ('https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop', 8),
        'shared house': ('https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&h=600&fit=crop', 10),
        'room available': ('https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&h=600&fit=crop', 9),
        'luxury condo': ('https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop', 10),
        'high rise': ('https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop', 9),
        'condo': ('https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop', 8),
        'tiny house': ('https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop', 10),
        'minimalist': ('https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop', 8),
        'modern house': ('https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&h=600&fit=crop', 10),
        'with yard': ('https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&h=600&fit=crop', 9),
        'studio': ('https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop', 9),
        'apartment downtown': ('https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop', 10),
        'downtown': ('https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop', 8),
        'garden apartment': ('https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop', 10),
        'charming': ('https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop', 7),
        
        # OTHER CATEGORIES
        'road rocks': ('https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop', 10),
        'fairy garden': ('https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=800&h=600&fit=crop', 10),
        'cat toy': ('https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=800&h=600&fit=crop', 10),
    }

def find_best_matching_image_refined(title, description, keyword_map):
    """Find the best matching image with priority-based selection"""
    text = f"{title} {description}".lower()
    
    best_match = None
    best_priority = 0
    best_keyword = None
    
    # Look for matches and select the one with highest priority
    for keyword, (image_url, priority) in keyword_map.items():
        if keyword in text:
            if priority > best_priority:
                best_match = image_url
                best_priority = priority
                best_keyword = keyword
    
    return best_match, best_keyword, best_priority

def refined_smart_assign_images():
    """Refined intelligent image assignment with better matching"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        keyword_map = get_refined_image_mapping()
        updated_count = 0
        matched_count = 0
        
        print(f"📊 Processing {len(docs)} listings with refined matching...")
        
        for doc in docs:
            data = doc.to_dict()
            title = data.get('title', '')
            description = data.get('description', '')
            category = data.get('category', '')
            
            # Find best matching image with priority
            best_image, matched_keyword, priority = find_best_matching_image_refined(title, description, keyword_map)
            
            if best_image:
                # Update the listing with the matched image
                doc.reference.update({
                    'images': [best_image]
                })
                
                print(f"✅ {category.upper()}: {title}")
                print(f"   Matched: '{matched_keyword}' (priority: {priority})")
                print()
                
                matched_count += 1
            else:
                print(f"⚠️  {category.upper()}: {title}")
                print(f"   No specific match found")
                print()
            
            updated_count += 1
        
        print(f"\n🎉 Refined matching complete!")
        print(f"Total listings processed: {updated_count}")
        print(f"Listings with specific matches: {matched_count}")
        print(f"Match rate: {(matched_count/updated_count)*100:.1f}%")
        
    except Exception as e:
        print(f"❌ Error in refined smart image assignment: {e}")

if __name__ == "__main__":
    refined_smart_assign_images()
