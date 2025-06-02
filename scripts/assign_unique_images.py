#!/usr/bin/env python3
"""
Update all listings with unique, category-appropriate images from Unsplash.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
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

def get_category_images():
    """Get category-specific image pools from Unsplash"""
    return {
        'vehicles': [
            'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&h=600&fit=crop',  # sports car
            'https://images.unsplash.com/photo-1580414155951-390bb5ad3d16?w=800&h=600&fit=crop',  # BMW
            'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop',  # Tesla
            'https://images.unsplash.com/photo-1565043589221-1a6fd9ae45c7?w=800&h=600&fit=crop',  # Jeep
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=800&h=600&fit=crop',  # Honda Civic
            'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&h=600&fit=crop',  # pickup truck
            'https://images.unsplash.com/photo-1561134643-668f9057cce4?w=800&h=600&fit=crop',  # SUV
            'https://images.unsplash.com/photo-1551830820-330a71b99659?w=800&h=600&fit=crop',  # sedan
            'https://images.unsplash.com/photo-1542362567-b07e54358753?w=800&h=600&fit=crop',  # Hyundai
            'https://images.unsplash.com/photo-1558317374-067fb5f30001?w=800&h=600&fit=crop',  # Subaru
            'https://images.unsplash.com/photo-1549399105-8a7e038696ab?w=800&h=600&fit=crop',  # Toyota
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
            'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=800&h=600&fit=crop',  # work jacket
            'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800&h=600&fit=crop',  # leggings
            'https://images.unsplash.com/photo-1562157873-818bc0726f68?w=800&h=600&fit=crop',  # dress shirt
            'https://images.unsplash.com/photo-1556821840-3a63f95609a7?w=800&h=600&fit=crop',  # hoodie
            'https://images.unsplash.com/photo-1595950653106-6c9ebd614d3a?w=800&h=600&fit=crop',  # running shoes
            'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=600&fit=crop',  # fleece vest
        ],
        'property-rentals': [
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',  # beach house
            'https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800&h=600&fit=crop',  # suburban house
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop',  # loft
            'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&h=600&fit=crop',  # shared house
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop',  # luxury condo
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=600&fit=crop',  # tiny house
            'https://images.unsplash.com/photo-1570129477492-45c003edd2be?w=800&h=600&fit=crop',  # modern house
            'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=800&h=600&fit=crop',  # studio
            'https://images.unsplash.com/photo-1545324418-cc1a3fa10c00?w=800&h=600&fit=crop',  # apartment
            'https://images.unsplash.com/photo-1567496898669-ee935f5317a7?w=800&h=600&fit=crop',  # garden apartment
        ],
        'garden-outdoor': [
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',  # rocks
            'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?w=800&h=600&fit=crop',  # fairy garden
        ],
        'pet-supplies': [
            'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?w=800&h=600&fit=crop',  # cat toy
        ]
    }

def assign_unique_images():
    """Assign unique images to all listings based on their category"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        # Get all listings
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        print(f"📊 Found {len(docs)} listings to update")
        
        category_images = get_category_images()
        category_counters = {}
        updated_count = 0
        
        for doc in docs:
            data = doc.to_dict()
            category = data.get('category', '').lower()
            title = data.get('title', 'No title')
            
            # Initialize counter for this category
            if category not in category_counters:
                category_counters[category] = 0
            
            # Get category-specific images
            if category in category_images:
                available_images = category_images[category]
                
                # Use round-robin assignment to ensure variety
                image_index = category_counters[category] % len(available_images)
                new_image_url = available_images[image_index]
                
                # Update the listing with new image
                doc.reference.update({
                    'images': [new_image_url]
                })
                
                print(f"✅ Updated {category}: {title}")
                print(f"   New image: {new_image_url}")
                
                category_counters[category] += 1
                updated_count += 1
            else:
                print(f"⚠️  No images defined for category: {category}")
        
        print(f"\n🎉 Successfully updated {updated_count} listings with unique images!")
        
        # Show summary
        print(f"\n📋 Summary by category:")
        for category, count in category_counters.items():
            print(f"  {category}: {count} listings updated")
        
    except Exception as e:
        print(f"❌ Error assigning unique images: {e}")

if __name__ == "__main__":
    assign_unique_images()
