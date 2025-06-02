#!/usr/bin/env python3
"""
Check users collection to see what user data exists.
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

def check_users():
    """Check users in the database"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        print("👥 Fetching all users...")
        
        users_ref = db.collection('users')
        docs = list(users_ref.stream())
        
        print(f"👥 Total users: {len(docs)}")
        
        for doc in docs:
            data = doc.to_dict()
            print(f"  {doc.id}: {data.get('name', 'No name')} ({data.get('email', 'No email')})")
        
        # Now check listings and their user references
        print("\n📋 Checking listing user references...")
        listings_ref = db.collection('listings')
        listing_docs = list(listings_ref.stream())
        
        user_ids_in_users = set(doc.id for doc in docs)
        user_ids_in_listings = set()
        
        for listing_doc in listing_docs:
            listing_data = listing_doc.to_dict()
            user_id = listing_data.get('userId')
            if user_id:
                user_ids_in_listings.add(user_id)
        
        print(f"User IDs in users collection: {user_ids_in_users}")
        print(f"User IDs referenced in listings: {user_ids_in_listings}")
        
        missing_users = user_ids_in_listings - user_ids_in_users
        if missing_users:
            print(f"❌ Missing users (referenced in listings but not in users collection): {missing_users}")
        else:
            print("✅ All listing user references are valid")
        
    except Exception as e:
        print(f"❌ Error checking users: {e}")

if __name__ == "__main__":
    check_users()
