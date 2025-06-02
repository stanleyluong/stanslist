#!/usr/bin/env python3
"""
Debug script to find null values in fake listings that might be causing Flutter errors.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        service_account_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
        
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

def debug_null_values():
    """Check for null values in fake listings"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        listings_ref = db.collection('listings')
        docs = list(listings_ref.stream())
        
        # IDs of listings that should be preserved
        keep_listings = [
            'eJcyzgfMmfM2eLEmeK62',
            'qBK9kYmhiYiom99DkluB', 
            'sNzIfzKXAkpySLNVnUCC',
            'tdDUoLaNAozUyTriLX3r'
        ]
        
        print("🔍 Checking for null values in fake listings...")
        
        for doc in docs[:3]:  # Check first 3 docs
            if doc.id not in keep_listings:  # Only check fake listings
                print(f"\n📄 Checking fake listing: {doc.id}")
                data = doc.to_dict()
                
                for key, value in data.items():
                    if value is None:
                        print(f"  ❌ NULL VALUE: {key} = None")
                    elif isinstance(value, list):
                        if not value:
                            print(f"  ⚠️  EMPTY LIST: {key} = []")
                        elif any(item is None for item in value):
                            print(f"  ❌ NULL IN LIST: {key} contains None values")
                        else:
                            print(f"  ✅ {key}: list with {len(value)} items")
                    elif isinstance(value, dict):
                        if any(v is None for v in value.values()):
                            print(f"  ❌ NULL IN DICT: {key} contains None values")
                        else:
                            print(f"  ✅ {key}: dict with {len(value)} keys")
                    elif isinstance(value, str):
                        if value == "":
                            print(f"  ⚠️  EMPTY STRING: {key} = ''")
                        else:
                            print(f"  ✅ {key}: '{value[:50]}{'...' if len(value) > 50 else ''}'")
                    else:
                        print(f"  ✅ {key}: {type(value).__name__} = {value}")
                
                # Check image URLs specifically
                if 'images' in data and data['images']:
                    print(f"  🖼️  Image URL: {data['images'][0]}")
                    has_token = 'token=' in data['images'][0]
                    print(f"  🔑 Has token: {has_token}")
                    if not has_token:
                        print(f"  ❌ MISSING TOKEN in image URL!")
                
                break  # Just check one fake listing
        
    except Exception as e:
        print(f"❌ Error debugging listings: {e}")

if __name__ == "__main__":
    debug_null_values()
