import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_text_field.dart';

class PlanCreationPage extends StatefulWidget {
  final String activityId;

  const PlanCreationPage({super.key, required this.activityId});

  @override
  State<PlanCreationPage> createState() => _PlanCreationPageState();
}

class _PlanCreationPageState extends State<PlanCreationPage> {
  final TextEditingController _notesController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _photoUrl;
  String? _activityName;
  String? _organizer;

  @override
  void initState() {
    super.initState();
    _fetchActivityDetails();
  }

  Future<void> _fetchActivityDetails() async {
    try {
      final activityDoc = await FirebaseFirestore.instance
          .collection('activities')
          .doc(widget.activityId)
          .get();

      if (activityDoc.exists) {
        final data = activityDoc.data();
        final photoName = data?['Photo'];
        if (photoName != null && photoName.isNotEmpty) {
          final photoUrl = await FirebaseStorage.instance
              .ref('activity pictures/$photoName')
              .getDownloadURL();
          setState(() {
            _photoUrl = photoUrl;
            _activityName = data?['Name'] ?? 'Unnamed Activity';
            _organizer = data?['Organizer'] ?? 'Unknown Organizer';
          });
        }
      }
    } catch (e) {
      setState(() {
        _photoUrl = null;
        _activityName = 'Unnamed Activity';
        _organizer = 'Unknown Organizer';
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  resizeToAvoidBottomInset: false, // Αποτρέπει το resize του περιεχομένου
  extendBodyBehindAppBar: true, // Το AppBar μένει διαφανές
  appBar: AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        Navigator.pop(context);
      },
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
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Εικόνα του Activity με overlay κείμενο
                  if (_photoUrl != null)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Stack(
                          children: [
                            Container(
                              width: 400,
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                              ),
                              child: Image.network(
                                _photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(child: Text('Image not available')),
                              ),
                            ),
                            Container(
                              width: 400,
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.6),
                                    Colors.transparent
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _activityName ?? 'Unnamed Activity',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    '@${_organizer ?? 'Unknown Organizer'}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  const SizedBox(height: 20),
                  const Text(
                    "Make your plan",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _selectedDate == null
                            ? "Choose date"
                            : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => _selectTime(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 20),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _selectedTime == null
                            ? "Choose time"
                            : _selectedTime!.format(context),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: _notesController,
                    hintText: "Add some notes about your plan",
                  ),
                  const SizedBox(height: 20),
                  RoundedButton(
                    text: "Select a group",
                    onPressed: () {
                      if (_selectedDate == null || _selectedTime == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Please choose a date and time!')),
                        );
                        return;
                      }
                      Navigator.pushNamed(
                        context,
                        '/friends_search_page',
                        arguments: {
                          'activityId': widget.activityId,
                          'notes': _notesController.text.trim(),
                          'date': _selectedDate,
                          'time': _selectedTime,
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}