import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/plan_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Future<void>? _eventsFuture; // Future για το _loadEvents
  Map<DateTime, List> _events = {};

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents(); // Αρχικοποίηση του Future
  }

  Future<void> _loadEvents() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final planIds = List<String>.from(userDoc.data()?['plans'] ?? []);

    Map<DateTime, List> tempEvents = {};

    for (final planId in planIds) {
      final planDoc =
          await FirebaseFirestore.instance.collection('plans').doc(planId).get();
      if (planDoc.exists) {
        final planDate = (planDoc.data()?['dateTime'] as Timestamp?)?.toDate();
        if (planDate != null) {
          final date = DateTime(planDate.year, planDate.month, planDate.day);

          tempEvents.update(date, (value) => value..add("Plan"),
              ifAbsent: () => ["Plan"]);
        }
      }
    }

    setState(() {
      _events = tempEvents; // Ενημέρωση των events
    });
  }


  Future<List<Map<String, dynamic>>> _fetchPlansByDate(DateTime date) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception("User document does not exist");
    }

    final planIds = List<String>.from(userDoc.data()?['plans'] ?? []);
    List<Map<String, dynamic>> plansByDate = [];

    for (final planId in planIds) {
      final planDoc = await FirebaseFirestore.instance.collection('plans').doc(planId).get();
      if (planDoc.exists) {
        final planDate = (planDoc.data()?['dateTime'] as Timestamp?)?.toDate();
        if (planDate != null &&
            planDate.year == date.year &&
            planDate.month == date.month &&
            planDate.day == date.day) {
          final activityId = planDoc.data()?['activityId'];
          if (activityId != null) {
            final activityDoc = await FirebaseFirestore.instance.collection('activities').doc(activityId).get();
            if (activityDoc.exists) {
              final activityName = activityDoc.data()?['Name'];
              plansByDate.add({
                'planId': planId,
                'activityName': activityName ?? 'Unknown Activity',
              });
            }
          }
        }
      }
    }
    return plansByDate;
  }

  Future<List<Map<String, dynamic>>> _fetchPlansWithPhotos({
    required String filterType,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      throw Exception("User not authenticated");
    }

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      throw Exception("User document does not exist");
    }

    final planIds = List<String>.from(userDoc.data()?['plans'] ?? []);
    List<Map<String, dynamic>> plansWithPhotos = [];
    final now = DateTime.now();

    for (final planId in planIds) {
      final planDoc = await FirebaseFirestore.instance.collection('plans').doc(planId).get();
      if (planDoc.exists) {
        final activityId = planDoc.data()?['activityId'];
        final planDate = (planDoc.data()?['dateTime'] as Timestamp?)?.toDate();

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

    plansWithPhotos.sort((a, b) {
      final dateA = a['planDate'] as DateTime?;
      final dateB = b['planDate'] as DateTime?;
      return dateA?.compareTo(dateB ?? DateTime(1970)) ?? 0;
    });

    return plansWithPhotos;
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
          // Main Content
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Scrollable content below the static header
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView(
                    children: [
                    // Section Title: My Plans
                    const Text(
                      'My Plans',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Fetch and Display Plans
                   FutureBuilder<List<Map<String, dynamic>>>(
  future: _fetchPlansWithPhotos(filterType: "pending"),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    final plans = snapshot.data ?? [];

    if (plans.isEmpty) {
      return const Center(
        child: Text(
          'No plans available.',
          style: TextStyle(color: Colors.black),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: plans.length,
        itemBuilder: (context, index) {
          final plan = plans[index];
          return GestureDetector(
            onTap: () async {
    await Navigator.pushNamed(
    context,
    '/arranged_plan_page',
    arguments: plan['planId'],
  );
},
            child: PlanCard(
              planId: plan['planId'],
              photoUrl: plan['photoUrl'],
              activityName: plan['activityName'],
            ),
          );
        },
      ),
    );
  },
),
                    const SizedBox(height: 20),
                    // Section Title: Calendar
                    const Text(
                      'Calendar',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Functional Calendar
                    FutureBuilder(
                      future: _eventsFuture, // Χρήση του Future
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return TableCalendar(
                          firstDay: DateTime.utc(2022, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          focusedDay: DateTime.now(),
                          calendarFormat: CalendarFormat.month,
                          eventLoader: (day) {
                            return _events[DateTime(day.year, day.month, day.day)] ?? [];
                          },
                          onDaySelected: (selectedDay, focusedDay) async {
    final plans = await _fetchPlansByDate(selectedDay);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Plans for ${selectedDay.day} ${_monthName(selectedDay.month)} ${selectedDay.year}'),
          content: plans.isEmpty
              ? const Text('No plans scheduled for this day.')
              : SizedBox(
                  height: 200,
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      return ListTile(
                        title: Text(plan['activityName']),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                            context,
                            '/arranged_plan_page',
                            arguments: plan['planId'],
                          );
                        },
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  },
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, date, events) {
                              if (events.isNotEmpty) {
                                return Positioned(
                                  bottom: 4,
                                  child: Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                );
                              }
                              return null;
                            },
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: Colors.deepPurple,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                            ),
                            tablePadding: EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 4,
    ),
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
                ),
        ], 
      ),
    );

  }

String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

}