import 'package:flutter/material.dart';

class NavigationIcon extends StatelessWidget {
  final String selectedIconPath; // Μονοπάτι για την επιλεγμένη εικόνα
  final String unselectedIconPath; // Μονοπάτι για την μη-επιλεγμένη εικόνα
  final bool isSelected; // Αν είναι επιλεγμένο
  final VoidCallback onTap; // Ενέργεια κατά την επιλογή

  const NavigationIcon({
    super.key,
    required this.selectedIconPath,
    required this.unselectedIconPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Κλήση της πλοήγησης
      child: Image.asset(
        isSelected ? selectedIconPath : unselectedIconPath, // Επιλογή εικόνας
        width: 30,
        height: 30,
      ),
    );
  }
}
