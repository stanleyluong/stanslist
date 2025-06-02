#!/usr/bin/env python3
"""
Fix image URLs for fake listings by replacing Firebase Storage URLs with working placeholder images.
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

def get_placeholder_url(category):
    """Get a working placeholder image URL based on category"""
    placeholder_urls = {
        'vehicles': 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=800&h=600&fit=crop',
        'property-rentals': 'https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=800&h=600&fit=crop',
        'electronics': 'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=800&h=600&fit=crop',
        'apparel': 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&h=600&fit=crop'
    }
    return placeholder_urls.get(category, 'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=600&fit=crop')

def fix_image_urls():
    """Update all fake listings to use working placeholder images"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        # Get all listings
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        # Real listing IDs to preserve (these have working images)
        real_listing_ids = [
            'NTR4VcEJfzNSIhUWY4Px',
            'iwGzx2G4FGp8uDlXiLFk', 
            '2uqP2z2KFjKbEhvnYUu3',
            'KrLMbR0G8YfkHSkZEGOi'
        ]
        
        updated_count = 0
        
        for doc in docs:
            # Skip real listings
            if doc.id in real_listing_ids:
                print(f"⏭️  Skipping real listing: {doc.id}")
                continue
                
            data = doc.to_dict()
            images = data.get('images', [])
            category = data.get('category', '')
            
            # Check if this has Firebase Storage URLs that are failing
            if images and any('firebasestorage.googleapis.com' in img for img in images):
                new_url = get_placeholder_url(category)
                
                # Update the document with new placeholder image
                doc.reference.update({
                    'images': [new_url]
                })
                
                print(f"✅ Updated listing {doc.id} ({category}) - new image URL: {new_url}")
                updated_count += 1
        
        print(f"\n🎉 Successfully updated {updated_count} fake listings with working placeholder images!")
        
    except Exception as e:
        print(f"❌ Error fixing image URLs: {e}")

if __name__ == "__main__":
    print("🔧 Fixing image URLs for fake listings...")
    fix_image_urls()
