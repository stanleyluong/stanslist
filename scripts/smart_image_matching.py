#!/usr/bin/env python3
"""
Intelligently match images to listings based on their titles and descriptions.
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

def get_smart_image_mapping():
    """Map specific keywords to appropriate images"""
    return {
        # Vehicles - Brand/Model specific
        'bmw': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&h=600&fit=crop',
        'ford': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop',
        'pickup': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop',
        'f-150': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop',
        'honda': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop',
        'civic': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop',
        'tesla': 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop',
        'model 3': 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop',
        'electric': 'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop',
        'jeep': 'https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=800&h=600&fit=crop',
        'wrangler': 'https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=800&h=600&fit=crop',
        'mazda': 'https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop',
        'cx-5': 'https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop',
        'suv': 'https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop',
        'nissan': 'https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop',
        'altima': 'https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop',
        'sedan': 'https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop',
        'hyundai': 'https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&h=600&fit=crop',
        'elantra': 'https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&h=600&fit=crop',
        'subaru': 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&h=600&fit=crop',
        'outback': 'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&h=600&fit=crop',
        'toyota': 'https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=800&h=600&fit=crop',
        'camry': 'https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=800&h=600&fit=crop',
        'hybrid': 'https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=800&h=600&fit=crop',
        'cybertruck': 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&h=600&fit=crop',
        
        # Electronics - Device specific
        'playstation': 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=800&h=600&fit=crop',
        'ps5': 'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=800&h=600&fit=crop',
        'macbook': 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop',
        'gaming pc': 'https://images.unsplash.com/photo-1587831990711-23ca6441447b?w=800&h=600&fit=crop',
        'rtx': 'https://images.unsplash.com/photo-1587831990711-23ca6441447b?w=800&h=600&fit=crop',
        'canon': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop',
        'camera': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop',
        'eos': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop',
        'airpods': 'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=800&h=600&fit=crop',
        'iphone': 'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=800&h=600&fit=crop',
        'nintendo': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
        'switch': 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',
        'samsung': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop',
        'tv': 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop',
        'ipad': 'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&h=600&fit=crop',
        'dell': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&h=600&fit=crop',
        'monitor': 'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&h=600&fit=crop',
        
        # Apparel - Item specific
        'jeans': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop',
        'levi': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop',
        '501': 'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop',
        'jacket': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop',
        'north face': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop',
        'puffer': 'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop',
        'nike': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop',
        'jordan': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop',
        'sneakers': 'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop',
        't-shirt': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop',
        'beatles': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop',
        'vintage': 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop',
        'carhartt': 'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800&h=600&fit=crop',
        'work': 'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800&h=600&fit=crop',
        'lululemon': 'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&h=600&fit=crop',
        'leggings': 'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&h=600&fit=crop',
        'dress shirt': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=600&fit=crop',
        'formal': 'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=600&fit=crop',
        'supreme': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&h=600&fit=crop',
        'hoodie': 'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&h=600&fit=crop',
        'adidas': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop',
        'ultraboost': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop',
        'running': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop',
        'patagonia': 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop',
        'fleece': 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop',
        'vest': 'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop',
        
        # Property rentals - Type specific
        'beach': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
        'vacation': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',
        'family home': 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop',
        'suburban': 'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop',
        'loft': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop',
        'artist': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop',
        'converted': 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop',
        'shared': 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&h=600&fit=crop',
        'room': 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&h=600&fit=crop',
        'luxury': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop',
        'condo': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop',
        'high rise': 'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop',
        'tiny house': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop',
        'minimalist': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop',
        'modern': 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&h=600&fit=crop',
        'yard': 'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&h=600&fit=crop',
        'studio': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop',
        'students': 'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop',
        'apartment': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop',
        'downtown': 'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop',
        'garden': 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop',
        'charming': 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop',
        
        # Other categories
        'rocks': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',
        'road': 'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',
        'fairy': 'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=800&h=600&fit=crop',
        'cat': 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=800&h=600&fit=crop',
        'toy': 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=800&h=600&fit=crop',
    }

def find_best_matching_image(title, description, keyword_map):
    """Find the best matching image based on title and description content"""
    # Combine title and description for searching
    text = f"{title} {description}".lower()
    
    # Look for exact matches first (more specific keywords)
    for keyword, image_url in keyword_map.items():
        if keyword in text:
            return image_url, keyword
    
    # If no match found, return None
    return None, None

def smart_assign_images():
    """Intelligently assign images based on listing content"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        keyword_map = get_smart_image_mapping()
        updated_count = 0
        matched_count = 0
        
        print(f"📊 Processing {len(docs)} listings...")
        
        for doc in docs:
            data = doc.to_dict()
            title = data.get('title', '')
            description = data.get('description', '')
            category = data.get('category', '')
            
            # Find best matching image
            best_image, matched_keyword = find_best_matching_image(title, description, keyword_map)
            
            if best_image:
                # Update the listing with the matched image
                doc.reference.update({
                    'images': [best_image]
                })
                
                print(f"✅ {category.upper()}: {title}")
                print(f"   Matched keyword: '{matched_keyword}'")
                print(f"   Image: {best_image}")
                print()
                
                matched_count += 1
            else:
                print(f"⚠️  {category.upper()}: {title}")
                print(f"   No specific match found")
                print()
            
            updated_count += 1
        
        print(f"\n🎉 Processing complete!")
        print(f"Total listings processed: {updated_count}")
        print(f"Listings with specific matches: {matched_count}")
        print(f"Match rate: {(matched_count/updated_count)*100:.1f}%")
        
    except Exception as e:
        print(f"❌ Error in smart image assignment: {e}")

if __name__ == "__main__":
    smart_assign_images()
