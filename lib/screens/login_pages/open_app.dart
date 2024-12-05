import 'package:flutter/material.dart';

class OpenAppScreen extends StatelessWidget {
  const OpenAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // Πλοήγηση στην οθόνη LoginPage
          Navigator.pushNamed(context, '/login');
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/open_app_background.jpg'),
              fit: BoxFit.cover, // Η εικόνα καλύπτει πλήρως την οθόνη
            ),
          ),
        ),
      ),
    );
  }
}
