#!/usr/bin/env python3
"""
Final Image Analysis and Verification
Comprehensive analysis of image assignments for uniqueness and quality
"""

import firebase_admin
from firebase_admin import credentials, firestore
import requests
from collections import defaultdict

# Initialize Firebase Admin
if not firebase_admin._apps:
    cred = credentials.Certificate('serviceAccountKey.json')
    firebase_admin.initialize_app(cred)

db = firestore.client()

def analyze_final_images():
    """Perform comprehensive analysis of all assigned images."""
    
    print("🔍 Final Image Analysis and Verification")
    print("=" * 50)
    
    # Get all listings
    listings_ref = db.collection('listings')
    listings = listings_ref.stream()
    
    all_listings = []
    for listing in listings:
        data = listing.to_dict()
        data['id'] = listing.id
        all_listings.append(data)
    
    print(f"📊 Analyzing {len(all_listings)} listings...")
    
    # Track image usage
    image_usage = defaultdict(list)
    broken_images = []
    category_breakdown = defaultdict(int)
    
    # Analyze each listing
    for listing in all_listings:
        title = listing.get('title', 'Unknown')
        category = listing.get('category', 'unknown')
        images = listing.get('images', [])
        
        category_breakdown[category] += 1
        
        if images:
            img_url = images[0]  # Get first image
            image_usage[img_url].append({
                'title': title,
                'category': category,
                'id': listing['id']
            })
            
            # Check if image is accessible
            try:
                response = requests.head(img_url, timeout=5)
                if response.status_code != 200:
                    broken_images.append({'title': title, 'url': img_url, 'status': response.status_code})
            except Exception as e:
                broken_images.append({'title': title, 'url': img_url, 'error': str(e)})
        else:
            print(f"  ⚠️  No image: {title}")
    
    # Calculate statistics
    total_images = len(image_usage)
    unique_images = sum(1 for listings in image_usage.values() if len(listings) == 1)
    duplicate_images = total_images - unique_images
    
    print(f"\n📈 Image Statistics:")
    print(f"  Total listings: {len(all_listings)}")
    print(f"  Total unique images: {total_images}")
    print(f"  Truly unique (1:1): {unique_images}")
    print(f"  Duplicate images: {duplicate_images}")
    print(f"  Uniqueness rate: {unique_images/total_images*100:.1f}%")
    print(f"  Broken images: {len(broken_images)}")
    
    # Category breakdown
    print(f"\n📂 Category Breakdown:")
    for category, count in sorted(category_breakdown.items()):
        print(f"  {category}: {count} listings")
    
    # Show duplicates if any
    if duplicate_images > 0:
        print(f"\n🔄 Duplicate Image Usage:")
        for img_url, usages in image_usage.items():
            if len(usages) > 1:
                print(f"  Image used {len(usages)} times:")
                for usage in usages:
                    print(f"    - {usage['title']} ({usage['category']})")
                print(f"    URL: {img_url[:80]}...")
    
    # Show broken images if any
    if broken_images:
        print(f"\n❌ Broken Images:")
        for broken in broken_images:
            print(f"  {broken['title']}")
            print(f"    URL: {broken['url']}")
            if 'status' in broken:
                print(f"    Status: {broken['status']}")
            if 'error' in broken:
                print(f"    Error: {broken['error']}")
    
    # Show sample of well-matched content
    print(f"\n✅ Sample Content Matches:")
    well_matched = []
    
    for img_url, usages in image_usage.items():
        if len(usages) == 1:  # Only unique images
            usage = usages[0]
            title = usage['title'].lower()
            
            # Check for good matches
            good_matches = [
                ('bmw' in title and 'bmw' in img_url),
                ('playstation' in title and 'playstation' in img_url),
                ('macbook' in title and 'macbook' in img_url),
                ('tesla' in title and 'tesla' in img_url),
                ('nintendo' in title and 'nintendo' in img_url),
                ('samsung' in title and 'samsung' in img_url),
                ('ipad' in title and 'ipad' in img_url),
                ('airpods' in title and 'airpods' in img_url),
                ('honda' in title and 'honda' in img_url),
                ('jeep' in title and 'jeep' in img_url)
            ]
            
            if any(good_matches):
                well_matched.append(usage['title'])
    
    for i, title in enumerate(well_matched[:10]):  # Show first 10
        print(f"  {i+1:2d}. {title}")
    
    if len(well_matched) > 10:
        print(f"  ... and {len(well_matched) - 10} more perfectly matched")
    
    # Overall quality assessment
    print(f"\n🎯 Quality Assessment:")
    
    if unique_images == total_images:
        print(f"  ✅ PERFECT: 100% unique images")
    elif unique_images > total_images * 0.9:
        print(f"  ✅ EXCELLENT: >90% unique images")
    elif unique_images > total_images * 0.8:
        print(f"  ⚠️  GOOD: >80% unique images")
    else:
        print(f"  ❌ NEEDS WORK: <80% unique images")
    
    if len(broken_images) == 0:
        print(f"  ✅ PERFECT: No broken images")
    elif len(broken_images) < 3:
        print(f"  ⚠️  MINOR: {len(broken_images)} broken images")
    else:
        print(f"  ❌ MAJOR: {len(broken_images)} broken images")
    
    content_match_rate = len(well_matched) / total_images * 100
    if content_match_rate > 80:
        print(f"  ✅ EXCELLENT: {content_match_rate:.1f}% content-matched")
    elif content_match_rate > 60:
        print(f"  ⚠️  GOOD: {content_match_rate:.1f}% content-matched")
    else:
        print(f"  ❌ POOR: {content_match_rate:.1f}% content-matched")
    
    # Final recommendation
    print(f"\n🏆 Final Result:")
    if unique_images == total_images and len(broken_images) == 0 and content_match_rate > 80:
        print(f"  🎉 MARKETPLACE READY! Perfect image implementation")
    elif unique_images > total_images * 0.9 and len(broken_images) < 3:
        print(f"  ✅ PRODUCTION READY! Minor improvements possible")
    else:
        print(f"  ⚠️  NEEDS IMPROVEMENT before production deployment")
    
    return {
        'total_listings': len(all_listings),
        'unique_images': unique_images,
        'total_images': total_images,
        'broken_images': len(broken_images),
        'content_match_rate': content_match_rate,
        'uniqueness_rate': unique_images/total_images*100 if total_images > 0 else 0
    }

if __name__ == "__main__":
    results = analyze_final_images()
    print(f"\n📋 Summary Report:")
    print(f"  Listings: {results['total_listings']}")
    print(f"  Unique Images: {results['unique_images']}/{results['total_images']}")
    print(f"  Uniqueness: {results['uniqueness_rate']:.1f}%")
    print(f"  Broken: {results['broken_images']}")
    print(f"  Content Match: {results['content_match_rate']:.1f}%")
