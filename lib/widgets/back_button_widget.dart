import 'package:flutter/material.dart';

class BackButtonWidget extends StatelessWidget {
  final Color iconColor;
  final double iconSize;
  final EdgeInsets padding; // Αλλαγή τύπου σε EdgeInsets

  const BackButtonWidget({
    super.key,
    this.iconColor = Colors.black, // Προεπιλεγμένο χρώμα
    this.iconSize = 28.0, // Προεπιλεγμένο μέγεθος
    this.padding = const EdgeInsets.only(top: 40, left: 20), // Προεπιλεγμένο padding
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: padding.top, // Διορθωμένη πρόσβαση στην ιδιότητα
      left: padding.left,
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: iconColor, size: iconSize),
        onPressed: () {
          Navigator.pop(context); // Επιστροφή στην προηγούμενη οθόνη
        },
      ),
    );
  }
}
