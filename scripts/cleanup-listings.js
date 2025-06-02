const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json');

// Initialize Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: 'stan-s-list.firebasestorage.app'
});

const db = admin.firestore();

// IDs of listings to keep
const keepListings = [
  'eJcyzgfMmfM2eLEmeK62',
  'qBK9kYmhiYiom99DkluB', 
  'sNzIfzKXAkpySLNVnUCC',
  'tdDUoLaNAozUyTriLX3r'
];

async function cleanupListings() {
  try {
    console.log('🔍 Starting cleanup process...');
    console.log('🔗 Connecting to Firebase...');
    
    // Test Firebase connection first
    console.log('🧪 Testing Firebase connection...');
    const testDoc = await db.collection('listings').limit(1).get();
    console.log('✅ Firebase connection successful');
    
    console.log('🔍 Fetching all listings...');
    const snapshot = await db.collection('listings').get();
    console.log(`📊 Found ${snapshot.size} total listings`);
    
    const listingsToDelete = [];
    const listingsToKeep = [];
    
    snapshot.forEach(doc => {
      if (keepListings.includes(doc.id)) {
        listingsToKeep.push(doc.id);
      } else {
        listingsToDelete.push(doc.id);
      }
    });
    
    console.log(`✅ Listings to keep (${listingsToKeep.length}):`, listingsToKeep);
    console.log(`❌ Listings to delete (${listingsToDelete.length}):`, listingsToDelete);
    
    if (listingsToDelete.length === 0) {
      console.log('🎉 No listings to delete!');
      return;
    }
    
    // Confirm deletion
    console.log(`\n⚠️  About to delete ${listingsToDelete.length} listings...`);
    
    // Delete in batches (Firestore has a limit of 500 operations per batch)
    const batchSize = 500;
    let deletedCount = 0;
    
    for (let i = 0; i < listingsToDelete.length; i += batchSize) {
      const batch = db.batch();
      const batchIds = listingsToDelete.slice(i, i + batchSize);
      
      batchIds.forEach(id => {
        const docRef = db.collection('listings').doc(id);
        batch.delete(docRef);
      });
      
      await batch.commit();
      deletedCount += batchIds.length;
      console.log(`🗑️  Deleted batch: ${deletedCount}/${listingsToDelete.length} listings`);
    }
    
    console.log(`\n✅ Successfully deleted ${deletedCount} listings`);
    console.log(`🔒 Preserved ${listingsToKeep.length} listings`);
    
    // Verify final count
    const finalSnapshot = await db.collection('listings').get();
    console.log(`📊 Final count: ${finalSnapshot.size} listings remaining`);
    
// Add timeout to prevent hanging
const timeout = setTimeout(() => {
  console.error('❌ Script timeout after 30 seconds');
  process.exit(1);
}, 30000);

cleanupListings().finally(() => {
  clearTimeout(timeout);
});{
    console.error('❌ Error cleaning up listings:', error);
  } finally {
    process.exit();
  }
}

cleanupListings();
