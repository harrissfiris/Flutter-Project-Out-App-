import 'package:flutter/material.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small.jpg'), // Background Image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50), // Spacing from the top

                  // Title and Subtitle
                  const Text(
                    "Create an account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Connect with your friends today!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Username Field
                  const CustomTextField(
                    hintText: "Enter Your Username",
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  const CustomTextField(
                    hintText: "Enter Your Email",
                  ),
                  const SizedBox(height: 20),

                  // Phone Number Field
                  const CustomTextField(
                    hintText: "Enter Your Phone Number",
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  const CustomTextField(
                    hintText: "Enter Your Password",
                    isPassword: true,
                  ),
                  const SizedBox(height: 40),

                  // Sign Up Button
                  RoundedButton(
                    text: "Sign up",
                    onPressed: () {
                      // Navigate to Welcome Page
                      Navigator.pushNamed(context, '/welcome');
                    },
                  ),
                  const SizedBox(height: 20),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to Login Page
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
