import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../widgets/category_icon.dart';
import '../profile_pages/profile_settings.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<String> interests = []; // Κατηγορίες του χρήστη
  String username = ''; // Όνομα χρήστη

  @override
  void initState() {
    super.initState();
    fetchUserData(); // Φόρτωση δεδομένων χρήστη
  }

  Future<void> fetchUserData() async {
    try {
      // Παίρνουμε το UID του χρήστη από το Authentication
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Διαβάζουμε τα δεδομένα από τη Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        setState(() {
          username = userDoc['username'] ?? ''; // Όνομα χρήστη
          interests = List<String>.from(userDoc['selectedCategories'] ?? []);
        });
      }
    } catch (e) {
      // Αν υπάρχει πρόβλημα, εμφάνισε ένα μήνυμα
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small_logo.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header Row: Settings, Profile Image, QR Code
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

                          // Ενημέρωση του username αν επιστραφεί νέο όνομα
                          if (updatedUsername != null && updatedUsername is String) {
                            setState(() {
                              username = updatedUsername;
                            });
                          }
                        },
                      ),
                      const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/icons/PROFILE.png'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.qr_code, size: 28, color: Colors.black),
                        onPressed: () {
                          Navigator.pushNamed(context, '/qr_code_page');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Username
                  Text(
                    '@$username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // My Friends Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/my_friends_page');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEDE7F6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text(
                      "My friends",
                      style: TextStyle(
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // My Interests
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Interests",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Interests List (Scrollable Horizontal List)
                  SizedBox(
                    height: 60,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}