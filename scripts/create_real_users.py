#!/usr/bin/env python3
"""
Create user records for the real user IDs that are missing.
"""

import firebase_admin
from firebase_admin import credentials, firestore
import os
from datetime import datetime

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

def create_real_users():
    """Create user records for missing real user IDs"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        # Real user IDs that need user records
        real_user_ids = [
            'WR7fnyg4H2Zd8f2pYN2cVKwI1tD3',
            'DpUI9J4DjnUDdhHl5yy1Gm8pSPS2', 
            'AYm7eLvxn7hkOiRovNdwKfIhyCq2',
            'uBQTgtf0fzM32pDvzljxm5T080I2'
        ]
        
        print("👥 Creating user records for real user IDs...")
        
        users_ref = db.collection('users')
        
        for i, user_id in enumerate(real_user_ids):
            user_data = {
                'name': f'User {i+1}',
                'email': f'user{i+1}@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            }
            
            users_ref.document(user_id).set(user_data)
            print(f"✅ Created user: {user_id} ({user_data['name']})")
        
        print(f"\n🎉 Successfully created {len(real_user_ids)} real user records")
        
        # Verify no more missing users
        print("\n🔍 Final verification...")
        docs = list(users_ref.stream())
        print(f"👥 Total users now: {len(docs)}")
        
        # Check if any users are still missing
        listings_ref = db.collection('listings')
        listing_docs = list(listings_ref.stream())
        
        user_ids_in_users = set(doc.id for doc in docs)
        user_ids_in_listings = set()
        
        for listing_doc in listing_docs:
            listing_data = listing_doc.to_dict()
            user_id = listing_data.get('userId')
            if user_id:
                user_ids_in_listings.add(user_id)
        
        missing_users = user_ids_in_listings - user_ids_in_users
        if missing_users:
            print(f"❌ Still missing users: {missing_users}")
        else:
            print("✅ All listing user references are now valid!")
        
    except Exception as e:
        print(f"❌ Error creating users: {e}")

if __name__ == "__main__":
    create_real_users()
