import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/category_icon.dart';
import '../profile_pages/friends_profile_page.dart';
import '../../widgets/plan_card.dart';

class TeamPage extends StatelessWidget {
 const TeamPage({super.key});

Future<List<Map<String, dynamic>>> _fetchGroupPlansWithPhotos({
 required String groupId,
 required String filterType, // "pending" ή "past"
}) async {
 final groupDoc = await FirebaseFirestore.instance.collection('group').doc(groupId).get();

 if (!groupDoc.exists) {
   throw Exception('Group not found');
 }

 final planIds = List<String>.from(groupDoc.data()?['plans'] ?? []);

 List<Map<String, dynamic>> plansWithPhotos = [];
 final now = DateTime.now();

 for (final planId in planIds) {
   final planDoc = await FirebaseFirestore.instance.collection('plans').doc(planId).get();
   if (planDoc.exists) {
     final activityId = planDoc.data()?['activityId'];
     final planDate = (planDoc.data()?['dateTime'] as Timestamp?)?.toDate();

     // Φιλτράρισμα
     if (filterType == "past" && (planDate == null || planDate.isAfter(now))) continue;
     if (filterType == "pending" && (planDate == null || planDate.isBefore(now))) continue;

     if (activityId != null) {
       final activityDoc = await FirebaseFirestore.instance.collection('activities').doc(activityId).get();
       if (activityDoc.exists) {
         final photoName = activityDoc.data()?['Photo'];
         final activityName = activityDoc.data()?['Name'];
         if (photoName != null && activityName != null) {
           final photoUrl = await FirebaseStorage.instance
               .ref('activity pictures/$photoName')
               .getDownloadURL();
           plansWithPhotos.add({
             'planId': planId,
             'photoUrl': photoUrl,
             'activityName': activityName,
             'planDate': planDate,
           });
         }
       }
     }
   }
 }

 // Ταξινόμηση των plans κατά ημερομηνία
 plansWithPhotos.sort((a, b) {
   final dateA = a['planDate'] as DateTime?;
   final dateB = b['planDate'] as DateTime?;
   return dateA?.compareTo(dateB ?? DateTime(1970)) ?? 0;
 });

 return plansWithPhotos;
}

Future<void> _leaveGroup(BuildContext context, String groupId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final groupDoc = await FirebaseFirestore.instance.collection('group').doc(groupId).get();

    if (!groupDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group not found.')),
      );
      return;
    }

    final groupData = groupDoc.data() as Map<String, dynamic>;
    final members = List<String>.from(groupData['members'] ?? []);

    // Αφαίρεση του χρήστη από τη λίστα μελών
    members.remove(user.uid);

    if (members.length < 2) {
      // Αν το group έχει λιγότερα από 2 μέλη, διαγράφεται
      await FirebaseFirestore.instance.collection('group').doc(groupId).delete();

      // Διαγραφή του groupId από τον άλλο χρήστη
      if (members.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(members.first).update({
          'groups': FieldValue.arrayRemove([groupId]),
        });
      }
    } else {
      // Ενημέρωση της λίστας μελών
      await FirebaseFirestore.instance.collection('group').doc(groupId).update({
        'members': members,
      });
    }

    // Αφαίρεση του groupId από τη λίστα του χρήστη
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'groups': FieldValue.arrayRemove([groupId]),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You have left the group.')),
    );

    // Επιστροφή στην προηγούμενη σελίδα με ενημέρωση
    Navigator.pop(context, true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error leaving group: $e')),
    );
  }
}

 @override
 Widget build(BuildContext context) {
   final String? groupId = ModalRoute.of(context)?.settings.arguments as String?;

   if (groupId == null) {
     return Scaffold(
       appBar: AppBar(
         title: const Text('Team Page'),
       ),
       body: const Center(
         child: Text('Group ID not found.'),
       ),
     );
   }

   Future<Map<String, dynamic>> getGroupDetails() async {
     DocumentSnapshot groupDoc = await FirebaseFirestore.instance
         .collection('group')
         .doc(groupId)
         .get();

     if (!groupDoc.exists) {
       throw Exception('Group not found');
     }

     return groupDoc.data() as Map<String, dynamic>;
   }

   Future<List<Map<String, String>>> getMemberDetails(List<String> memberIds) async {
     try {
       QuerySnapshot membersQuery = await FirebaseFirestore.instance
           .collection('users')
           .where(FieldPath.documentId, whereIn: memberIds)
           .get();

       return membersQuery.docs.map((doc) {
         final data = doc.data() as Map<String, dynamic>;
         final username = data['username'] ?? 'Unknown User';
         final avatarName = data['avatar'] ?? '';
         final userId = doc.id; // Παίρνουμε το ID του χρήστη

         return {
           'username': username.toString(),
           'avatar': avatarName.toString(),
           'id': userId, // Προσθήκη ID στο αντικείμενο
         };
       }).toList();
     } catch (e) {
       throw Exception('Error fetching member details: $e');
     }
   }

   Future<String> fetchAvatarUrl(String avatarName) async {
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
  actions: [
         IconButton(
           icon: const Icon(Icons.exit_to_app, color: Colors.black),
           onPressed: () async {
            await _leaveGroup(context, groupId);
            },
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
     child: FutureBuilder<Map<String, dynamic>>(
       future: getGroupDetails(),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(
             child: CircularProgressIndicator(),
           );
         }

         if (snapshot.hasError) {
           return Center(
             child: Text('Error: ${snapshot.error}'),
           );
         }

         if (!snapshot.hasData || snapshot.data == null) {
           return const Center(
             child: Text('Group not found.'),
           );
         }

         final group = snapshot.data!;
         final memberIds = List<String>.from(group['members'] ?? []);

         return FutureBuilder<List<Map<String, String>>>(
           future: getMemberDetails(memberIds),
           builder: (context, memberSnapshot) {
             if (memberSnapshot.connectionState == ConnectionState.waiting) {
               return const Center(
                 child: CircularProgressIndicator(),
               );
             }

             if (memberSnapshot.hasError) {
               return Center(
                 child: Text('Error: ${memberSnapshot.error}'),
               );
             }

             final members = memberSnapshot.data ?? [];

             return Column(
               children: [
                 const SizedBox(height: 20),
                 Text(
                   group['name'] ?? 'Unnamed Group',
                   style: const TextStyle(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 30),
                 SizedBox(
                   height: 110,
                   child: ListView.builder(
                     scrollDirection: Axis.horizontal,
                     itemCount: members.length,
                     itemBuilder: (context, index) {
                       final member = members[index];
                       final username = member['username']!;
                       final avatarName = member['avatar']!;
                       final userId = member['id']!;

                       return FutureBuilder<String>(
                         future: fetchAvatarUrl(avatarName),
                         builder: (context, avatarSnapshot) {
                           if (avatarSnapshot.connectionState == ConnectionState.waiting) {
                             return const SizedBox(
                               width: 80,
                               height: 80,
                               child: CircularProgressIndicator(),
                             );
                           }

                           final avatarUrl = avatarSnapshot.data!;
                           return GestureDetector(
                             onTap: () {
                               Navigator.push(
                                 context,
                                 MaterialPageRoute(
                                   builder: (context) => FriendsProfilePage(
                                     friendId: userId,
                                     fromAddFriendsPage: false,
                                   ),
                                 ),
                               );
                             },
                             child: Padding(
                               padding: const EdgeInsets.symmetric(horizontal: 8.0),
                               child: Column(
                                 children: [
                                   CircleAvatar(
                                     radius: 30,
                                     backgroundImage: avatarUrl.startsWith('assets')
                                         ? AssetImage(avatarUrl) as ImageProvider
                                         : NetworkImage(avatarUrl),
                                   ),
                                   const SizedBox(height: 5),
                                   SizedBox(
                                     width: 80,
                                     child: Text(
                                       username,
                                       style: const TextStyle(fontSize: 12),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                       textAlign: TextAlign.center,
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                           );
                         },
                       );
                     },
                   ),
                 ),

Column(
 crossAxisAlignment: CrossAxisAlignment.start,
 children: [

// Add Members Button
Align(
  alignment: Alignment.centerLeft, // Ευθυγράμμιση στα αριστερά
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: GestureDetector(
      onTap: () {
        Navigator.pushNamed(
      context,
      '/add_members',
      arguments: {'groupId': groupId},
    );
      },
      child: const SizedBox(
        width: 180, // Σωστό πλάτος για το κουμπί
        height: 40,
        child: CategoryIcon(
          text: "Add members",
          fontSize: 18, // Μικρότερη γραμματοσειρά
        ),
      ),
    ),
  ),
),

const SizedBox(height: 20),

   // Pending Plans Section
   const Align(
     alignment: Alignment.centerLeft,
     child: Padding(
       padding: EdgeInsets.symmetric(horizontal: 16.0), // Απόσταση από τα πλάγια
       child: Text(
         "Pending Plans",
         style: TextStyle(
           fontSize: 24,
           fontWeight: FontWeight.bold,
         ),
       ),
     ),
   ),
   const SizedBox(height: 10),
   FutureBuilder<List<Map<String, dynamic>>>(
     future: _fetchGroupPlansWithPhotos(groupId: groupId, filterType: "pending"),
     builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return const Center(child: CircularProgressIndicator());
       }

       if (snapshot.hasError) {
         return Center(child: Text('Error: ${snapshot.error}'));
       }

       final pendingPlans = snapshot.data ?? [];

       if (pendingPlans.isEmpty) {
         return const Center(
           child: Padding(
             padding: EdgeInsets.symmetric(horizontal: 16.0), // Απόσταση από τα πλάγια
             child: Text(
               'No pending plans available.',
               style: TextStyle(color: Colors.black),
             ),
           ),
         );
       }

       return SizedBox(
         height: 180,
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0), // Απόσταση από τα πλάγια
           child: ListView.builder(
             scrollDirection: Axis.horizontal,
             itemCount: pendingPlans.length,
             itemBuilder: (context, index) {
               final plan = pendingPlans[index];
               return PlanCard(
                 planId: plan['planId'],
                 photoUrl: plan['photoUrl'],
                 activityName: plan['activityName'],
               );
             },
           ),
         ),
       );
     },
   ),
   const SizedBox(height: 20),

   // Past Plans Section
   const Align(
     alignment: Alignment.centerLeft,
     child: Padding(
       padding: EdgeInsets.symmetric(horizontal: 16.0), // Απόσταση από τα πλάγια
       child: Text(
         "Past Plans",
         style: TextStyle(
           fontSize: 24,
           fontWeight: FontWeight.bold,
         ),
       ),
     ),
   ),
   const SizedBox(height: 10),
   FutureBuilder<List<Map<String, dynamic>>>(
     future: _fetchGroupPlansWithPhotos(groupId: groupId, filterType: "past"),
     builder: (context, snapshot) {
       if (snapshot.connectionState == ConnectionState.waiting) {
         return const Center(child: CircularProgressIndicator());
       }

       if (snapshot.hasError) {
         return Center(child: Text('Error: ${snapshot.error}'));
       }

       final pastPlans = snapshot.data ?? [];

       if (pastPlans.isEmpty) {
         return const Center(
           child: Padding(
             padding: EdgeInsets.symmetric(horizontal: 16.0), // Απόσταση από τα πλάγια
             child: Text(
               'No past plans available.',
               style: TextStyle(color: Colors.black),
             ),
           ),
         );
       }

       return SizedBox(
         height: 180,
         child: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 16.0), // Απόσταση από τα πλάγια
           child: ListView.builder(
             scrollDirection: Axis.horizontal,
             itemCount: pastPlans.length,
             itemBuilder: (context, index) {
               final plan = pastPlans[index];
               return PlanCard(
                 planId: plan['planId'],
                 photoUrl: plan['photoUrl'],
                 activityName: plan['activityName'],
               );
             },
           ),
         ),
       );
     },
   ),
 ],
),

               ],
             );
           },
         );
       },
     ),
    ),
     ],
   ),
   );
 }
}