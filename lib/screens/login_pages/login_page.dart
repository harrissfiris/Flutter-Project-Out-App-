import 'package:flutter/material.dart';
import '../../widgets/back_button_widget.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_medium.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Welcome Text
          const Positioned(
            top: 150, // Απόσταση από το πάνω μέρος
            left: 20, // Απόσταση από αριστερά
            right: 20, // Απόσταση από δεξιά
            child: Text(
              "Hi, Welcome Back! 👋",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Back Button
          const BackButtonWidget(),

          // Email Field
          const Positioned(
            top: 300, // Θέση του Email Field
            left: 20,
            right: 20,
            child: CustomTextField(
              hintText: "example@gmail.com",
            ),
          ),

          // Password Field
          const Positioned(
            top: 370, // Θέση του Password Field κάτω από το Email
            left: 20,
            right: 20,
            child: CustomTextField(
              hintText: "Enter Your Password",
              isPassword: true,
            ),
          ),

          // Remember Me and Forgot Password
          Positioned(
            top: 450, // Θέση του περιεχομένου κάτω από τα πεδία εισαγωγής
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(value: false, onChanged: (value) {}),
                    const Text("Remember Me"),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: const Text("Forgot Password?"),
                ),
              ],
            ),
          ),

          // Login Button at the Bottom
          Positioned(
            bottom: 150, // Απόσταση 150 pixels από το κάτω μέρος
            left: 20, // Απόσταση από αριστερά
            right: 20, // Απόσταση από δεξιά
            child: RoundedButton(
              text: "Login",
              onPressed: () {
                Navigator.pushNamed(context, '/welcome');
              },
            ),
          ),

          // Don't have an account? Sign Up
          Positioned(
            bottom: 80, // Απόσταση 80 pixels από το κάτω μέρος
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: Colors.black),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Colors.purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
