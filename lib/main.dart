import 'package:flutter/material.dart';
import 'main_app.dart';
// Login Pages
import 'screens/login_pages/open_app.dart';
import 'screens/login_pages/login_page.dart';
import 'screens/login_pages/forgot_password.dart';
import 'screens/login_pages/signup.dart';
import 'screens/login_pages/welcome_page.dart';
import 'screens/login_pages/preferences_page.dart';
// Main Pages
import 'screens/main_pages/home_main_page.dart';
import 'screens/main_pages/search_main_page.dart';
import 'screens/main_pages/groups_main_page.dart';
import 'screens/main_pages/calendar_main_page.dart';
import 'screens/main_pages/profile_main_page.dart';
// Plan Pages
import 'screens/plan_pages/activity_page.dart';
import 'screens/plan_pages/friends_search_page.dart';
import 'screens/plan_pages/plan_confirmation_page.dart';
import 'screens/plan_pages/plan_creation_page.dart';
// Profile Pages
import 'screens/profile_pages/avatar_selection.dart';
import 'screens/profile_pages/friends_profile_page.dart';
import 'screens/profile_pages/my_friends_page.dart';
import 'screens/profile_pages/profile_settings.dart';
import 'screens/profile_pages/mycode_page.dart';
import 'screens/profile_pages/myscanner_page.dart';
// Team Pages
import 'screens/team_pages/arranged_plan_page.dart';
import 'screens/team_pages/group_creation_page.dart';
import 'screens/team_pages/team_page.dart';
import 'screens/team_pages/time_suggestion_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      initialRoute: '/open_app',
      routes: {
        '/main': (context) => const MainApp(),

        // Login Pages
        '/open_app': (context) => const OpenAppScreen(),
        '/login': (context) => const LoginPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/signup': (context) => const SignUpPage(),
        '/welcome': (context) => const WelcomePage(),
        '/preferences': (context) => const PreferencesPage(),

        // Main Pages
        '/home': (context) => const HomePage(),
        '/search': (context) => const SearchPage(),
        '/groups': (context) => const GroupsPage(),
        '/calendar': (context) => const CalendarPage(),
        '/profile': (context) => const ProfilePage(),

        // Plan Pages
        '/activity_page': (context) => const ActivityPage(),
        '/friends_search_page': (context) => const FriendsSearchPage(),
        '/plan_confirmation_page': (context) => const PlanConfirmationPage(),
        '/plan_creation_page': (context) => const PlanCreationPage(),

        // Profile Pages
        '/avatar_selection': (context) => const AvatarSelectionPage(),
        '/friends_profile_page': (context) => const FriendsProfilePage(),
        '/my_friends_page': (context) => const MyFriendsPage(),
        '/profile_settings': (context) => const ProfileSettingsPage(),
        '/qr_code_page': (context) => const QRCodePage(),
        '/qr_scanner_page': (context) => const QRScannerPage(),

        // Team Pages
        '/arranged_plan_page': (context) => const ArrangedPlanPage(),
        '/group_creation_page': (context) => const GroupCreationPage(),
        '/team_page': (context) => const TeamPage(),
        '/time_suggestion_page': (context) => const TimeSuggestionPage(),
      },
    );
  }
}
