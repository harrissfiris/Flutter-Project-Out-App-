import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../main_app.dart';
import '../../widgets/rounded_button.dart';
import '../profile_pages/friends_profile_page.dart';

class PlanConfirmationPage extends StatelessWidget {
  const PlanConfirmationPage({super.key});

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

  Future<String> fetchAvatarUrl(String avatarName) async {
    if (avatarName.isEmpty) {
      return 'assets/icons/PROFILE.png';
    }

    try {
      final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
      return await ref.getDownloadURL();
    } catch (e) {
      return 'assets/icons/PROFILE.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments is! Map<String, String>) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Invalid plan details provided.'),
        ),
      );
    }

    final planId = arguments['planId'];

    if (planId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Plan Confirmation'),
        ),
        body: const Center(
          child: Text('Plan ID not found.'),
        ),
      );
    }

    Future<Map<String, dynamic>> getPlanDetails() async {
      DocumentSnapshot planDoc = await FirebaseFirestore.instance
          .collection('plans')
          .doc(planId)
          .get();

      if (!planDoc.exists) {
        throw Exception('Plan not found');
      }

      return planDoc.data() as Map<String, dynamic>;
    }

    return Scaffold(
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
            child: FutureBuilder<Map<String, dynamic>>(
              future: getPlanDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: Text('Plan not found.'),
                  );
                }

                final plan = snapshot.data!;
                final List<String> participants = List<String>.from(plan['participants'] ?? []);
                final DateTime dateTime = (plan['dateTime'] as Timestamp).toDate();
                final String notes = plan['notes'] ?? '';
                final String activityId = plan['activityId'];

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
                    final String photoName = activity['Photo'];

                    return FutureBuilder<String>(
                      future: fetchActivityPhoto(photoName),
                      builder: (context, photoSnapshot) {
                        final photoUrl = photoSnapshot.data ?? '';

                        return Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 50),
                              const Center(
                                child: Text(
                                  "Your plan is confirmed!",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
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
                      const Center(child: Text('Image not available')),
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
                                    if (notes.isNotEmpty) const SizedBox(height: 10),
                                    if (notes.isNotEmpty)
                                      Text(
                                        notes,
                                        style: const TextStyle(
                                          fontSize: 18,
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
                                  if (participantSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(child: CircularProgressIndicator());
                                  }

                                  final participantDetails =
                                      participantSnapshot.data ?? [];

                                  return SizedBox(
                                    height: 120,
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
                                                                    backgroundImage:
                                                                        NetworkImage(avatarUrl),
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
                              const Spacer(),
                              RoundedButton(
                                text: "Back to home screen",
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainApp(),
                                    ),
                                  );
                                },
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

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}