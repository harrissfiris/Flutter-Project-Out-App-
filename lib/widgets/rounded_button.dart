import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const RoundedButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity, // Το κουμπί καλύπτει όλο το πλάτος του γονικού widget
        padding: const EdgeInsets.symmetric(vertical: 20), // Υψος του κουμπιού
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF9C27B0), Color(0xFF673AB7)], // Gradient χρωμάτων
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(30), // Στρογγυλεμένες γωνίες
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5), // Εφέ σκιάς
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
