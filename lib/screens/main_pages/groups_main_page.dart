import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsPage extends StatefulWidget {
 const GroupsPage({super.key});

 @override
 State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {

Future<List<Map<String, dynamic>>> _getUserGroups() async {
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Ελέγχει αν υπάρχει το πεδίο "groups"
    List<String> groupIds = [];
final userData = userDoc.data() as Map<String, dynamic>?;

if (userData != null && userData.containsKey('groups')) {
  groupIds = List<String>.from(userData['groups']);
}

    // Αν δεν υπάρχουν group IDs, επιστρέφει κενή λίστα
    if (groupIds.isEmpty) {
      return [];
    }

    QuerySnapshot groupsQuery = await FirebaseFirestore.instance
        .collection('group')
        .where(FieldPath.documentId, whereIn: groupIds)
        .get();

    return groupsQuery.docs.map((doc) {
      return {
        'id': doc.id,
        'name': doc['name'],
      };
    }).toList();
  } catch (e) {
    throw Exception("Error fetching groups: $e");
  }
}

 Future<void> _addGroupToUser(String groupId) async {
   try {
     User? user = FirebaseAuth.instance.currentUser;
     if (user == null) throw Exception("User not logged in!");

     await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
       'groups': FieldValue.arrayUnion([groupId]),
     });
   } catch (e) {
     throw Exception("Error adding group to user: $e");
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     body: Stack(
       children: [
         // Background Image
         Container(
           decoration: const BoxDecoration(
             image: DecorationImage(
               image: AssetImage('assets/images/background_small_logo.jpg'),
               fit: BoxFit.cover,
             ),
           ),
         ),

         // Content
         SafeArea(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const SizedBox(height: 70),
                 // Centered Title
                 const Text(
                   "My Groups",
                   style: TextStyle(
                     fontSize: 24,
                     fontWeight: FontWeight.bold,
                     color: Colors.black,
                   ),
                 ),
                 const SizedBox(height: 25),

                 // Plus Button and Create new group in a Row
Row(
 crossAxisAlignment: CrossAxisAlignment.center,
 children: [
   const SizedBox(width: 16), // Αριστερή ευθυγράμμιση
   GestureDetector(
     onTap: () async {
       final newGroupId = await Navigator.pushNamed(context, '/group_creation_page');
       if (newGroupId != null) {
         await _addGroupToUser(newGroupId.toString());
         setState(() {});
       }
     },
     child: const CircleAvatar(
       radius: 25, // Ίδιο μέγεθος με τα icons των ομάδων
       backgroundColor: Colors.purple,
       child: Icon(
         Icons.add,
         color: Colors.white,
         size: 24,
       ),
     ),
   ),
   const SizedBox(width: 16), // Απόσταση μεταξύ του κουμπιού και του κειμένου
   const Text(
     "Create new group",
     style: TextStyle(
       fontSize: 18,
       fontWeight: FontWeight.w500,
       color: Colors.black,
     ),
   ),
 ],
),
                 const SizedBox(height: 20),

                 // Group List
                 Expanded(
                   child: FutureBuilder<List<Map<String, dynamic>>>(
                     future: _getUserGroups(),
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

                       final groups = snapshot.data ?? [];

                       if (groups.isEmpty) {
                         return const Center(
                           child: Text('You are not part of any groups.'),
                         );
                       }

                       return ListView.builder(
                         itemCount: groups.length,
                         itemBuilder: (context, index) {
                           final group = groups[index];
                           return Padding(
                             padding: const EdgeInsets.symmetric(vertical: 8.0),
                             child: ListTile(
                               leading: CircleAvatar(
                                 radius: 25,
                                 backgroundColor: Colors.grey[200],
                                 child: const Icon(
                                   Icons.group,
                                   color: Colors.black,
                                   size: 24,
                                 ),
                               ),
                               title: Text(
                                 group['name'],
                                 style: const TextStyle(
                                   fontSize: 18,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               onTap: () async {
  final result = await Navigator.pushNamed(context, '/team_page', arguments: group['id']);
  if (result == true) {
    setState(() {}); // Ανανεώνει τη λίστα των groups
  }
},
                             ),
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