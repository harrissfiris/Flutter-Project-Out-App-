import 'package:flutter/material.dart';

class FriendsSearchPage extends StatelessWidget {
  const FriendsSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'Friends Search Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
