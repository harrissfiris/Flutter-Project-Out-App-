import 'package:flutter/material.dart';
import '../../main_app.dart';
import '../../widgets/rounded_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/welcome_background.jpg'), // Wallpaper
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Welcome Text
          const Positioned(
            top: 200, // Απόσταση από το πάνω μέρος
            left: 20, // Απόσταση από αριστερά
            right: 20, // Απόσταση από δεξιά
            child: Text(
              "Welcome!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Rounded Button at the Bottom
          Positioned(
            bottom: 50, // Απόσταση 50 pixels από το κάτω μέρος
            left: 20, // Απόσταση από αριστερά
            right: 20, // Απόσταση από δεξιά
            child: RoundedButton(
              text: "Get started to go Out!",
              onPressed: () {
                Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MainApp()),
  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
