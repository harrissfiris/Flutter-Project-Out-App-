import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/plus_button.dart';
import '../../widgets/back_button_widget.dart';

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

  Future<void> _saveChanges() async {
  try {
    User? user = _auth.currentUser;
    if (user != null) {
      String updatedUsername = _usernameController.text.trim();
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'username': updatedUsername});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully!')),
      );

      // Επιστροφή του νέου username στο προηγούμενο screen
      Navigator.pop(context, updatedUsername);
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error saving changes: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  const BackButtonWidget(),

                  const SizedBox(height: 20),

                  // Title
                  const Center(
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Avatar with Plus Button
                  Center(
                    child: Stack(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/icons/PROFILE.png'),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: PlusButton(
                            onTap: () {
                              Navigator.pushNamed(context, '/avatar_selection');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Username Field
                  CustomTextField(
                    hintText: "Username",
                    controller: _usernameController,
                  ),

                  const SizedBox(height: 20),

                  // Change Interests
                  Row(
                    children: [
                      const Text(
                        "Do you want to change your ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/preferences');
                        },
                        child: const Text(
                          "interests",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const Text("?", style: TextStyle(fontSize: 16)),
                    ],
                  ),

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