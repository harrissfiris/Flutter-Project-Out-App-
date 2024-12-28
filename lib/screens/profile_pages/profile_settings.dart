import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_text_field.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  final TextEditingController _usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String currentUsername = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        setState(() {
          currentUsername = userDoc['username'] ?? '';
          _usernameController.text = currentUsername;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading user data: $e')),
      );
    }
  }

  Future<bool> _isUsernameUnique(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return querySnapshot.docs.isEmpty;
  }

  Future<void> _saveChanges() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        String updatedUsername = _usernameController.text.trim();

        if (updatedUsername.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username cannot be empty!')),
          );
          return;
        }

        if (updatedUsername != currentUsername) {
          bool isUnique = await _isUsernameUnique(updatedUsername);
          if (!isUnique) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Username is already taken. Please choose another one.'),
              ),
            );
            return;
          }
        }

        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'username': updatedUsername});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Changes saved successfully!')),
        );

        Navigator.pop(context, updatedUsername);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving changes: $e')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Το AppBar πίσω από το περιεχόμενο
appBar: AppBar(
  backgroundColor: Colors.transparent, // Διαφάνεια
  elevation: 0, // Αφαιρεί τη σκιά
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios), // Χρησιμοποιεί το "<" για όλες τις πλατφόρμες
    onPressed: () {
      Navigator.pop(context); // Επιστροφή στην προηγούμενη οθόνη
    },
  ),
  actions: [
    IconButton(
      icon: const Icon(Icons.exit_to_app, color: Colors.black),
      onPressed: _logout, // Ενέργεια για αποσύνδεση
    ),
  ],
),
      body: Stack(
        children: [
          // Wallpaper
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small.jpg'), // Το wallpaper
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const SizedBox(height: 80),

                  // Title
                  const Center(
                    child: Text(
                      "Edit Username",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Username Field
                  CustomTextField(
                    hintText: "Username",
                    controller: _usernameController,
                  ),

                  const SizedBox(height: 20),

                  const Spacer(),

                  // Save Changes Button
                  RoundedButton(
                    text: "Save changes",
                    onPressed: _saveChanges,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}