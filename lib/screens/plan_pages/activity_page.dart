import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/plus_button.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String? activityId = ModalRoute.of(context)?.settings.arguments as String?;

    if (activityId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Activity Page'),
        ),
        body: const Center(
          child: Text('Activity ID not found.'),
        ),
      );
    }

    Future<Map<String, dynamic>> getActivityDetails() async {
      final activityDoc = await FirebaseFirestore.instance
          .collection('activities')
          .doc(activityId)
          .get();

      if (!activityDoc.exists) {
        throw Exception('Activity not found');
      }

      final activityData = activityDoc.data() as Map<String, dynamic>;
      final photoName = activityData['Photo'];

      // Ανάκτηση του URL από το Firebase Storage
      if (photoName != null && photoName.isNotEmpty) {
        final photoUrl = await FirebaseStorage.instance
            .ref('activity pictures/$photoName')
            .getDownloadURL();
        activityData['PhotoUrl'] = photoUrl; // Προσθήκη του URL στο activityData
      } else {
        activityData['PhotoUrl'] = null; // Αν δεν υπάρχει εικόνα
      }

      return activityData;
    }

    return Scaffold(
      extendBodyBehindAppBar: true, // Το AppBar πίσω από το περιεχόμενο
appBar: AppBar(
  backgroundColor: Colors.transparent, // Διαφάνεια
  elevation: 0, // Αφαιρεί τη σκιά
  iconTheme: const IconThemeData(color: Colors.black), // Χρώμα του back button
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios), // Χρησιμοποιεί το "<" για όλα τα platforms
    onPressed: () {
      Navigator.pop(context);
    },
  ),
),
      body: Stack(
        children: [
          // Wallpaper
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                FutureBuilder<Map<String, dynamic>>(
                  future: getActivityDetails(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('Activity not found.'));
                    }

                    final activity = snapshot.data!;
                    final photoUrl = activity['PhotoUrl']; // URL της εικόνας

                    return Padding(
                      padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 0),
                          // Εικόνα του Activity με overlay κείμενο
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 400,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                    ),
                                    child: photoUrl != null
                                        ? Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Center(child: Text('Image not available')),
                                          )
                                        : const Center(child: Text('No image available')),
                                  ),
                                  Container(
                                    width: 400,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.black.withOpacity(0.6),
                                          Colors.transparent
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          activity['Name'] ?? 'Unnamed Activity',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Text(
                                          '@${activity['Organizer'] ?? 'Unknown Organizer'}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Όνομα και Λεπτομέρειες
                          Text(
                            activity['Name'] ?? 'Unnamed Activity',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            activity['Location'] ?? 'No location provided',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            activity['Description'] ?? 'No description available',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),

                          // Σύνδεσμος και Τηλέφωνο
                          if (activity['Link'] != null)
                            InkWell(
                              onTap: () {
                                // Λογική για άνοιγμα συνδέσμου
                              },
                              child: Text(
                                activity['Link'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          if (activity['Phone'] != null)
                            Text(
                              activity['Phone'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Plus Button
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: PlusButton(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/plan_creation_page',
                                    arguments: activityId,
                                  );
                                },
                                labelText: "Create a Plan",
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}