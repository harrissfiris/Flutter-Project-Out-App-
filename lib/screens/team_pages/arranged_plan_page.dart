import 'package:flutter/material.dart';

class ArrangedPlanPage extends StatelessWidget {
  const ArrangedPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Arranged Plan Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
