import 'package:flutter/material.dart';

class PlanConfirmationPage extends StatelessWidget {
  const PlanConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Plan Confirmation Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
