#!/usr/bin/env python3
"""
Create missing user records for the fake listing user IDs.
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

def create_missing_users():
    """Create user records for missing user IDs"""
    db = initialize_firebase()
    if not db:
        return
    
    try:
        # User data for fake user IDs
        fake_users = {
            'user_john_doe': {
                'name': 'John Doe',
                'email': 'john.doe@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_jane_smith': {
                'name': 'Jane Smith',
                'email': 'jane.smith@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_mike_johnson': {
                'name': 'Mike Johnson',
                'email': 'mike.johnson@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_sarah_wilson': {
                'name': 'Sarah Wilson',
                'email': 'sarah.wilson@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_david_brown': {
                'name': 'David Brown',
                'email': 'david.brown@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_emma_taylor': {
                'name': 'Emma Taylor',
                'email': 'emma.taylor@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_chris_garcia': {
                'name': 'Chris Garcia',
                'email': 'chris.garcia@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_amanda_anderson': {
                'name': 'Amanda Anderson',
                'email': 'amanda.anderson@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_ryan_martinez': {
                'name': 'Ryan Martinez',
                'email': 'ryan.martinez@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            },
            'user_lisa_davis': {
                'name': 'Lisa Davis',
                'email': 'lisa.davis@example.com',
                'joinedAt': datetime.now(),
                'isActive': True
            }
        }
        
        print("👥 Creating missing user records...")
        
        users_ref = db.collection('users')
        
        for user_id, user_data in fake_users.items():
            users_ref.document(user_id).set(user_data)
            print(f"✅ Created user: {user_id} ({user_data['name']})")
        
        print(f"\n🎉 Successfully created {len(fake_users)} user records")
        
        # Verify creation
        print("\n🔍 Verifying user creation...")
        docs = list(users_ref.stream())
        print(f"👥 Total users now: {len(docs)}")
        
    except Exception as e:
        print(f"❌ Error creating users: {e}")

if __name__ == "__main__":
    create_missing_users()
