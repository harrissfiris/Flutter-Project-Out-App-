import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  const BackButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft, // Σταθερή θέση πάνω αριστερά
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Απαραίτητο padding για αποστάσεις
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black, // Μπορείς να προσαρμόσεις το χρώμα
            ),
            onPressed: () {
              Navigator.pop(context); // Επιστροφή στην προηγούμενη σελίδα
            },
          ),
        ),
      ),
    );
  }
}
