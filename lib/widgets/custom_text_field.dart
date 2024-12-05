import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText; // Το κείμενο που θα εμφανίζεται ως οδηγία
  final bool isPassword; // Αν το πεδίο είναι για password ή όχι

  const CustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false, // Προεπιλογή: Δεν είναι password
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: isPassword, // Αν είναι password, αποκρύπτει το κείμενο
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), // Στρογγυλεμένες γωνίες
        ),
        suffixIcon: isPassword
            ? const Icon(Icons.visibility) // Εικονίδιο για password
            : null,
      ),
    );
  }
}
