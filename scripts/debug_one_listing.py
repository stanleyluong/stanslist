#!/usr/bin/env python3
"""
Check the exact structure of one fake listing to identify null values.
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

def debug_one_listing():
    """Get one fake listing and print its exact structure"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        # Get just one fake listing
        listings_ref = db.collection('listings')
        docs = list(listings_ref.limit(1).stream())
        
        if not docs:
            print("❌ No listings found")
            return
            
        doc = docs[0]
        data = doc.to_dict()
        
        print(f"📄 Document ID: {doc.id}")
        print(f"📄 Raw data structure:")
        print(json.dumps(data, indent=2, default=str))
        
        # Check specific fields that might be problematic
        problematic_fields = ['title', 'description', 'category', 'userId', 'location', 'contactEmail', 'datePosted', 'createdAt']
        
        print(f"\n🔍 Checking specific fields:")
        for field in problematic_fields:
            value = data.get(field)
            print(f"  {field}: {type(value).__name__} = {repr(value)}")
        
    except Exception as e:
        print(f"❌ Error debugging listing: {e}")

if __name__ == "__main__":
    debug_one_listing()
