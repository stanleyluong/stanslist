const { faker } = require('@faker-js/faker');
const admin = require('firebase-admin');

// Initialize Firebase Admin with service account
const serviceAccount = require('../serviceAccountKey.json');

// Get the project configuration from firebase.json
const firebaseConfig = require('../firebase.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}.firebaseio.com`,
  storageBucket: `${serviceAccount.project_id}.appspot.com`
});

const db = admin.firestore();

// Helper function to generate random image URLs
function getRandomImages(category, count = 3) {
  const images = [];
  for (let i = 0; i < count; i++) {
    switch(category) {
      case 'vehicles':
        images.push(faker.image.transport());
        break;
      case 'property-rentals':
        images.push(faker.image.city());
        break;
      case 'electronics':
        images.push(faker.image.technics());
        break;
      case 'apparel':
        images.push(faker.image.fashion());
        break;
      default:
        images.push(faker.image.url());
    }
  }
  return images;
}

// Category-specific data generators
const categoryGenerators = {
  vehicles: () => ({
    make: faker.vehicle.manufacturer(),
    model: faker.vehicle.model(),
    year: faker.date.past().getFullYear().toString(),
    mileage: faker.number.int({ min: 1000, max: 150000 }).toString(),
    condition: faker.helpers.arrayElement([
      'New', 'Used - Like New', 'Used - Good', 'Used - Fair', 'For Parts'
    ]),
    vin: faker.vehicle.vin(),
    transmission: faker.helpers.arrayElement(['Automatic', 'Manual', 'Other']),
    fuelType: faker.helpers.arrayElement(['Gasoline', 'Diesel', 'Electric', 'Hybrid', 'Other'])
  }),
  
  'property-rentals': () => ({
    propertyType: faker.helpers.arrayElement([
      'Apartment', 'House', 'Condo', 'Townhouse', 'Room', 'Other'
    ]),
    bedrooms: faker.number.int({ min: 1, max: 5 }).toString(),
    bathrooms: faker.number.float({ min: 1, max: 4, precision: 0.5 }).toString(),
    sqft: faker.number.int({ min: 500, max: 3000 }).toString(),
    petPolicy: faker.helpers.arrayElement([
      'Dogs Allowed', 'Cats Allowed', 'No Pets', 'Pets Negotiable'
    ]),
    leaseTerm: faker.helpers.arrayElement(['12 months', '6 months', 'Month-to-Month']),
    availabilityDate: faker.date.future().toISOString().split('T')[0]
  }),

  electronics: () => ({
    type: faker.helpers.arrayElement(['Phone', 'Laptop', 'TV', 'Tablet', 'Camera']),
    brand: faker.helpers.arrayElement(['Apple', 'Samsung', 'Sony', 'LG', 'Dell']),
    model: faker.commerce.product(),
    condition: faker.helpers.arrayElement([
      'New', 'Like New', 'Good', 'Fair', 'Poor', 'For Parts'
    ])
  }),

  apparel: () => ({
    type: faker.helpers.arrayElement(['Shirt', 'Pants', 'Dress', 'Shoes', 'Jacket']),
    size: faker.helpers.arrayElement(['XS', 'S', 'M', 'L', 'XL']),
    brand: faker.company.name(),
    condition: faker.helpers.arrayElement([
      'New with tags', 'New without tags', 'Like New', 'Good', 'Fair'
    ]),
    color: faker.color.human(),
    material: faker.helpers.arrayElement(['Cotton', 'Polyester', 'Wool', 'Leather'])
  })
};

// Generate listings for a category
async function generateListingsForCategory(category, count) {
  const listings = [];
  const users = Array.from({ length: count }, () => ({
    id: faker.string.uuid(),
    email: faker.internet.email()
  }));

  for (let i = 0; i < count; i++) {
    const user = users[i];
    const categoryFields = categoryGenerators[category] ? categoryGenerators[category]() : {};
    
    const listing = {
      id: faker.string.uuid(),
      title: faker.commerce.productName(),
      description: faker.commerce.productDescription(),
      price: parseFloat(faker.commerce.price({ min: 10, max: 1000 })),
      category,
      userId: user.id,
      datePosted: faker.date.recent(),
      createdAt: new Date(),
      images: getRandomImages(category),
      location: `${faker.location.city()}, ${faker.location.state()}`,
      isActive: true,
      contactEmail: user.email,
      contactPhone: faker.phone.number(),
      categoryFields
    };

    listings.push(listing);
  }

  return listings;
}

// Main seeding function
async function seedDatabase() {
  try {
    console.log('Starting database seeding...');
    const categoriesToSeed = ['vehicles', 'property-rentals', 'electronics', 'apparel'];
    const listingsPerCategory = 10;

    for (const category of categoriesToSeed) {
      console.log(`Generating listings for category: ${category}`);
      const listings = await generateListingsForCategory(category, listingsPerCategory);
      
      for (const listing of listings) {
        await db.collection('listings').doc(listing.id).set(listing);
        console.log(`Created listing: ${listing.title} in category: ${category}`);
      }
    }

    console.log('Database seeding completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();
