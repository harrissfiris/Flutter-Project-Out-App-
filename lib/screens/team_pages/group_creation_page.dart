import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_text_field.dart';

class GroupCreationPage extends StatefulWidget {
  const GroupCreationPage({super.key});

  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> friends = []; // Friends list with details
  List<String> selectedFriends = []; // IDs of selected friends

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
  try {
    User? user = _auth.currentUser;
    if (user == null) throw Exception("User not logged in!");

    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    List<String> friendsIds = List<String>.from(userDoc['friends'] ?? []);

    if (friendsIds.isNotEmpty) {
      QuerySnapshot friendsQuery = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendsIds)
          .get();

      setState(() {
        friends = friendsQuery.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'username': data['username'] ?? 'Unknown',
            'avatar': data.containsKey('avatar') ? data['avatar'] : '',
          };
        }).toList();
      });
    } else {
      // Αν η λίστα είναι κενή, απλά δεν κάνουμε τίποτα
      setState(() {
        friends = [];
      });
    }
  } catch (e) {
    if (mounted) {
      debugPrint('Error loading friends: $e');
    }
  }
}

  Future<String> _fetchAvatarUrl(String avatarName) async {
    if (avatarName.isEmpty) {
      return 'assets/icons/PROFILE.png'; // Default avatar
    }

    try {
      final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
      return await ref.getDownloadURL();
    } catch (e) {
      return 'assets/icons/PROFILE.png'; // Return default avatar on error
    }
  }

  Future<void> _createGroup() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) throw Exception("User not logged in!");

      final groupData = {
        'name': _groupNameController.text.trim(),
        'members': [user.uid, ...selectedFriends],
        'createdBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      DocumentReference groupRef = await _firestore.collection('group').add(groupData);

      List<String> allMembers = [user.uid, ...selectedFriends];
      for (String memberId in allMembers) {
        await _firestore.collection('users').doc(memberId).update({
          'groups': FieldValue.arrayUnion([groupRef.id]),
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created successfully!')),
      );

      Navigator.pop(context, groupRef.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $e')),
      );
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
            // Content
            child: Padding(
              padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Create new group",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Group Name Input
                  CustomTextField(
                    controller: _groupNameController,
                    hintText: "Group Name",
                  ),
                  const SizedBox(height: 20),

                  // Members Section
                  const Text(
                    "Select members:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Scrollable Friends List
                  Expanded(
  child: friends.isEmpty
      ? const Center(
          child: Text(
            'Add some friends before creating a group!',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        )
      : ListView.builder(
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            final isSelected = selectedFriends.contains(friend['id']);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Adds spacing between items
              child: FutureBuilder<String>(
                future: _fetchAvatarUrl(friend['avatar']),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final avatarUrl = snapshot.data ?? 'assets/icons/PROFILE.png';

                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: avatarUrl.startsWith('assets')
                          ? AssetImage(avatarUrl) as ImageProvider
                          : NetworkImage(avatarUrl),
                    ),
                    title: Text(
                      '@${friend['username']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.purple)
                        : const Icon(Icons.circle_outlined, color: Colors.grey),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedFriends.remove(friend['id']);
                        } else {
                          selectedFriends.add(friend['id']);
                        }
                      });
                    },
                  );
                },
              ),
            );
          },
        ),
),
                  const SizedBox(height: 20),

                  // Create Group Button
                  RoundedButton(
                    text: "Create group",
                    onPressed: () {
                      if (_groupNameController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Group name cannot be empty!')),
                        );
                        return;
                      }
                      if (selectedFriends.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select at least one friend!')),
                        );
                        return;
                      }
                      _createGroup();
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

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }
}