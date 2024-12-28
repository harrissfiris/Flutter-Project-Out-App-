import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'friends_profile_page.dart';
import 'qr_scanner_page.dart';


class AddFriendsPage extends StatefulWidget {
 const AddFriendsPage({super.key});


 @override
 _AddFriendsPageState createState() => _AddFriendsPageState();
}


class _AddFriendsPageState extends State<AddFriendsPage> {
 final TextEditingController _searchController = TextEditingController();
 List<Map<String, String>> _searchResults = [];
 bool _isSearching = false;


 Future<List<String>> _getUserFriends() async {
   try {
     User? user = FirebaseAuth.instance.currentUser;
     if (user == null) {
       throw Exception("User not logged in");
     }
     DocumentSnapshot userDoc = await FirebaseFirestore.instance
         .collection('users')
         .doc(user.uid)
         .get();
     return List<String>.from(userDoc['friends'] ?? []);
   } catch (e) {
     debugPrint('Error fetching friends list: $e');
     return [];
   }
 }


Future<void> _searchUsers(String query) async {
  if (query.isEmpty) {
    setState(() {
      _searchResults = [];
      _isSearching = false;
    });
    return;
  }

  setState(() {
    _isSearching = true;
  });

  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception("User not logged in");
    }
    List<String> friends = await _getUserFriends();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    setState(() {
      _searchResults = querySnapshot.docs
          .where((doc) => !friends.contains(doc.id) && doc.id != currentUser.uid)
          .map((doc) {
            final data = doc.data(); // Convert to Map
            return {
              'id': doc.id,
              'username': data['username']?.toString() ?? '',
              'avatar': data.containsKey('avatar') && data['avatar'] != null
                  ? data['avatar'].toString()
                  : '', // Default empty if not exists
            };
          }).toList();
      _isSearching = false;
    });
  } catch (e) {
    debugPrint('Error searching users: $e');
    setState(() {
      _isSearching = false;
    });
  }
}

Future<String?> _fetchAvatarUrl(String avatarName) async {
  if (avatarName.isEmpty) {
    return null; // Αν δεν υπάρχει όνομα avatar, επιστρέφει null
  }
  try {
    final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
    return await ref.getDownloadURL();
  } catch (e) {
    debugPrint('Error fetching avatar: $e');
    return null; // Σε αποτυχία επιστρέφουμε null
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
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add Friends',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.black),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QRScannerPage(),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search users by username...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                        onChanged: _searchUsers,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isSearching)
                  const Center(child: CircularProgressIndicator())
                else if (_searchResults.isEmpty &&
                    _searchController.text.isNotEmpty)
                  const Center(
                    child: Text('No users found.'),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return FutureBuilder<String?>(
                          future: _fetchAvatarUrl(user['avatar'] ?? ''),
                          builder: (context, snapshot) {
                            final avatarUrl = snapshot.data;

                            return ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[200],
                                backgroundImage: avatarUrl != null
                                    ? NetworkImage(avatarUrl)
                                    : const AssetImage('assets/icons/PROFILE.png')
                                        as ImageProvider,
                              ),
                              title: Text(user['username']!),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FriendsProfilePage(
                                      friendId: user['id']!,
                                      fromAddFriendsPage: true,
                                    ),
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
          ),
        ),
      ],
    ),
  );
}
}