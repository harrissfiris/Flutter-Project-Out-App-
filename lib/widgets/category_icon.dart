import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String text;

  const CategoryIcon({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3), // Μειώθηκε το vertical padding
      decoration: BoxDecoration(
        color: const Color(0xFF7E57C2), // Βαθύ μωβ χρώμα
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Σκιά με διαφάνεια
            blurRadius: 8,
            offset: const Offset(2, 4), // Μετατόπιση σκιάς
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }
}