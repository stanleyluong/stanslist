#!/usr/bin/env python3
"""
Verification script to check the current state of listings in the database.
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

def verify_listings():
    """Check current listings in database"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        print("📊 Fetching all listings...")
        
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        print(f"📊 Total listings: {len(docs)}")
        
        # Count by category
        categories = Counter()
        preserved_listings = []
        
        # IDs of listings that should be preserved
        keep_listings = [
            'eJcyzgfMmfM2eLEmeK62',
            'qBK9kYmhiYiom99DkluB', 
            'sNzIfzKXAkpySLNVnUCC',
            'tdDUoLaNAozUyTriLX3r'
        ]
        
        for doc in docs:
            data = doc.to_dict()
            category = data.get('category', 'unknown')
            categories[category] += 1
            
            if doc.id in keep_listings:
                preserved_listings.append({
                    'id': doc.id,
                    'title': data.get('title', 'No title'),
                    'category': category
                })
        
        print("\n📈 Listings by category:")
        for category, count in categories.items():
            print(f"  {category}: {count}")
        
        print(f"\n🔒 Preserved real listings ({len(preserved_listings)}):")
        for listing in preserved_listings:
            print(f"  {listing['id']}: {listing['title']} ({listing['category']})")
        
        # Sample some new listings
        print(f"\n📝 Sample of recent listings:")
        sample_docs = docs[:5]  # First 5 listings
        for doc in sample_docs:
            data = doc.to_dict()
            print(f"  {doc.id}: {data.get('title', 'No title')} ({data.get('category', 'unknown')})")
            if 'images' in data and data['images']:
                print(f"    Image URL: {data['images'][0]}")
                # Check if URL has token
                has_token = 'token=' in data['images'][0]
                print(f"    Has token: {has_token}")
        
        # Check one fake listing data structure in detail
        fake_listing = None
        for doc in docs:
            if doc.id not in keep_listings:
                fake_listing = doc
                break
        
        if fake_listing:
            print(f"\n🔍 Detailed fake listing data structure:")
            fake_data = fake_listing.to_dict()
            for key, value in fake_data.items():
                print(f"  {key}: {type(value).__name__} = {value}")
                # Check for None values that might cause the null error
                if value is None:
                    print(f"    ⚠️  NULL VALUE FOUND in {key}")
                elif isinstance(value, list) and any(item is None for item in value):
                    print(f"    ⚠️  NULL VALUE IN LIST FOUND in {key}")
                elif isinstance(value, dict) and any(v is None for v in value.values()):
                    print(f"    ⚠️  NULL VALUE IN DICT FOUND in {key}")
        
    except Exception as e:
        print(f"❌ Error verifying listings: {e}")

if __name__ == "__main__":
    verify_listings()
