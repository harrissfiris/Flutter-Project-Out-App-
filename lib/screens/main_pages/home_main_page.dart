import 'package:flutter/material.dart';
import '../../widgets/back_button_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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

          // Back Button
          const BackButtonWidget(),

          const Align(
            alignment: Alignment.center, // Τοποθετεί το κείμενο στη μέση
            child: Text(
              "Welcome to Home!",
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
