import 'package:flutter/material.dart';

class CategoryIcon extends StatelessWidget {
  final String text;
  final double fontSize;

  const CategoryIcon({
    required this.text,
    this.fontSize = 24, // Προεπιλεγμένο μέγεθος γραμματοσειράς
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFC880FC), // Αρχικό χρώμα
            Color(0xFF773BC5), // Τελικό χρώμα
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Σκιά με διαφάνεια
            blurRadius: 6,
            offset: const Offset(2, 4), // Μετατόπιση σκιάς
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: fontSize, // Τιμή από την παράμετρο
          ),
        ),
      ),
    );
  }
}