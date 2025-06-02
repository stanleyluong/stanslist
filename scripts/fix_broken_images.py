#!/usr/bin/env python3
"""
Fix broken Unsplash image URLs that are returning 404 errors.
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

def fix_broken_image_urls():
    """Fix specific broken Unsplash URLs with working alternatives"""
    db = initialize_firebase()
    if not db:
        return
    
    # Map of broken URLs to working replacements
    url_fixes = {
        'https://images.unsplash.com/photo-1580414155951-390bb5ad3d16?w=800&h=600&fit=crop': 
            'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&h=600&fit=crop',  # BMW/sports car
        'https://images.unsplash.com/photo-1549399105-8a7e038696ab?w=800&h=600&fit=crop': 
            'https://images.unsplash.com/photo-1621007947382-bb3c3994e3fb?w=800&h=600&fit=crop',  # Tesla/electric car
        'https://images.unsplash.com/photo-1567496898669-ee935f5317a7?w=800&h=600&fit=crop': 
            'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800&h=600&fit=crop',  # Garden apartment
    }
    
    try:
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        updated_count = 0
        
        for doc in docs:
            data = doc.to_dict()
            images = data.get('images', [])
            title = data.get('title', 'No title')
            
            # Check if any images need fixing
            updated_images = []
            needs_update = False
            
            for image_url in images:
                if image_url in url_fixes:
                    updated_images.append(url_fixes[image_url])
                    needs_update = True
                    print(f"🔧 Fixing broken image for: {title}")
                    print(f"   Old: {image_url}")
                    print(f"   New: {url_fixes[image_url]}")
                else:
                    updated_images.append(image_url)
            
            if needs_update:
                doc.reference.update({'images': updated_images})
                updated_count += 1
        
        print(f"\n✅ Fixed {updated_count} listings with broken image URLs")
        
    except Exception as e:
        print(f"❌ Error fixing broken image URLs: {e}")

if __name__ == "__main__":
    fix_broken_image_urls()
