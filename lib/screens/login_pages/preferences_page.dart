import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/rounded_button.dart';
import '../profile_pages/avatar_selection.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final List<String> interests = [
    'Pottery', 'Music', 'Cars', 'Extreme Sports', 'Animals', 'Sea', 'Mountain',
    'Movies', 'Books', 'Food', 'Dance', 'Sports', 'Drinking',
    'Art', 'Volunteering', 'Comedy', 'Games', 'Beauty',
    'Fitness', 'Theater', 'Nightlife'
  ];

  final List<String> selectedInterests = [];

  void toggleSelection(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  Future<bool> savePreferences() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'selectedCategories': selectedInterests,
        });
        return true;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving preferences: $e'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return false;
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User is not logged in!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                image: AssetImage('assets/images/background_small.jpg'), // Το wallpaper
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  const Text(
                    'Choose your interests!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pick 3 or more categories',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Scrollable Interests List
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: interests.map((interest) {
                          final isSelected = selectedInterests.contains(interest);
                          return GestureDetector(
                            onTap: () => toggleSelection(interest),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFE541F1),
                                          Color.fromARGB(255, 149, 57, 155),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                color: !isSelected
                                    ? const Color(0xFF9500FB).withOpacity(0.27)
                                    : null,
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.transparent,
                                ),
                              ),
                              child: Text(
                                interest,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  // Rounded Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: RoundedButton(
                      text: "Ready",
                      onPressed: () async {
                        if (selectedInterests.length >= 3) {
                          await savePreferences();

                          final args =
                              ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
                          final origin = args?['origin'];

                          if (origin == 'signup') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AvatarSelectionPage(),
                                settings:
                                    const RouteSettings(arguments: {'origin': 'preferences'}),
                              ),
                            );
                          } else if (origin == 'profile') {
                            Navigator.pop(context, true);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select at least 3 categories'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
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