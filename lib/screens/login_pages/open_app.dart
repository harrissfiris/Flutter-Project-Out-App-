import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../main_app.dart';

class OpenAppScreen extends StatefulWidget {
  const OpenAppScreen({super.key});

  @override
  _OpenAppScreenState createState() => _OpenAppScreenState();
}

class _OpenAppScreenState extends State<OpenAppScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 2)); // Αναμονή 2 δευτερολέπτων

    // Έλεγχος αν ο χρήστης είναι συνδεδεμένος στο Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Ο χρήστης είναι ήδη συνδεδεμένος
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainApp()),
      );
    } else {
      // Ο χρήστης δεν είναι συνδεδεμένος
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/open_app_background.jpg'),
            fit: BoxFit.cover, // Η εικόνα καλύπτει πλήρως την οθόνη
          ),
        ),
      ),
    );
  }
}