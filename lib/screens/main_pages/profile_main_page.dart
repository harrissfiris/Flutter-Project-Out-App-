import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../widgets/category_icon.dart';
import '../../widgets/plan_card.dart';
import '../profile_pages/profile_settings.dart';
import '../profile_pages/avatar_selection.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> interests = [];
  String username = '';
  String uid = '';
  String avatar = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        uid = user.uid;

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        String avatarName = userDoc['avatar'] ?? '';
        String avatarUrl = '';

        if (avatarName.isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
            avatarUrl = await ref.getDownloadURL();
          } catch (e) {
            avatarUrl = '';
          }
        }

        setState(() {
          username = userDoc['username'] ?? '';
          interests = List<String>.from(userDoc['selectedCategories'] ?? []);
          avatar = avatarUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPastPlansWithPhotos() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception("User document does not exist");
    }

    final planIds = List<String>.from(userDoc.data()?['plans'] ?? []);

    List<Map<String, dynamic>> pastPlansWithPhotos = [];
    final now = DateTime.now();

    for (final planId in planIds) {
      final planDoc = await FirebaseFirestore.instance.collection('plans').doc(planId).get();
      if (planDoc.exists) {
        final activityId = planDoc.data()?['activityId'];
        final planDate = (planDoc.data()?['dateTime'] as Timestamp?)?.toDate();

        if (planDate == null || planDate.isAfter(now)) continue;

        if (activityId != null) {
          final activityDoc = await FirebaseFirestore.instance.collection('activities').doc(activityId).get();
          if (activityDoc.exists) {
            final photoName = activityDoc.data()?['Photo'];
            final activityName = activityDoc.data()?['Name'];
            if (photoName != null && activityName != null) {
              final photoUrl = await FirebaseStorage.instance
                  .ref('activity pictures/$photoName')
                  .getDownloadURL();
              pastPlansWithPhotos.add({
                'planId': planId,
                'photoUrl': photoUrl,
                'activityName': activityName,
                'planDate': planDate,
              });
            }
          }
        }
      }
    }

    pastPlansWithPhotos.sort((a, b) {
      final dateA = a['planDate'] as DateTime?;
      final dateB = b['planDate'] as DateTime?;
      return dateB?.compareTo(dateA ?? DateTime(1970)) ?? 0;
    });

    return pastPlansWithPhotos.take(10).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small_logo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView( // Ενεργοποίηση scroll
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 45),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.settings, size: 28, color: Colors.black),
                        onPressed: () async {
                          final updatedUsername = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ProfileSettingsPage()),
                          );

                          if (updatedUsername != null && updatedUsername is String) {
                            setState(() {
                              username = updatedUsername;
                            });
                          }
                        },
                      ),
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AvatarSelectionPage(),
    settings: const RouteSettings(arguments: {'origin': 'profile'}),
  ),
);

                          if (result == true) {
                            fetchUserData();
                          }
                        },
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: avatar.isNotEmpty
                              ? NetworkImage(avatar)
                              : const AssetImage('assets/icons/PROFILE.png') as ImageProvider,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code, size: 28, color: Colors.black),
                        onPressed: () {
                          _showQrDialog(context, uid, username);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '@$username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
  onTap: () {
    Navigator.pushNamed(context, '/my_friends_page');
  },
  child: const SizedBox(
                    height: 40,
                    child: CategoryIcon(
    text: "My friends",
    fontSize: 18,
  ),
                  ),
),
                      const SizedBox(width: 10),
                      GestureDetector(
  onTap: () async {
    final dynamic result = await Navigator.pushNamed(
      context,
      '/preferences',
      arguments: {'origin': 'profile'},
    );

    if (result == true) {
      fetchUserData();
    }
  },
  child: const SizedBox(
                    height: 40,
                    child: CategoryIcon(
    text: "Change Interests",
    fontSize: 18,
  ),
                  ),
),

                    ],
                  ),
                  const SizedBox(height: 30),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Interests",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 55,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: interests.map((interest) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: CategoryIcon(text: interest),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Past Plans",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _fetchPastPlansWithPhotos(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final pastPlans = snapshot.data ?? [];

                      if (pastPlans.isEmpty) {
                        return const Center(
                          child: Text(
                            'No past plans available.',
                            style: TextStyle(color: Colors.black),
                          ),
                        );
                      }

                      return SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: pastPlans.length,
                          itemBuilder: (context, index) {
                            final plan = pastPlans[index];
                            return PlanCard(
                              planId: plan['planId'],
                              photoUrl: plan['photoUrl'],
                              activityName: plan['activityName'],
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
          ),
        ],
      ),
    );
  }

  void _showQrDialog(BuildContext context, String uid, String username) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    QrImageView(
                      data: uid,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '@$username',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}