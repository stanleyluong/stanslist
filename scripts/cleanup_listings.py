#!/usr/bin/env python3
"""
Cleanup script to remove fake listings while preserving specific real listings.
Requires: pip install firebase-admin
"""

import firebase_admin
from firebase_admin import credentials, firestore
import sys
import os

# IDs of listings to keep
KEEP_LISTINGS = [
    'eJcyzgfMmfM2eLEmeK62',
    'qBK9kYmhiYiom99DkluB', 
    'sNzIfzKXAkpySLNVnUCC',
    'tdDUoLaNAozUyTriLX3r'
]

def initialize_firebase():
    """Initialize Firebase Admin SDK"""
    try:
        # Path to service account key
        service_account_path = os.path.join(os.path.dirname(__file__), '..', 'serviceAccountKey.json')
        
        if not os.path.exists(service_account_path):
            print(f"❌ Service account key not found at: {service_account_path}")
            return None
            
        # Initialize Firebase Admin SDK
        cred = credentials.Certificate(service_account_path)
        firebase_admin.initialize_app(cred, {
            'storageBucket': 'stan-s-list.firebasestorage.app'
        })
        
        return firestore.client()
    except Exception as e:
        print(f"❌ Error initializing Firebase: {e}")
        return None

def cleanup_listings():
    """Main cleanup function"""
    print("🔍 Initializing Firebase connection...")
    
    db = initialize_firebase()
    if not db:
        return False
    
    try:
        print("📊 Fetching all listings...")
        
        # Get all listings
        listings_ref = db.collection('listings')
        docs = listings_ref.stream()
        
        listings_to_delete = []
        listings_to_keep = []
        total_count = 0
        
        # Process each document
        for doc in docs:
            total_count += 1
            if doc.id in KEEP_LISTINGS:
                listings_to_keep.append(doc.id)
            else:
                listings_to_delete.append(doc.id)
        
        print(f"📊 Found {total_count} total listings")
        print(f"✅ Listings to keep ({len(listings_to_keep)}): {listings_to_keep}")
        print(f"❌ Listings to delete ({len(listings_to_delete)}): {listings_to_delete}")
        
        if len(listings_to_delete) == 0:
            print("🎉 No listings to delete!")
            return True
        
        # Confirm deletion
        print(f"\n⚠️  About to delete {len(listings_to_delete)} listings...")
        
        # Delete listings in batches (Firestore batch limit is 500)
        batch_size = 500
        deleted_count = 0
        
        for i in range(0, len(listings_to_delete), batch_size):
            batch = db.batch()
            batch_ids = listings_to_delete[i:i + batch_size]
            
            for listing_id in batch_ids:
                doc_ref = listings_ref.document(listing_id)
                batch.delete(doc_ref)
            
            # Commit the batch
            batch.commit()
            deleted_count += len(batch_ids)
            print(f"🗑️  Deleted batch: {deleted_count}/{len(listings_to_delete)} listings")
        
        print(f"\n✅ Successfully deleted {deleted_count} listings")
        print(f"🔒 Preserved {len(listings_to_keep)} listings")
        
        # Verify final count
        final_docs = list(listings_ref.stream())
        print(f"📊 Final count: {len(final_docs)} listings remaining")
        
        return True
        
    except Exception as e:
        print(f"❌ Error during cleanup: {e}")
        return False

if __name__ == "__main__":
    print("🧹 Starting listing cleanup...")
    success = cleanup_listings()
    
    if success:
        print("✅ Cleanup completed successfully!")
        sys.exit(0)
    else:
        print("❌ Cleanup failed!")
        sys.exit(1)
