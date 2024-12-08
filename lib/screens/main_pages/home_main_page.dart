import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  HomePage({super.key});

  Future<List<String>> _getUserInterests() async {
    // Λήψη του τρέχοντος χρήστη
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in!");
    }

    // Ανάκτηση των κατηγοριών από τη Firestore
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    final userData = userDoc.data();

    if (userData == null || !userData.containsKey('selectedCategories')) {
      return [];
    }

    return List<String>.from(userData['selectedCategories']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggested Activities'),
      ),
      body: FutureBuilder<List<String>>(
        future: _getUserInterests(),
        builder: (BuildContext context, AsyncSnapshot<List<String>> userInterestsSnapshot) {
          if (userInterestsSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (userInterestsSnapshot.hasError) {
            return Center(
              child: Text('Error: ${userInterestsSnapshot.error}'),
            );
          }

          // Κατηγορίες του χρήστη
          final userInterests = userInterestsSnapshot.data ?? [];

          if (userInterests.isEmpty) {
            return const Center(
              child: Text('No interests found. Please select your interests.'),
            );
          }

          // Φιλτράρισμα δραστηριοτήτων
          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('activity')
                .where('Interest', whereIn: userInterests) // Φιλτράρισμα με βάση τα interests
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> activitiesSnapshot) {
              if (activitiesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (activitiesSnapshot.hasError) {
                return Center(
                  child: Text('Error: ${activitiesSnapshot.error}'),
                );
              }

              if (!activitiesSnapshot.hasData || activitiesSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No activities found for your interests.'),
                );
              }

              // Δεδομένα δραστηριοτήτων
              final activities = activitiesSnapshot.data!.docs;

              return ListView.builder(
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index].data() as Map<String, dynamic>;

                  final name = activity['name'] ?? 'Untitled Activity';
                  final description = activity['description'] ?? 'No description available';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text(description),
                      onTap: () {
                        // Προαιρετική λειτουργία: εμφάνιση λεπτομερειών δραστηριότητας
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}