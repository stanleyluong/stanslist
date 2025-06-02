#!/usr/bin/env python3
"""
Debug script to examine the exact data structure of listings to identify the null casting issue.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
import json

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

def debug_listing_data():
    """Examine detailed data structure of listings"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        print("🔍 Analyzing listing data structure...")
        
        # Get a few different listings to compare
        listings_ref = db.collection('listings')
        docs = list(listings_ref.limit(5).stream())
        
        preserve_ids = [
            'eJcyzgfMmfM2eLEmeK62',
            'qBK9kYmhiYiom99DkluB', 
            'sNzIfzKXAkpySLNVnUCC',
            'tdDUoLaNAozUyTriLX3r'
        ]
        
        # Also get one of the preserved listings
        if preserve_ids:
            preserved_doc = db.collection('listings').document(preserve_ids[0]).get()
            if preserved_doc.exists:
                docs.append(preserved_doc)
        
        for i, doc in enumerate(docs):
            data = doc.to_dict()
            print(f"\n{'='*50}")
            print(f"Listing {i+1}: {doc.id}")
            print(f"Is preserved: {'YES' if doc.id in preserve_ids else 'NO'}")
            print(f"{'='*50}")
            
            # Check for null values and types
            for key, value in data.items():
                value_type = type(value).__name__
                is_null = value is None
                print(f"  {key}: {value_type} = {value if not is_null else 'NULL'}")
                
                if is_null:
                    print(f"    ⚠️  NULL VALUE DETECTED in {key}")
            
            # Pretty print the entire data structure
            print("\n📄 Full data structure:")
            print(json.dumps(data, indent=2, default=str))
        
        print(f"\n🔍 Summary: Analyzed {len(docs)} listings")
        
    except Exception as e:
        print(f"❌ Error debugging listing data: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    debug_listing_data()
