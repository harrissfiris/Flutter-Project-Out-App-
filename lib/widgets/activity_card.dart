import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityCard extends StatelessWidget {
  final String activityId;
  final String photoUrl;
  final String activityName;

  const ActivityCard({
    required this.activityId,
    required this.photoUrl,
    required this.activityName,
    super.key,
  });

  Future<String> fetchOrganiser(String activityId) async {
    try {
      final activityDoc = await FirebaseFirestore.instance
          .collection('activities')
          .doc(activityId)
          .get();

      if (activityDoc.exists) {
        return activityDoc['Organizer'] ?? 'Unknown';
      }
    } catch (e) {
      return 'Unknown';
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/activity_page',
          arguments: activityId,
        );
      },
      child: FutureBuilder<String>(
        future: fetchOrganiser(activityId),
        builder: (context, snapshot) {
          String organiser = 'Unknown';
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            organiser = snapshot.data!;
          }

          return Container(
            margin: const EdgeInsets.only(right: 16),
            width: 165,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(photoUrl),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activityName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '@$organiser',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}