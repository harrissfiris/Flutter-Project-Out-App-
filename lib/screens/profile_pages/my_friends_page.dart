import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/rounded_button.dart';
import 'friends_profile_page.dart';
import 'qr_scanner_page.dart';

class MyFriendsPage extends StatelessWidget {
  const MyFriendsPage({super.key});

 Future<List<Map<String, dynamic>>> _getUserFriends() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return []; // Επιστροφή κενής λίστας αν δεν υπάρχει συνδεδεμένος χρήστης
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    List<String> friendsIds = List<String>.from(userDoc['friends'] ?? []);

    if (friendsIds.isEmpty) return []; // Επιστροφή κενής λίστας αν δεν υπάρχουν φίλοι

    QuerySnapshot friendsQuery = await FirebaseFirestore.instance
        .collection('users')
        .where(FieldPath.documentId, whereIn: friendsIds)
        .get();

    return friendsQuery.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'id': doc.id,
        'username': data['username'] ?? 'Unknown',
        'avatar': data['avatar'] ?? '',
      };
    }).toList();
  } catch (e) {
    debugPrint("Error fetching friends: $e");
    return []; // Επιστροφή κενής λίστας σε περίπτωση λάθους
  }
}

  Future<String> _fetchAvatarUrl(String avatarName) async {
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
    return Scaffold(
      resizeToAvoidBottomInset: false, // Αποτρέπει το "ανέβασμα" των στοιχείων
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
            // Main Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Friends',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Friends List
                  Expanded(
  child: FutureBuilder<List<Map<String, dynamic>>>(
    future: _getUserFriends(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      // Αν το snapshot έχει σφάλμα, απλώς δείχνουμε φιλικό μήνυμα αντί για το error
      if (snapshot.hasError) {
        debugPrint('Error: ${snapshot.error}');
        return const Center(
          child: Text(
            'Something went wrong. Please try again later.',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        );
      }

      final friends = snapshot.data ?? [];

      // Φιλική εμφάνιση φίλων αν υπάρχουν
      return ListView.builder(
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          return FutureBuilder<String>(
            future: _fetchAvatarUrl(friend['avatar']),
            builder: (context, avatarSnapshot) {
              if (avatarSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final avatarUrl = avatarSnapshot.data ?? 'assets/icons/PROFILE.png';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: avatarUrl.startsWith('assets')
                        ? AssetImage(avatarUrl) as ImageProvider
                        : NetworkImage(avatarUrl),
                  ),
                  title: Text(
                    '@${friend['username']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FriendsProfilePage(
                          friendId: friend['id'],
                          fromAddFriendsPage: false,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    },
  ),
),
                  // Add Friends Button
                  RoundedButton(
                    text: "Add new friends",
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerPage(),
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
    );
  }
}