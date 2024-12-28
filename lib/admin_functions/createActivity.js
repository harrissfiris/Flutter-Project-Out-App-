const admin = require("firebase-admin");

// Αρχικοποίηση Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

// Συνάρτηση για δημιουργία νέου activity
async function createActivity({
  description,
  interest,
  latitude,
  location,
  longitude,
  name,
  organizer,
  phone,
  photo,
  website,
}) {
  try {
    const activityData = {
      Description: description,
      Interest: interest,
      Latitude: latitude,
      Location: location,
      Longitude: longitude,
      Name: name,
      Organizer: organizer,
      Phone: phone,
      Photo: photo,
      Website: website,
    };

    const newActivityRef = await db.collection("activities").add(activityData);

    console.log(`New activity created with ID: ${newActivityRef.id}`);
  } catch (error) {
    console.error("Error creating activity: ", error.message);
  }
}

// Παράδειγμα χρήσης της συνάρτησης
const newActivity = {
    description: "Authentic Scottish pub offering a wide variety of whiskies, beers, and lively events like quiz nights.",
    interest: "Drinking",
    latitude: 37.9895,
    location: "Konopisopoulou 23 & Logothetidi, Ampelokipoi, Athens 11524, Greece",
    longitude: 23.7540,
    name: "Beer night",
    organizer: "The Wee Dram Scottish Pub",
    phone: "+30 210 6916509",
    photo: "wee_dram_pub.jpg", // Add the actual photo filename if you upload it
    website: "https://www.beer.gr/beerhouse/theweedram",
  };

// Κλήση της συνάρτησης με τα πεδία
createActivity(newActivity);

// Για εκτελεση της συνάρτησης στο terminal εκτελώ
// node lib/admin_functions/createActivity.js