import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/category_icon.dart';
import '../../main_app.dart';
import '../profile_pages/friends_profile_page.dart';

class ArrangedPlanPage extends StatelessWidget {
  const ArrangedPlanPage({super.key});

  Future<void> removeUserFromPlan(String planId, String userId) async {
    final planRef = FirebaseFirestore.instance.collection('plans').doc(planId);
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final planSnapshot = await transaction.get(planRef);
        final userSnapshot = await transaction.get(userRef);

        if (!planSnapshot.exists) throw Exception("Plan not found");
        if (!userSnapshot.exists) throw Exception("User not found");

        final planData = planSnapshot.data() as Map<String, dynamic>;
        final userData = userSnapshot.data() as Map<String, dynamic>;

        final participants = List<String>.from(planData['participants'] ?? []);
        final userPlans = List<String>.from(userData['plans'] ?? []);

        if (!participants.contains(userId)) throw Exception("User is not a participant in this plan");
        if (!userPlans.contains(planId)) throw Exception("Plan is not associated with this user");

        participants.remove(userId);
        userPlans.remove(planId);

        transaction.update(planRef, {'participants': participants});
        transaction.update(userRef, {'plans': userPlans});
      });
    } catch (e) {
      throw Exception("Error removing user from plan: $e");
    }
  }

  Future<String> fetchAvatarUrl(String avatarName) async {
    if (avatarName.isEmpty) return 'assets/icons/PROFILE.png';

    try {
      final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
      return await ref.getDownloadURL();
    } catch (e) {
      return 'assets/icons/PROFILE.png';
    }
  }

  Future<String> fetchActivityPhoto(String photoName) async {
    try {
      return await FirebaseStorage.instance
          .ref('activity pictures/$photoName')
          .getDownloadURL();
    } catch (e) {
      return '';
    }
  }

  Future<List<Map<String, String>>> getParticipantDetails(List<String> participantIds) async {
    if (participantIds.isEmpty) return [];
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: participantIds)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'username': (data['username'] ?? 'Unknown User').toString(),
          'avatar': (data['avatar'] ?? '').toString(),
        };
      }).toList();
    } catch (e) {
      throw Exception('Error fetching participant details: $e');
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final String? planId = ModalRoute.of(context)?.settings.arguments as String?;
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId == null || planId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Plan Details'),
        ),
        body: const Center(child: Text('Plan ID or User not found.')),
      );
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
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('plans').doc(planId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Plan not found.'));
                }

                final plan = snapshot.data!.data() as Map<String, dynamic>;
                final activityId = plan['activityId'];
                final participants = List<String>.from(plan['participants'] ?? []);
                final dateTime = (plan['dateTime'] as Timestamp).toDate();
                final notes = plan['notes'] ?? '';

                final isPastPlan = dateTime.isBefore(DateTime.now());

                return FutureBuilder<Map<String, dynamic>>(
                  future: FirebaseFirestore.instance
                      .collection('activities')
                      .doc(activityId)
                      .get()
                      .then((doc) => doc.data() ?? {}),
                  builder: (context, activitySnapshot) {
                    if (activitySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final activity = activitySnapshot.data ?? {};
                    final photoName = activity['Photo'];

                    return FutureBuilder<String>(
                      future: fetchActivityPhoto(photoName),
                      builder: (context, photoSnapshot) {
                        final photoUrl = photoSnapshot.data ?? '';

                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30),
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
                                        child: photoUrl.isNotEmpty
                                            ? Image.network(
                                                photoUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    const Center(
                                                        child: Text('Image not available')),
                                              )
                                            : const Center(child: Text('No image available')),
                                      ),
                                      Container(
                                        width: 400,
                                        height: 200,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
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
                                              activity['Name'] ?? 'Unknown Activity',
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
                            // Date, time, and notes
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    '${dateTime.day} ${_monthName(dateTime.month)} ${dateTime.year}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (notes.isNotEmpty)
                                    Text(
                                      notes,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Participants
                            const Center(
                              child: Text(
                                'Participants',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            FutureBuilder<List<Map<String, String>>>(
                              future: getParticipantDetails(participants),
                              builder: (context, participantSnapshot) {
                                if (participantSnapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final participantDetails = participantSnapshot.data ?? [];
                                return SizedBox(
  height: 110,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: participantDetails.length,
    itemBuilder: (context, index) {
      final participant = participantDetails[index];
      final username = participant['username']!;
      final avatarName = participant['avatar']!;
      final userId = participant['id']!;

      return GestureDetector(
        onTap: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FriendsProfilePage(
        friendId: userId,
        fromAddFriendsPage: false,
      ),
    ),
  );
},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: avatarName.isEmpty
                    ? const Icon(Icons.person, size: 30)
                    : FutureBuilder<String>(
                        future: fetchAvatarUrl(avatarName),
                        builder: (context, avatarSnapshot) {
                          final avatarUrl = avatarSnapshot.data ?? '';
                          return avatarUrl.isEmpty
                              ? const Icon(Icons.person, size: 30)
                              : CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(avatarUrl),
                                );
                        },
                      ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                width: 80,
                child: Text(
                  username,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
);
                              },
                            ),
// Add Participants Button
if (!isPastPlan)
  Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/add_participants',
            arguments: {'planId': planId},
          );
        },
        child: const SizedBox(
          width: 200,
          height: 40,
          child: CategoryIcon(
            text: "Add participants",
            fontSize: 18,
          ),
        ),
      ),
    ),
  ),
        
                            const Spacer(),
                            // "I don't want to participate" button
                            if (!isPastPlan)
                              Padding(
  padding: const EdgeInsets.only(bottom: 20.0), // Ελάχιστο κενό από το κάτω μέρος
  child: Center(
    child: TextButton(
      onPressed: () async {
        try {
          await removeUserFromPlan(planId, userId);

          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Your friends will miss you :(")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MainApp(initialPage: 3),
            ),
          );
        } catch (e) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e")),
          );
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red, // Χρώμα του κειμένου
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: const Text(
        "I don't want to participate",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    ),
  ),
),
                          ],
                        ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}