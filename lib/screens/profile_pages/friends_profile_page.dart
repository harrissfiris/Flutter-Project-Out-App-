import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/category_icon.dart';


class FriendsProfilePage extends StatelessWidget {
  final String friendId;
  final bool fromAddFriendsPage;


  const FriendsProfilePage({
    super.key,
    required this.friendId,
    this.fromAddFriendsPage = false,
  });


  Future<Map<String, dynamic>> _getFriendDetails() async {
    try {
      DocumentSnapshot friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(friendId)
          .get();


      String avatarName = friendDoc['avatar'] ?? '';
      String avatarUrl = '';


      if (avatarName.isNotEmpty) {
        try {
          final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
          avatarUrl = await ref.getDownloadURL();
        } catch (e) {
          avatarUrl = '';
        }
      }


      return {
        ...friendDoc.data() as Map<String, dynamic>,
        'avatarUrl': avatarUrl,
      };
    } catch (e) {
      throw Exception("Error fetching friend details: $e");
    }
  }


  Future<void> _addFriend(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in!");


      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'friends': FieldValue.arrayUnion([friendId]),
      });


      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Friend added successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding friend: $e'),
          duration: const Duration(seconds: 2),
        ),
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
          FutureBuilder<Map<String, dynamic>>(
            future: _getFriendDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }


              final friend = snapshot.data!;


              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: friend['avatarUrl'].isNotEmpty
                            ? NetworkImage(friend['avatarUrl'])
                            : const AssetImage('assets/icons/PROFILE.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 20),
                      // Username
                      Text(
                        '@${friend['username']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Interests
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Interests",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Interests List (from Profile Page)
                      SizedBox(
                        height: 60,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: List<String>.from(friend['selectedCategories'] ?? [])
                              .map((interest) => Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: CategoryIcon(text: interest),
                                  ))
                              .toList(),
                        ),
                      ),
                      const Spacer(),
                      // Add Friend Button
                      if (fromAddFriendsPage)
  Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0), // Προαιρετικό padding
    child: RoundedButton(
      text: 'Add Friend',
      onPressed: () => _addFriend(context),
    ),
  ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}










