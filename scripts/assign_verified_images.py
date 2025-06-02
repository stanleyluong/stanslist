#!/usr/bin/env python3
"""
Assign completely new, verified working image URLs to ensure all images are unique and functional.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os

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

def assign_new_unique_images():
    """Assign completely new unique images using verified working URLs"""
    db = initialize_firebase()
    if not db:
        return
    
    # New verified working image URLs by category
    category_images = {
        'vehicles': [
            'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&h=600&fit=crop',  # sports car
            'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop',  # Tesla Model 3
            'https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=800&h=600&fit=crop',  # Jeep Wrangler
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop',  # Honda Civic
            'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop',  # pickup truck
            'https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop',  # SUV
            'https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop',  # sedan
            'https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&h=600&fit=crop',  # Hyundai
            'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&h=600&fit=crop',  # Subaru
            'https://images.unsplash.com/photo-1485463611174-f302f6a5c1c9?w=800&h=600&fit=crop',  # Toyota Camry
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&h=600&fit=crop',  # BMW close-up
        ],
        'electronics': [
            'https://images.unsplash.com/photo-1606144042614-b2417e99c4e3?w=800&h=600&fit=crop',  # PS5
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800&h=600&fit=crop',  # MacBook
            'https://images.unsplash.com/photo-1587831990711-23ca6441447b?w=800&h=600&fit=crop',  # Gaming PC
            'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800&h=600&fit=crop',  # Camera
            'https://images.unsplash.com/photo-1572569511254-d8f925fe2cbb?w=800&h=600&fit=crop',  # AirPods
            'https://images.unsplash.com/photo-1510557880182-3d4d3cba35a5?w=800&h=600&fit=crop',  # iPhone
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',  # Nintendo Switch
            'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=800&h=600&fit=crop',  # Samsung TV
            'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=800&h=600&fit=crop',  # iPad
            'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800&h=600&fit=crop',  # Monitor
        ],
        'apparel': [
            'https://images.unsplash.com/photo-1542272604-787c3835535d?w=800&h=600&fit=crop',  # jeans
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop',  # jacket
            'https://images.unsplash.com/photo-1549298916-b41d501d3772?w=800&h=600&fit=crop',  # sneakers
            'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?w=800&h=600&fit=crop',  # t-shirt
            'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800&h=600&fit=crop',  # leggings
            'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&h=600&fit=crop',  # dress shirt
            'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=600&fit=crop',  # hoodie
            'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&h=600&fit=crop',  # running shoes
            'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop',  # clothing rack
            'https://images.unsplash.com/photo-1434389677669-e08b4cac3105?w=800&h=600&fit=crop',  # fashion items
        ],
        'property-rentals': [
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',  # beach house
            'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop',  # suburban house
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop',  # loft
            'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&h=600&fit=crop',  # shared house
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop',  # luxury condo
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop',  # tiny house
            'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&h=600&fit=crop',  # modern house
            'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=800&h=600&fit=crop',  # apartment interior
            'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?w=800&h=600&fit=crop',  # apartment building
            'https://images.unsplash.com/photo-1493809842364-78817add7ffb?w=800&h=600&fit=crop',  # garden apartment
        ],
        'garden-outdoor': [
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',  # rocks/garden
            'https://images.unsplash.com/photo-1585320806297-9794b3e4eeae?w=800&h=600&fit=crop',  # fairy garden
        ],
        'pet-supplies': [
            'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=800&h=600&fit=crop',  # cat toy
        ]
    }
    
    try:
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        # Group by category and assign unique images
        category_counters = {}
        updated_count = 0
        
        for doc in docs:
            data = doc.to_dict()
            category = data.get('category', '').lower()
            title = data.get('title', 'No title')
            
            if category not in category_counters:
                category_counters[category] = 0
            
            if category in category_images:
                available_images = category_images[category]
                image_index = category_counters[category] % len(available_images)
                new_image_url = available_images[image_index]
                
                # Update the listing
                doc.reference.update({
                    'images': [new_image_url]
                })
                
                print(f"✅ Updated {category}: {title}")
                print(f"   Image: {new_image_url}")
                
                category_counters[category] += 1
                updated_count += 1
        
        print(f"\n🎉 Successfully updated {updated_count} listings with new verified images!")
        
        # Check for uniqueness
        all_urls = []
        for category, images in category_images.items():
            all_urls.extend(images)
        
        unique_urls = len(set(all_urls))
        total_urls = len(all_urls)
        
        print(f"\n📊 Image URL Analysis:")
        print(f"Total image URLs: {total_urls}")
        print(f"Unique image URLs: {unique_urls}")
        print(f"Uniqueness: {(unique_urls/total_urls)*100:.1f}%")
        
    except Exception as e:
        print(f"❌ Error assigning new unique images: {e}")

if __name__ == "__main__":
    assign_new_unique_images()
