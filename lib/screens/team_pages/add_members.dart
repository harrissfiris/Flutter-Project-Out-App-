import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/rounded_button.dart';

class AddMembers extends StatefulWidget {
  final String groupId;

  const AddMembers({super.key, required this.groupId});

  @override
  State<AddMembers> createState() => _AddMembersState();
}

class _AddMembersState extends State<AddMembers> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> filteredFriends = [];
  List<String> selectedFriends = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFriends();
    searchController.addListener(_filterSearchResults);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in!");

      // Φέρε τους φίλους του χρήστη
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final friendsIds = List<String>.from(userDoc.data()?['friends'] ?? []);

      // Φέρε τα μέλη του group
      final groupDoc = await FirebaseFirestore.instance.collection('group').doc(widget.groupId).get();
      final membersIds = List<String>.from(groupDoc.data()?['members'] ?? []);

      // Φίλτραρε μόνο φίλους που δεν είναι μέλη
      final filteredFriendsIds = friendsIds.where((id) => !membersIds.contains(id)).toList();

      if (filteredFriendsIds.isNotEmpty) {
        final friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: filteredFriendsIds)
            .get();

        final loadedFriends = friendsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['username'] ?? 'Unknown',
            'avatar': data['avatar'] ?? '',
          };
        }).toList();

        setState(() {
          friends = loadedFriends;
          filteredFriends = friends;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friends: $e')),
      );
    }
  }

  void _filterSearchResults() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredFriends = friends
          .where((friend) => friend['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<String?> _fetchAvatarUrl(String avatarName) async {
    if (avatarName.isEmpty) return null;

    try {
      final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _addMembersToGroup() async {
  try {
    final batch = FirebaseFirestore.instance.batch();
    final groupRef = FirebaseFirestore.instance.collection('group').doc(widget.groupId);

    // Προσθήκη των νέων μελών στο group
    batch.update(groupRef, {
      'members': FieldValue.arrayUnion(selectedFriends),
    });

    // Προσθήκη του groupId στο πεδίο "groups" των χρηστών
    for (String userId in selectedFriends) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
      batch.update(userRef, {
        'groups': FieldValue.arrayUnion([widget.groupId]),
      });
    }

    // Εκτέλεση του batch update
    await batch.commit();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Members added successfully!')),
    );

    Navigator.pop(context, true); // Επιστροφή στο TeamPage με refresh
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error adding members: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Add Friends to Group",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16.0),
  child: TextField(
    controller: searchController,
    decoration: InputDecoration(
      hintText: "Search friends...",
      prefixIcon: const Icon(Icons.search),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    onTap: () {
      setState(() {
        isSearching = true;
      });
    },
    onChanged: (value) => _filterSearchResults(),
  ),
),
                const SizedBox(height: 10),
                Expanded(
  child: ListView.separated(
    separatorBuilder: (context, index) => const Divider(
      height: 0,
      color: Colors.transparent,
    ),
    itemCount: filteredFriends.length,
    itemBuilder: (context, index) {
      final friend = filteredFriends[index];
      final isSelected = selectedFriends.contains(friend['id']);

      return FutureBuilder<String?>(
        future: _fetchAvatarUrl(friend['avatar']),
        builder: (context, snapshot) {
          final avatarUrl = snapshot.data;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey[200],
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.black)
                  : ClipOval(
                      child: Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    ),
            ),
            title: Text(friend['name'], style: const TextStyle(fontSize: 16)),
            subtitle: const Text('Friend'),
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
      );
    },
  ),
),
                        Padding(
  padding: const EdgeInsets.all(16.0),
  child: RoundedButton(
    text: "Add Members",
    onPressed: selectedFriends.isNotEmpty
        ? () {
            _addMembersToGroup();
          }
        : () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please choose at least one member to add!'),
              ),
            );
          },
  ),
),
              ],
            ),
          ),
        ],
      ),
    );
  }
}