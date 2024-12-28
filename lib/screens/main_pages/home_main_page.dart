import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart'; // Πακέτο για την τοποθεσία
import 'dart:math'; // Για τον υπολογισμό της απόστασης
import '../../widgets/activity_card.dart';


class HomePage extends StatelessWidget {
 final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  HomePage({super.key});


 Future<Position> _determinePosition() async {
 bool serviceEnabled;
 LocationPermission permission;


 // Βεβαιωθείτε ότι το GPS είναι ενεργοποιημένο
 serviceEnabled = await Geolocator.isLocationServiceEnabled();
 if (!serviceEnabled) {
   throw Exception('Location services are disabled.');
 }


 // Ελέγξτε την άδεια
 permission = await Geolocator.checkPermission();
 if (permission == LocationPermission.denied) {
   permission = await Geolocator.requestPermission();
   if (permission == LocationPermission.denied) {
     throw Exception('Location permissions are denied.');
   }
 }


 // Αν ο χρήστης έχει απορρίψει μόνιμα τις άδειες
 if (permission == LocationPermission.deniedForever) {
   throw Exception(
       'Location permissions are permanently denied. Please enable them from the device settings.');
 }


 // Επιστροφή της τρέχουσας τοποθεσίας
 return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}


Future<List<Map<String, dynamic>>> fetchSuggestedActivities() async {
  // Λήψη ενδιαφερόντων του χρήστη
  final userInterests = await _getUserInterests();

  // Αν δεν υπάρχουν επιλεγμένα ενδιαφέροντα, επιστρέφουμε κενή λίστα
  if (userInterests.isEmpty) {
    return [];
  }

  // Ανάκτηση όλων των activities που έχουν ως Interest κάποια από τα selectedCategories
  final activitiesSnapshot = await _firestore
      .collection('activities')
      .where('Interest', whereIn: userInterests)
      .get();

  List<Map<String, dynamic>> activities = [];

  // Πρόσθεση των activities με τα απαιτούμενα πεδία
  for (var doc in activitiesSnapshot.docs) {
    final data = doc.data();

    // Φόρτωση εικόνας από το Firebase Storage
    final photoUrl = await FirebaseStorage.instance
        .ref('activity pictures/${data['Photo']}')
        .getDownloadURL();

    activities.add({
      'activityId': doc.id,
      'photoUrl': photoUrl,
      'activityName': data['Name'],
    });
  }

  // Περιορίζουμε τα αποτελέσματα σε 8 activities
  return activities.take(8).toList();
}


Future<List<Map<String, dynamic>>> fetchNearbyActivities() async {
  // Λήψη τοποθεσίας χρήστη
  Position position = await _determinePosition();
  double userLatitude = position.latitude;
  double userLongitude = position.longitude;

  // Φόρτωση όλων των activities
  final activitiesSnapshot = await _firestore.collection('activities').get();

  // Λίστα για αποθήκευση των δραστηριοτήτων με αποστάσεις
  List<Map<String, dynamic>> activities = [];

  // Υπολογισμός αποστάσεων
  for (var doc in activitiesSnapshot.docs) {
    final data = doc.data();
    final latitude = data['Latitude'] as double?;
    final longitude = data['Longitude'] as double?; // Εδώ χρησιμοποιούμε το σωστό πεδίο

    if (latitude != null && longitude != null) {
      final distance = _calculateDistance(
        userLatitude,
        userLongitude,
        latitude,
        longitude,
      );

      final photoUrl = await FirebaseStorage.instance
          .ref('activity pictures/${data['Photo']}')
          .getDownloadURL();

      activities.add({
        'activityId': doc.id,
        'photoUrl': photoUrl,
        'activityName': data['Name'],
        'distance': distance, // Προσθήκη της απόστασης
      });
    }
  }

  // Ταξινόμηση με βάση την απόσταση (ascending order)
  activities.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));

  // Επιστροφή των 8 κοντινότερων activities
  return activities.take(8).toList();
}


 Future<List<Map<String, dynamic>>> fetchPastActivities() async {
   final userId = FirebaseAuth.instance.currentUser?.uid;


   if (userId == null) {
     throw Exception("User not authenticated");
   }


   final userDoc = await _firestore.collection('users').doc(userId).get();


   if (!userDoc.exists) {
     throw Exception("User document does not exist");
   }


   final planIds = List<String>.from(userDoc.data()?['plans'] ?? []);
   final now = DateTime.now();


   final Set<String> uniqueActivityIds = {};
   List<Map<String, dynamic>> uniquePastActivities = [];


   for (final planId in planIds) {
     final planDoc = await _firestore.collection('plans').doc(planId).get();
     if (planDoc.exists) {
       final activityId = planDoc.data()?['activityId'];
       final planDate = (planDoc.data()?['dateTime'] as Timestamp?)?.toDate();


       if (planDate == null || planDate.isAfter(now)) continue;


       if (activityId != null && !uniqueActivityIds.contains(activityId)) {
         final activityDoc = await _firestore.collection('activities').doc(activityId).get();
         if (activityDoc.exists) {
           final photoName = activityDoc.data()?['Photo'];
           final activityName = activityDoc.data()?['Name'];
           if (photoName != null && activityName != null) {
             final photoUrl = await FirebaseStorage.instance
                 .ref('activity pictures/$photoName')
                 .getDownloadURL();
             uniquePastActivities.add({
               'activityId': activityId,
               'photoUrl': photoUrl,
               'activityName': activityName,
               'planDate': planDate,
             });
             uniqueActivityIds.add(activityId);
           }
         }
       }
     }
   }


   uniquePastActivities.sort((a, b) {
     final dateA = a['planDate'] as DateTime?;
     final dateB = b['planDate'] as DateTime?;
     return dateA?.compareTo(dateB ?? DateTime(1970)) ?? 0;
   });


   return uniquePastActivities;
 }


 Future<List<String>> _getUserInterests() async {
   User? user = FirebaseAuth.instance.currentUser;


   if (user == null) {
     throw Exception("User not logged in!");
   }


   final userDoc = await _firestore.collection('users').doc(user.uid).get();
   final userData = userDoc.data();


   if (userData == null || !userData.containsKey('selectedCategories')) {
     return [];
   }


   return List<String>.from(userData['selectedCategories']);
 }


 double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
   const double radius = 6371; // Radius of the Earth in km
   final double dLat = _degreesToRadians(lat2 - lat1);
   final double dLon = _degreesToRadians(lon2 - lon1);


   final double a = sin(dLat / 2) * sin(dLat / 2) +
       cos(_degreesToRadians(lat1)) *
           cos(_degreesToRadians(lat2)) *
           sin(dLon / 2) *
           sin(dLon / 2);


   final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
   return radius * c; // Distance in km
 }


 double _degreesToRadians(double degrees) {
   return degrees * pi / 180;
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     body: Stack(
       children: [
         // Background Image
         Container(
           decoration: const BoxDecoration(
             image: DecorationImage(
               image: AssetImage('assets/images/background_small_logo.jpg'),
               fit: BoxFit.cover,
             ),
           ),
         ),
         // Main Content
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Center(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    child: Text(
      "Discover your next hangOUT!",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
  ),
),
              const SizedBox(height: 20),
              // Scrollable content below the static header
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    children: [
                      const Text(
                        "We think you might like",
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                     ),
                   ),
                   const SizedBox(height: 16),
                   FutureBuilder<List<Map<String, dynamic>>>(
                     future: fetchSuggestedActivities(),
                     builder: (context, snapshot) {
                       if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(child: CircularProgressIndicator());
                       }


                       if (snapshot.hasError) {
                         return Center(child: Text('Error: ${snapshot.error}'));
                       }


                       final activities = snapshot.data ?? [];


                       if (activities.isEmpty) {
                         return const Center(
                           child: Text(
                             'No activities found.',
                             style: TextStyle(color: Colors.black),
                           ),
                         );
                       }


                       return SizedBox(
                         height: 180,
                         child: ListView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: activities.length,
                           itemBuilder: (context, index) {
                             final activity = activities[index];
                             return ActivityCard(
                               activityId: activity['activityId'],
                               photoUrl: activity['photoUrl'],
                               activityName: activity['activityName'],
                             );
                           },
                         ),
                       );
                     },
                   ),
                   const SizedBox(height: 10),
                   const Text(
                     "Closer to you",
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                     ),
                   ),
                   const SizedBox(height: 10),
                   FutureBuilder<List<Map<String, dynamic>>>(
                     future: fetchNearbyActivities(),
                     builder: (context, snapshot) {
                       if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(child: CircularProgressIndicator());
                       }


                       if (snapshot.hasError) {
                         return Center(child: Text('Error: ${snapshot.error}'));
                       }


                       final activities = snapshot.data ?? [];


                       if (activities.isEmpty) {
                         return const Center(
                           child: Text(
                             'No nearby activities found.',
                            
                             style: TextStyle(color: Colors.black),
                           ),
                         );
                       }


                       return SizedBox(
                         height: 180,
                         child: ListView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: activities.length,
                           itemBuilder: (context, index) {
                             final activity = activities[index];
                             return ActivityCard(
                               activityId: activity['activityId'],
                               photoUrl: activity['photoUrl'],
                               activityName: activity['activityName'],
                             );
                           },
                         ),
                       );
                     },
                   ),
                   const SizedBox(height: 10),
                   const Text(
                     "Do it again",
                     style: TextStyle(
                       fontSize: 20,
                       fontWeight: FontWeight.bold,
                       color: Colors.black,
                     ),
                   ),
                   const SizedBox(height: 10),
                   FutureBuilder<List<Map<String, dynamic>>>(
                     future: fetchPastActivities(),
                     builder: (context, snapshot) {
                       if (snapshot.connectionState == ConnectionState.waiting) {
                         return const Center(child: CircularProgressIndicator());
                       }


                       if (snapshot.hasError) {
                         return Center(child: Text('Error: ${snapshot.error}'));
                       }


                       final pastActivities = snapshot.data ?? [];


                       if (pastActivities.isEmpty) {
                         return const Center(
                           child: Text(
                             'No past activities yet',
                             style: TextStyle(color: Colors.black),
                           ),
                         );
                       }


                       return SizedBox(
                         height: 180,
                         child: ListView.builder(
                           scrollDirection: Axis.horizontal,
                           itemCount: pastActivities.length,
                           itemBuilder: (context, index) {
                             final activity = pastActivities[index];
                             return ActivityCard(
                               activityId: activity['activityId'],
                               photoUrl: activity['photoUrl'],
                               activityName: activity['activityName'],
                             );
                           },
                         ),
                       );
                     },
                   ),
                 ],
               ),
             ),
           ),
       ],
     ),
   ), 
   ], 
   ), 
   );
 }
}
