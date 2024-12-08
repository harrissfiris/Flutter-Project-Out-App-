import 'package:flutter/material.dart';

class PlusButton extends StatelessWidget {
  final VoidCallback onTap; // Συνάρτηση για το τι συμβαίνει όταν πατιέται
  final String? labelText; // Προαιρετικό κείμενο

  const PlusButton({
    super.key,
    required this.onTap,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // "+" Button
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Προαιρετικό κείμενο
          if (labelText != null)
            Text(
              labelText!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}