#!/usr/bin/env python3
"""
Fix data quality issues for marketplace listings:
1. Add realistic email addresses
2. Diversify locations across US cities
3. Spread posting dates from January 1, 2025 to June 2, 2025
"""

import firebase_admin
from firebase_admin import credentials, firestore
from faker import Faker
import random
from datetime import datetime, timezone, timedelta

# Initialize Firebase
if not firebase_admin._apps:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()
fake = Faker()

# Define diverse US locations
LOCATIONS = [
    "New York, NY",
    "Los Angeles, CA", 
    "Chicago, IL",
    "Houston, TX",
    "Phoenix, AZ",
    "Philadelphia, PA",
    "San Antonio, TX",
    "San Diego, CA",
    "Dallas, TX",
    "San Jose, CA",
    "Austin, TX",
    "Jacksonville, FL",
    "Fort Worth, TX",
    "Columbus, OH",
    "Charlotte, NC",
    "San Francisco, CA",
    "Indianapolis, IN",
    "Seattle, WA",
    "Denver, CO",
    "Washington, DC",
    "Boston, MA",
    "El Paso, TX",
    "Nashville, TN",
    "Detroit, MI",
    "Oklahoma City, OK",
    "Portland, OR",
    "Las Vegas, NV",
    "Memphis, TN",
    "Louisville, KY",
    "Baltimore, MD",
    "Milwaukee, WI",
    "Albuquerque, NM",
    "Tucson, AZ",
    "Fresno, CA",
    "Mesa, AZ",
    "Sacramento, CA",
    "Atlanta, GA",
    "Kansas City, MO",
    "Colorado Springs, CO",
    "Miami, FL",
    "Raleigh, NC",
    "Omaha, NE",
    "Long Beach, CA",
    "Virginia Beach, VA",
    "Oakland, CA",
    "Minneapolis, MN",
    "Tulsa, OK",
    "Arlington, TX",
    "Tampa, FL",
    "New Orleans, LA"
]

def generate_email_from_name(user_id):
    """Generate realistic email from user_id"""
    # Extract name components from user_id like "user_john_smith"
    if user_id.startswith("user_"):
        name_part = user_id[5:]  # Remove "user_" prefix
        name_components = name_part.split("_")
        
        if len(name_components) >= 2:
            first_name = name_components[0]
            last_name = name_components[1]
            
            # Various email patterns
            patterns = [
                f"{first_name}.{last_name}@gmail.com",
                f"{first_name}.{last_name}@yahoo.com", 
                f"{first_name}.{last_name}@outlook.com",
                f"{first_name}{last_name}@gmail.com",
                f"{first_name}_{last_name}@gmail.com",
                f"{first_name[0]}{last_name}@gmail.com",
                f"{first_name}.{last_name[0]}@gmail.com",
                f"{first_name}{random.randint(10, 99)}@gmail.com",
                f"{first_name}.{last_name}{random.randint(1, 9)}@yahoo.com"
            ]
            return random.choice(patterns)
    
    # Fallback to faker if user_id doesn't match expected pattern
    return fake.email()

def generate_random_date():
    """Generate random date between January 1, 2025 and June 2, 2025"""
    start_date = datetime(2025, 1, 1, tzinfo=timezone.utc)
    end_date = datetime(2025, 6, 2, tzinfo=timezone.utc)
    
    # Calculate random time between start and end
    time_difference = end_date - start_date
    random_days = random.randint(0, time_difference.days)
    random_hours = random.randint(0, 23)
    random_minutes = random.randint(0, 59)
    random_seconds = random.randint(0, 59)
    
    random_date = start_date + timedelta(
        days=random_days, 
        hours=random_hours, 
        minutes=random_minutes, 
        seconds=random_seconds
    )
    
    return random_date

def fix_listing_data():
    """Fix data quality issues for all fake listings"""
    
    print("🔍 Fetching all listings...")
    listings_ref = db.collection('listings')
    listings = listings_ref.stream()
    
    updated_count = 0
    
    for listing in listings:
        listing_data = listing.to_dict()
        user_id = listing_data.get('userId', '')
        
        # Skip real user listings (preserve original data)
        real_user_ids = [
            'YfY4GhBz5eeMC85ULOPhRH6eeKa2',
            'Rn67vCW8n6TGgkI0Bt4KdLs83bO2', 
            'EqXqL9H4SZS9XGGsKDhxLVbLNKV2',
            'KqXqL9H4SZS9XGGsKDhxLVbLN123'
        ]
        
        if user_id in real_user_ids:
            print(f"⏭️  Skipping real listing: {listing.id}")
            continue
            
        # Prepare updates
        updates = {}
        
        # Fix contact email
        contact_email = listing_data.get('contactEmail')
        if contact_email is None:
            new_email = generate_email_from_name(user_id)
            updates['contactEmail'] = new_email
            print(f"📧 Adding email for {user_id}: {new_email}")
        
        # Fix location if it's San Francisco, CA
        current_location = listing_data.get('location', '')
        if current_location == "San Francisco, CA":
            new_location = random.choice(LOCATIONS)
            updates['location'] = new_location
            print(f"📍 Changing location from {current_location} to {new_location}")
        
        # Fix date posted
        date_posted = listing_data.get('datePosted')
        if date_posted is None:
            # Generate random date and also update createdAt to match
            new_date = generate_random_date()
            updates['datePosted'] = new_date
            updates['createdAt'] = new_date
            updates['updatedAt'] = new_date
            print(f"📅 Setting date for listing {listing.id}: {new_date.strftime('%Y-%m-%d %H:%M:%S')}")
        
        # Apply updates if any
        if updates:
            try:
                listings_ref.document(listing.id).update(updates)
                updated_count += 1
                print(f"✅ Updated listing {listing.id}")
            except Exception as e:
                print(f"❌ Error updating listing {listing.id}: {e}")
        else:
            print(f"⏭️  No updates needed for listing {listing.id}")
    
    print(f"\n🎉 Data quality fix complete! Updated {updated_count} listings.")
    
    # Verify changes
    print("\n🔍 Verifying changes...")
    sample_listings = listings_ref.limit(5).stream()
    
    for listing in sample_listings:
        data = listing.to_dict()
        user_id = data.get('userId', 'unknown')
        
        # Skip real users in verification
        if user_id in ['YfY4GhBz5eeMC85ULOPhRH6eeKa2', 'Rn67vCW8n6TGgkI0Bt4KdLs83bO2', 'EqXqL9H4SZS9XGGsKDhxLVbLNKV2', 'KqXqL9H4SZS9XGGsKDhxLVbLN123']:
            continue
            
        print(f"\n📄 Sample listing {listing.id}:")
        print(f"  👤 User: {user_id}")
        print(f"  📧 Email: {data.get('contactEmail', 'None')}")
        print(f"  📍 Location: {data.get('location', 'None')}")
        print(f"  📅 Date Posted: {data.get('datePosted', 'None')}")
        break

if __name__ == "__main__":
    fix_listing_data()
