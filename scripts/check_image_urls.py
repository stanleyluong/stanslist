#!/usr/bin/env python3
"""
Check all image URLs currently being used in listings to identify duplicates.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
from collections import Counter

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

def check_image_urls():
    """Check all image URLs in listings"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        print(f"📊 Found {len(docs)} total listings")
        
        # Collect all image URLs
        all_image_urls = []
        listings_by_category = {}
        
        for doc in docs:
            data = doc.to_dict()
            images = data.get('images', [])
            category = data.get('category', 'unknown')
            title = data.get('title', 'No title')
            
            if category not in listings_by_category:
                listings_by_category[category] = []
            
            listings_by_category[category].append({
                'id': doc.id,
                'title': title,
                'images': images
            })
            
            all_image_urls.extend(images)
        
        # Count duplicate URLs
        url_counts = Counter(all_image_urls)
        duplicates = {url: count for url, count in url_counts.items() if count > 1}
        
        print(f"\n🔍 Image URL Analysis:")
        print(f"Total images: {len(all_image_urls)}")
        print(f"Unique images: {len(url_counts)}")
        print(f"Duplicate URLs: {len(duplicates)}")
        
        if duplicates:
            print(f"\n📋 Most repeated images:")
            for url, count in sorted(duplicates.items(), key=lambda x: x[1], reverse=True):
                print(f"  Used {count} times: {url}")
        
        print(f"\n📂 Listings by category:")
        for category, listings in listings_by_category.items():
            print(f"\n{category.upper()} ({len(listings)} listings):")
            for listing in listings:
                images_str = ', '.join(listing['images']) if listing['images'] else 'No images'
                print(f"  • {listing['title']}: {images_str}")
        
    except Exception as e:
        print(f"❌ Error checking image URLs: {e}")

if __name__ == "__main__":
    check_image_urls()
