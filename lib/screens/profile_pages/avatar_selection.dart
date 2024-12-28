import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/rounded_button.dart';
import '../login_pages/welcome_page.dart';

class AvatarSelectionPage extends StatefulWidget {
  const AvatarSelectionPage({super.key});

  @override
  State<AvatarSelectionPage> createState() => _AvatarSelectionPageState();
}

class _AvatarSelectionPageState extends State<AvatarSelectionPage> {
  final List<String> avatarPaths = [
    'avatar1.png',
    'avatar2.png',
    'avatar3.png',
    'avatar4.png',
    'avatar5.png',
    'avatar6.png',
    'avatar7.png',
    'avatar8.png',
    'avatar9.png',
    'avatar10.png',
    'avatar11.png',
    'avatar12.png',
  ];

  Map<String, String> avatarUrls = {};
  String? selectedAvatar;

  @override
  void initState() {
    super.initState();
    _loadAvatarUrls();
  }

  Future<void> _loadAvatarUrls() async {
  try {
    for (final path in avatarPaths) {
      final ref = FirebaseStorage.instance.ref('avatars/$path');
      final url = await ref.getDownloadURL();
      
      if (mounted) { // Ελέγχει αν το widget είναι ακόμη ενεργό
        setState(() {
          avatarUrls[path] = url;
        });
      }
    }
  } catch (e) {
    if (mounted) { // Ελέγχει αν το widget είναι ακόμη ενεργό
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading avatars: $e')),
      );
    }
  }
}

  Future<void> saveAvatar() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && selectedAvatar != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'avatar': selectedAvatar,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated successfully!')),
        );

        // Διαφορετική πλοήγηση ανάλογα με το origin
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final origin = args?['origin'];

        if (origin == 'preferences') {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const WelcomePage()),
  );
} else if (origin == 'profile') {
          Navigator.pop(context, true); // Επιστρέφει true για να ανανεωθεί η εικόνα
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an avatar!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating avatar: $e')),
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
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Choose Avatar',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: avatarPaths.length,
                      itemBuilder: (context, index) {
                        final avatarPath = avatarPaths[index];
                        final url = avatarUrls[avatarPath];

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAvatar = avatarPath;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selectedAvatar == avatarPath
                                    ? Colors.deepPurple
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                            child: ClipOval(
                              child: url != null
                                  ? Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error, color: Colors.red);
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    )
                                  : const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  RoundedButton(
                    text: 'Choose Avatar',
                    onPressed: saveAvatar,
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