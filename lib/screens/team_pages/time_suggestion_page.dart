import 'package:flutter/material.dart';

class TimeSuggestionPage extends StatelessWidget {
  const TimeSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Time Suggestion Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
