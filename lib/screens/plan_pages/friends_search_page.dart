import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/rounded_button.dart';

class FriendsSearchPage extends StatefulWidget {
  const FriendsSearchPage({super.key});

  @override
  _FriendsSearchPageState createState() => _FriendsSearchPageState();
}

class _FriendsSearchPageState extends State<FriendsSearchPage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> friendsAndGroups = [];
  List<Map<String, dynamic>> filteredFriendsAndGroups = [];
  List<Map<String, dynamic>> recommended = [];
  String? selectedParticipant;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFriendsAndGroups();
    searchController.addListener(_filterSearchResults);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFriendsAndGroups() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in!");

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      final friendsIds = List<String>.from(userDoc.data()?['friends'] ?? []);
      List<Map<String, dynamic>> friends = [];
      if (friendsIds.isNotEmpty) {
        final friendsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where(FieldPath.documentId, whereIn: friendsIds)
            .get();

        friends = friendsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['username'] ?? 'Unknown',
            'avatar': data['avatar'] ?? '',
            'type': 'friend',
          };
        }).toList();
      }

      final groupsIds = List<String>.from(userDoc.data()?['groups'] ?? []);
      List<Map<String, dynamic>> groups = [];
      if (groupsIds.isNotEmpty) {
        for (String groupId in groupsIds) {
          final groupDoc =
              await FirebaseFirestore.instance.collection('group').doc(groupId).get();
          if (groupDoc.exists) {
            groups.add({
              'id': groupDoc.id,
              'name': groupDoc.data()?['name'] ?? 'Unknown Group',
              'avatar': '', // Τα groups δεν έχουν avatar
              'type': 'group',
            });
          }
        }
      }

      final topFriends = friends.take(2).toList();
      final topGroups = groups.take(2).toList();

      setState(() {
        friendsAndGroups = [...friends, ...groups];
        filteredFriendsAndGroups = friendsAndGroups;
        recommended = [...topFriends, ...topGroups];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading friends and groups: $e')),
      );
    }
  }

  void _filterSearchResults() {
    final query = searchController.text.toLowerCase();

    setState(() {
      filteredFriendsAndGroups = friendsAndGroups
          .where((item) => item['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<String?> _fetchAvatarUrl(String avatarName) async {
    if (avatarName.isEmpty) {
      return null;
    }

    try {
      final ref = FirebaseStorage.instance.ref('avatars/$avatarName');
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

 Future<void> _confirmPlan(Map<String, dynamic> planDetails) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in!");

   List<String> participants = [user.uid];

if (selectedParticipant != null) {
  final selectedItem = friendsAndGroups.firstWhere((item) => item['id'] == selectedParticipant);
  final isGroup = selectedItem['type'] == 'group';

  if (isGroup) {
    final groupDoc = await FirebaseFirestore.instance
        .collection('group')
        .doc(selectedParticipant)
        .get();
    final groupMembers = List<String>.from(groupDoc.data()?['members'] ?? []);
    participants.addAll(groupMembers);
  } else {
    participants.add(selectedParticipant!);
  }
}

    participants = participants.toSet().toList();

    // Δημιουργία του νέου plan
    final planRef = await FirebaseFirestore.instance.collection('plans').add({
      'activityId': planDetails['activityId'],
      'dateTime': DateTime(
        planDetails['date'].year,
        planDetails['date'].month,
        planDetails['date'].day,
        planDetails['time'].hour,
        planDetails['time'].minute,
      ),
      'participants': participants,
      'createdAt': FieldValue.serverTimestamp(),
      'notes': planDetails['notes']
    });

    final String planId = planRef.id;

    // Προσθήκη του planId στο attribute `plans` όλων των participants
    for (String participantId in participants) {
      final participantRef = FirebaseFirestore.instance.collection('users').doc(participantId);

      await participantRef.update({
        'plans': FieldValue.arrayUnion([planId]),
      }).catchError((e) async {
        if (e.toString().contains("No document to update")) {
          await participantRef.set({
            'plans': [planId],
          }, SetOptions(merge: true));
        } else {
          throw e;
        }
      });
    }

    // Ενημέρωση της λίστας plans στο group (αν το selectedParticipant είναι group)
if (selectedParticipant != null) {
  final selectedItem = friendsAndGroups.firstWhere((item) => item['id'] == selectedParticipant);
  final isGroup = selectedItem['type'] == 'group';

  if (isGroup) {
    final groupRef = FirebaseFirestore.instance.collection('group').doc(selectedParticipant);

    await groupRef.update({
      'plans': FieldValue.arrayUnion([planId]),
    }).catchError((e) async {
      if (e.toString().contains("No document to update")) {
        await groupRef.set({
          'plans': [planId],
        }, SetOptions(merge: true));
      } else {
        throw e;
      }
    });
  }
}

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plan created successfully!')),
    );

    // Navigate to Plan Confirmation Page
    Navigator.pushReplacementNamed(
      context,
      '/plan_confirmation_page',
      arguments: {'planId': planId},
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error creating plan: $e')),
    );
  }
}

   @override
  Widget build(BuildContext context) {
    final planDetails = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (planDetails == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Plan details not provided.'),
        ),
      );
    }

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
          // Background Image
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [   
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "Search friends or groups",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search friends or groups...",
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
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: isSearching
                        ? filteredFriendsAndGroups.length
                        : recommended.length,
                    itemBuilder: (context, index) {
                      final item = isSearching
                          ? filteredFriendsAndGroups[index]
                          : recommended[index];
                      final isSelected = selectedParticipant == item['id'];

                      if (item['type'] == 'group') {
                        // Εμφάνιση για groups
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.group,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                          title: Text(item['name']),
                          subtitle: const Text('Group'),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle, color: Colors.purple)
                              : const Icon(Icons.circle_outlined, color: Colors.grey),
                          onTap: () {
                            setState(() {
                              selectedParticipant = isSelected ? null : item['id'];
                            });
                          },
                        );
                      } else {
                        // Εμφάνιση για friends
                        return FutureBuilder<String?>(
                          future: _fetchAvatarUrl(item['avatar']),
                          builder: (context, snapshot) {
                            final avatarUrl = snapshot.data;

                            return ListTile(
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
                              title: Text(item['name']),
                              subtitle: const Text('Friend'),
                              trailing: isSelected
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : const Icon(Icons.circle_outlined, color: Colors.grey),
                              onTap: () {
                                setState(() {
                                  selectedParticipant =
                                      isSelected ? null : item['id'];
                                });
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RoundedButton(
                    text: "Confirm Plan",
                    onPressed: () {
                    _confirmPlan(planDetails);
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