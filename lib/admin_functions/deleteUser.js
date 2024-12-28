const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function deleteUser(userId) {
  try {
    // 1. Διαγραφή του χρήστη από τη συλλογή users
    await db.collection("users").doc(userId).delete();

    // 2. Αφαίρεση του χρήστη από friends άλλων χρηστών
    const usersSnapshot = await db.collection("users").get();
    for (const userDoc of usersSnapshot.docs) {
      await db.collection("users").doc(userDoc.id).update({
        friends: admin.firestore.FieldValue.arrayRemove(userId),
      });
    }

    // 3. Αφαίρεση του χρήστη από groups και διαγραφή groups με 2 μέλη
    const groupsSnapshot = await db.collection("group").get();
    for (const groupDoc of groupsSnapshot.docs) {
      const groupData = groupDoc.data();
      const members = groupData.members || [];

      if (members.includes(userId)) {
        if (members.length <= 2) {
          // Διαγραφή group αν είχε 2 μέλη
          await db.collection("group").doc(groupDoc.id).delete();

          // Αφαίρεση group ID από τον άλλο χρήστη
          for (const memberId of members) {
            if (memberId !== userId) {
              await db.collection("users").doc(memberId).update({
                groups: admin.firestore.FieldValue.arrayRemove(groupDoc.id),
              });
            }
          }
        } else {
          // Αφαίρεση userId από τα members
          await db.collection("group").doc(groupDoc.id).update({
            members: admin.firestore.FieldValue.arrayRemove(userId),
          });
        }
      }
    }

    // 4. Αφαίρεση του χρήστη από participants των plans και διαγραφή των μοναδικών plans
    const plansSnapshot = await db.collection("plans").get();
    for (const planDoc of plansSnapshot.docs) {
      const planData = planDoc.data();
      const participants = planData.participants || [];

      if (participants.includes(userId)) {
        if (participants.length === 1) {
          // Διαγραφή του plan αν ο χρήστης ήταν μοναδικός participant
          await db.collection("plans").doc(planDoc.id).delete();
        } else {
          // Αφαίρεση userId από τους participants
          await db.collection("plans").doc(planDoc.id).update({
            participants: admin.firestore.FieldValue.arrayRemove(userId),
          });
        }
      }
    }

    // 5. Διαγραφή του χρήστη από το Firebase Authentication
    await admin.auth().deleteUser(userId);

    console.log(`User ${userId} and associated data successfully deleted.`);
  } catch (error) {
    console.error(`Error deleting user: ${error}`);
  }
}

// Εκτέλεση της συνάρτησης
const userId = process.argv[2]; // Λήψη userId από τη γραμμή εντολών
if (!userId) {
  console.error('Please provide a userId as an argument.');
  process.exit(1);
}

deleteUser(userId);

// Για εκτελεση της συναρτησης απο το terminal εκτελω
// node lib/admin_functions/deleteUser.js userId