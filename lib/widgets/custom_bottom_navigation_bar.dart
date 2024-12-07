import 'package:flutter/material.dart';
import 'navigation_icon.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Σταθερό ύψος για το navigation bar
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), // Καμπύλες γωνίες
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5), // Σκιά πάνω από το navigation bar
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding για τα εικονίδια
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavigationIcon(
            selectedIconPath: 'assets/icons/HOME_selected.png',
            unselectedIconPath: 'assets/icons/HOME.png',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          NavigationIcon(
            selectedIconPath: 'assets/icons/SEARCH_selected.png',
            unselectedIconPath: 'assets/icons/SEARCH.png',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          NavigationIcon(
            selectedIconPath: 'assets/icons/TEAMS_selected.png',
            unselectedIconPath: 'assets/icons/TEAMS.png',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          NavigationIcon(
            selectedIconPath: 'assets/icons/CALENDAR_selected.png',
            unselectedIconPath: 'assets/icons/CALENDAR.png',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          NavigationIcon(
            selectedIconPath: 'assets/icons/PROFILE_selected.png',
            unselectedIconPath: 'assets/icons/PROFILE.png',
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}
