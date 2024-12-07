import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_navigation_bar.dart';
import 'screens/main_pages/home_main_page.dart';
import 'screens/main_pages/search_main_page.dart';
import 'screens/main_pages/groups_main_page.dart';
import 'screens/main_pages/calendar_main_page.dart';
import 'screens/main_pages/profile_main_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0; // Ο δείκτης για την τρέχουσα σελίδα

  final List<Widget> _screens = [
    const HomePage(),
    const SearchPage(),
    const GroupsPage(),
    const CalendarPage(),
    const ProfilePage(),
  ];

  // Ενημέρωση της τρέχουσας σελίδας
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex, // Ελέγχει ποια σελίδα εμφανίζεται
        children: _screens, // Οι σελίδες μας
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex, // Δείκτης για το επιλεγμένο tab
        onTap: _onTabTapped, // Ενημέρωση όταν αλλάζει tab
      ),
    );
  }
}
