const { faker } = require('@faker-js/faker');
const admin = require('firebase-admin');

// Initialize Firebase Admin with service account
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`,
  storageBucket: `${serviceAccount.project_id}.appspot.com`
});

const db = admin.firestore();

// Function to generate realistic Firebase Storage URLs
function generateFirebaseStorageUrls(count = 3, category = 'general') {
  const urls = [];
  const projectId = serviceAccount.project_id;
  
  for (let i = 0; i < count; i++) {
    // Generate a realistic Firebase Storage URL structure
    const filename = `${faker.string.uuid()}-${faker.word.noun()}.jpg`;
    const url = `https://firebasestorage.googleapis.com/v0/b/${projectId}.firebasestorage.app/o/listings%2F${filename}?alt=media&token=${faker.string.uuid()}`;
    urls.push(url);
  }
  
  return urls;
}

// Category-specific data generators with realistic titles and descriptions
const categoryGenerators = {
  vehicles: () => {
    const makes = ['Honda', 'Toyota', 'Ford', 'Chevrolet', 'BMW', 'Mercedes-Benz', 'Volkswagen', 'Nissan', 'Hyundai', 'Kia'];
    const models = {
      'Honda': ['Civic', 'Accord', 'CR-V', 'Pilot', 'Odyssey'],
      'Toyota': ['Corolla', 'Camry', 'RAV4', 'Highlander', 'Prius'],
      'Ford': ['F-150', 'Mustang', 'Explorer', 'Edge', 'Escape'],
      'Chevrolet': ['Silverado', 'Equinox', 'Malibu', 'Traverse', 'Camaro'],
      'BMW': ['3 Series', '5 Series', 'X3', 'X5', 'i3'],
      'Mercedes-Benz': ['C-Class', 'E-Class', 'GLC', 'GLE', 'A-Class'],
      'Volkswagen': ['Jetta', 'Passat', 'Tiguan', 'Atlas', 'Golf'],
      'Nissan': ['Altima', 'Sentra', 'Rogue', 'Pathfinder', '370Z'],
      'Hyundai': ['Elantra', 'Sonata', 'Tucson', 'Santa Fe', 'Genesis'],
      'Kia': ['Forte', 'Optima', 'Sorento', 'Sportage', 'Soul']
    };
    
    const make = faker.helpers.arrayElement(makes);
    const model = faker.helpers.arrayElement(models[make]);
    const year = faker.number.int({ min: 2000, max: 2024 });
    const mileage = faker.number.int({ min: 0, max: 200000 });
    const condition = faker.helpers.arrayElement(['excellent', 'good', 'fair', 'poor']);
    const price = faker.number.int({ min: 3000, max: 65000 });
    
    const title = `${year} ${make} ${model}`;
    const description = `${year} ${make} ${model} in ${condition} condition. This reliable vehicle has ${mileage.toLocaleString()} miles and has been well-maintained. Great for daily commuting or family trips. Clean title, no accidents reported. Contact for more details or to schedule a test drive.`;
    
    return {
      title,
      description,
      price,
      categoryFields: {
        make,
        model,
        year: year.toString(),
        mileage: mileage.toString(),
        condition,
        transmission: faker.helpers.arrayElement(['automatic', 'manual']),
        engine_size: faker.helpers.arrayElement(['1.6L', '2.0L', '2.4L', '3.0L', '3.5L', '4.0L']),
        fuel_type: faker.helpers.arrayElement(['gasoline', 'diesel', 'electric', 'hybrid']),
        exterior_color: faker.vehicle.color(),
        interior_color: faker.vehicle.color(),
        vehicle_type: faker.helpers.arrayElement(['sedan', 'suv', 'truck', 'coupe', 'wagon']),
        vin: faker.vehicle.vin(),
      },
      images: generateFirebaseStorageUrls(3, 'vehicles')
    };
  },

  'property-rentals': () => {
    const propertyTypes = ['Apartment', 'House', 'Condo', 'Townhouse', 'Studio'];
    const propertyType = faker.helpers.arrayElement(propertyTypes);
    const bedrooms = faker.number.int({ min: 1, max: 4 });
    const bathrooms = faker.number.float({ min: 1, max: 3, multipleOf: 0.5 });
    const sqft = faker.number.int({ min: 500, max: 2500 });
    const rent = faker.number.int({ min: 800, max: 4000 });
    const city = faker.location.city();
    
    const title = `${bedrooms}BR ${propertyType} for Rent in ${city}`;
    const description = `Spacious ${bedrooms} bedroom, ${bathrooms} bathroom ${propertyType.toLowerCase()} available for rent. ${sqft} square feet of living space with modern amenities. Great location with easy access to shopping, dining, and public transportation. Perfect for ${bedrooms === 1 ? 'individuals or couples' : 'families'}. Contact us to schedule a viewing!`;
    
    return {
      title,
      description,
      price: rent,
      categoryFields: {
        property_type: propertyType.toLowerCase(),
        bedrooms: bedrooms.toString(),
        bathrooms: bathrooms.toString(),
        sqft: sqft.toString(),
        pet_policy: faker.helpers.arrayElement(['dogs_allowed', 'cats_allowed', 'no_pets', 'pets_negotiable']),
        lease_term: faker.helpers.arrayElement(['12_months', '6_months', 'month_to_month']),
        availability_date: faker.date.future().toISOString().split('T')[0],
        parking: faker.helpers.arrayElement(['garage', 'driveway', 'street', 'none']),
        laundry: faker.helpers.arrayElement(['in_unit', 'in_building', 'nearby', 'none']),
      },
      images: generateFirebaseStorageUrls(3, 'property')
    };
  },

  electronics: () => {
    const items = [
      { type: 'iPhone', brands: ['Apple'], models: ['iPhone 14', 'iPhone 13', 'iPhone 12', 'iPhone SE'], priceRange: [200, 1200] },
      { type: 'MacBook', brands: ['Apple'], models: ['MacBook Air', 'MacBook Pro 13"', 'MacBook Pro 16"'], priceRange: [600, 2500] },
      { type: 'Samsung Galaxy', brands: ['Samsung'], models: ['Galaxy S23', 'Galaxy S22', 'Galaxy Note 20', 'Galaxy A54'], priceRange: [150, 1000] },
      { type: 'Gaming Console', brands: ['Sony', 'Microsoft', 'Nintendo'], models: ['PlayStation 5', 'Xbox Series X', 'Nintendo Switch'], priceRange: [200, 600] },
      { type: 'Laptop', brands: ['Dell', 'HP', 'Lenovo', 'ASUS'], models: ['XPS 13', 'Pavilion', 'ThinkPad', 'ZenBook'], priceRange: [300, 1800] },
    ];
    
    const item = faker.helpers.arrayElement(items);
    const brand = faker.helpers.arrayElement(item.brands);
    const model = faker.helpers.arrayElement(item.models);
    const condition = faker.helpers.arrayElement(['new', 'like_new', 'excellent', 'good', 'fair']);
    const price = faker.number.int({ min: item.priceRange[0], max: item.priceRange[1] });
    
    const title = `${brand} ${model} - ${condition.replace('_', ' ')} condition`;
    const description = `${brand} ${model} in ${condition.replace('_', ' ')} condition. ${condition === 'new' ? 'Still in original packaging with warranty.' : 'Well-maintained and fully functional.'} Perfect for ${item.type.includes('iPhone') || item.type.includes('Galaxy') ? 'everyday use, photos, and staying connected' : item.type.includes('MacBook') || item.type.includes('Laptop') ? 'work, school, or creative projects' : 'gaming and entertainment'}. Comes with original accessories where available.`;
    
    return {
      title,
      description,
      price,
      categoryFields: {
        type: item.type.toLowerCase().replace(' ', '_'),
        brand: brand.toLowerCase(),
        model,
        condition,
        warranty: faker.helpers.arrayElement(['yes', 'no']),
        storage: faker.helpers.arrayElement(['64GB', '128GB', '256GB', '512GB', '1TB']),
      },
      images: generateFirebaseStorageUrls(3, 'electronics')
    };
  },

  apparel: () => {
    const items = [
      { type: 'Designer Jacket', brands: ['Nike', 'Adidas', 'North Face', 'Patagonia'], priceRange: [30, 200] },
      { type: 'Jeans', brands: ['Levi\'s', 'Wrangler', 'Lucky Brand', 'AG'], priceRange: [20, 150] },
      { type: 'Sneakers', brands: ['Nike', 'Adidas', 'Jordan', 'Vans'], priceRange: [40, 300] },
      { type: 'Dress', brands: ['Zara', 'H&M', 'Calvin Klein', 'Tommy Hilfiger'], priceRange: [25, 180] },
      { type: 'T-Shirt', brands: ['Gap', 'Uniqlo', 'Ralph Lauren', 'Champion'], priceRange: [10, 80] },
    ];
    
    const item = faker.helpers.arrayElement(items);
    const brand = faker.helpers.arrayElement(item.brands);
    const size = faker.helpers.arrayElement(['XS', 'S', 'M', 'L', 'XL', 'XXL']);
    const condition = faker.helpers.arrayElement(['new_with_tags', 'new_without_tags', 'like_new', 'excellent', 'good']);
    const price = faker.number.int({ min: item.priceRange[0], max: item.priceRange[1] });
    const color = faker.color.human();
    
    const title = `${brand} ${item.type} - Size ${size}`;
    const description = `${brand} ${item.type} in ${color.toLowerCase()} color, size ${size}. Condition: ${condition.replace(/_/g, ' ')}. ${condition.includes('new') ? 'Never worn, still has tags.' : 'Gently used and well-maintained.'} Perfect for ${item.type.includes('Jacket') ? 'outdoor activities or casual wear' : item.type.includes('Jeans') ? 'everyday casual wear' : item.type.includes('Sneakers') ? 'sports, gym, or casual outings' : item.type.includes('Dress') ? 'special occasions or professional settings' : 'casual everyday wear'}. Smoke-free home.`;
    
    return {
      title,
      description,
      price,
      categoryFields: {
        type: item.type.toLowerCase().replace(' ', '_'),
        size,
        brand: brand.toLowerCase(),
        condition,
        color: color.toLowerCase(),
        material: faker.helpers.arrayElement(['cotton', 'polyester', 'wool', 'leather', 'denim', 'silk']),
        gender: faker.helpers.arrayElement(['mens', 'womens', 'unisex']),
      },
      images: generateFirebaseStorageUrls(3, 'apparel')
    };
  }
};

// Generate listings for a category
async function generateListingsForCategory(category, count) {
  const listings = [];
  const users = Array.from({ length: count }, () => ({
    id: faker.string.uuid(),
    email: faker.internet.email(),
    name: faker.person.fullName()
  }));

  for (let i = 0; i < count; i++) {
    const user = users[i];
    const generatedData = categoryGenerators[category]();
    
    const listing = {
      id: faker.string.uuid(),
      title: generatedData.title,
      description: generatedData.description,
      price: generatedData.price,
      category,
      userId: user.id,
      datePosted: faker.date.recent({ days: 30 }).toISOString(),
      createdAt: faker.date.recent({ days: 30 }).toISOString(),
      images: generatedData.images,
      location: `${faker.location.city()}, ${faker.location.stateAbbr()}`,
      isActive: true,
      contactEmail: user.email,
      contactPhone: faker.phone.number(),
      categoryFields: generatedData.categoryFields
    };

    listings.push(listing);
  }

  return listings;
}

// Clear existing data and seed fresh data
async function clearAndSeedDatabase() {
  try {
    console.log('Clearing existing listings...');
    
    // Get all existing listings
    const existingListings = await db.collection('listings').get();
    
    // Delete in batches
    const batchSize = 500;
    let batch = db.batch();
    let operationCount = 0;
    
    for (const doc of existingListings.docs) {
      batch.delete(doc.ref);
      operationCount++;
      
      if (operationCount === batchSize) {
        await batch.commit();
        batch = db.batch();
        operationCount = 0;
      }
    }
    
    if (operationCount > 0) {
      await batch.commit();
    }
    
    console.log(`Cleared ${existingListings.docs.length} existing listings.`);
    
    console.log('Starting database seeding with realistic Firebase Storage URLs...');
    const categoriesToSeed = ['vehicles', 'property-rentals', 'electronics', 'apparel'];
    const listingsPerCategory = 10;

    for (const category of categoriesToSeed) {
      console.log(`Generating realistic listings for category: ${category}`);
      const listings = await generateListingsForCategory(category, listingsPerCategory);
      
      for (const listing of listings) {
        await db.collection('listings').doc(listing.id).set(listing);
        console.log(`Created realistic listing: ${listing.title}`);
      }
    }

    console.log('Database seeding completed successfully with realistic data and Firebase Storage URLs!');
    console.log('Total listings created: ', categoriesToSeed.length * listingsPerCategory);
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

// Run the seeding
clearAndSeedDatabase();
