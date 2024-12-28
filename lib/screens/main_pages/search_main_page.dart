import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../../widgets/search_bar_new.dart';
import '../../widgets/activity_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final Map<String, String> activityMap = {};
  List<Map<String, dynamic>> allActivities = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    fetchAllActivities();
  }

  // Φόρτωση όλων των δραστηριοτήτων και φωτογραφιών
  Future<void> fetchAllActivities() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('activities').get();

      List<Map<String, dynamic>> activities = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final photoName = data['Photo'] as String?;

        final photoUrl = (photoName != null && photoName.isNotEmpty)
            ? await FirebaseStorage.instance
                .ref('activity pictures/$photoName')
                .getDownloadURL()
            : null;

        activities.add({
          'activityId': doc.id,
          'photoUrl': photoUrl ?? '',
          'activityName': data['Name'] ?? 'Unnamed Activity',
        });
      }

      setState(() {
        allActivities = activities;
      });
    } catch (e) {
      debugPrint('Error fetching activities: $e');
    }
  }

  // Αναζήτηση δραστηριοτήτων
  Future<Map<String, String>> searchActivities(String query) async {
    if (query.isEmpty) return {};

    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('activities').get();

      return querySnapshot.docs
          .where((doc) {
            final name = (doc['Name'] as String).toLowerCase();
            final organizer = (doc['Organizer'] as String).toLowerCase();
            return name.contains(query.toLowerCase()) ||
                organizer.contains(query.toLowerCase());
          })
          .fold<Map<String, String>>({}, (map, doc) {
            final name = doc['Name'] as String;
            final organizer = doc['Organizer'] as String;
            map['$name @$organizer'] = doc.id;
            return map;
          });
    } catch (e) {
      debugPrint('Error fetching activities: $e');
      return {};
    }
  }

  void onActivitySelected(String selectedActivity) {
    final activityId = activityMap[selectedActivity];
    if (activityId != null) {
      Navigator.pushNamed(
        context,
        '/activity_page',
        arguments: activityId,
      );
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
          SafeArea(
  child: Column(
    mainAxisSize: MainAxisSize.min, // Προσαρμοσμένο ύψος για το Column
    children: [
      const SizedBox(height: 80),
      const Center(
        child: Text(
          "Look for an activity",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      const SizedBox(height: 10),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: CustomSearchBarNew(
          hintText: 'Search activities...',
          onSearch: (query) async {
            setState(() {
              isSearching = query.isNotEmpty;
            });
            activityMap.clear();
            final results = await searchActivities(query);
            setState(() {
              activityMap.addAll(results);
            });
            return results.keys.toList();
          },
          onResultTap: (result) => onActivitySelected(result),
        ),
      ),
      const SizedBox(height: 10),
      Expanded(
  child: !isSearching
      ? Padding(
          padding: const EdgeInsets.only(left: 15.0), // Αριστερό padding
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 3 / 2,
            ),
            itemCount: allActivities.length,
            itemBuilder: (context, index) {
              final activity = allActivities[index];
              return ActivityCard(
                activityId: activity['activityId'],
                photoUrl: activity['photoUrl'],
                activityName: activity['activityName'],
              );
            },
          ),
        )
      : const SizedBox.shrink(),
),
    ],
  ),
),
        ],
      ),
    );
  }
}