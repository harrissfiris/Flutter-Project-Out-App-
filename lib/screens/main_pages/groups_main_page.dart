import 'package:flutter/material.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small_logo.jpg'), // Wallpaper
                fit: BoxFit.cover,
              ),
            ),
          ),

          const Align(
            alignment: Alignment.center, // Τοποθετεί το κείμενο στη μέση
            child: Text(
              "Groups Page!!!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Στυλ κειμένου
              ),
            ),
          ),

        ],
      ),
    );
  }
}
