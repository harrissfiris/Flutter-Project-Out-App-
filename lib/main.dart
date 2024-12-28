import 'package:flutter/material.dart';
import 'main_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
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
import 'screens/plan_pages/arranged_plan_page.dart';
import 'screens/plan_pages/add_participants.dart';
// Profile Pages
import 'screens/profile_pages/avatar_selection.dart';
import 'screens/profile_pages/friends_profile_page.dart';
import 'screens/profile_pages/my_friends_page.dart';
import 'screens/profile_pages/add_friends_page.dart';
import 'screens/profile_pages/profile_settings.dart';
import 'screens/profile_pages/qr_scanner_page.dart';
// Team Pages
import 'screens/team_pages/group_creation_page.dart';
import 'screens/team_pages/team_page.dart';
import 'screens/team_pages/add_members.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
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
        '/home': (context) => HomePage(),
        '/search': (context) => const SearchPage(),
        '/groups': (context) => const GroupsPage(),
        '/calendar': (context) => const CalendarPage(),
        '/profile': (context) => const ProfilePage(),

        // Plan Pages
        '/activity_page': (context) => const ActivityPage(),
        '/friends_search_page': (context) => const FriendsSearchPage(),
        '/plan_confirmation_page': (context) => const PlanConfirmationPage(),
        '/arranged_plan_page': (context) => const ArrangedPlanPage(),
        '/plan_creation_page': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as String?;
            if (args == null) {
              throw Exception("Missing activityId for PlanCreationPage");
            }
            return PlanCreationPage(activityId: args);
        },
        '/add_participants': (context) {
  final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  if (args == null || args['planId'] == null) {
    throw Exception("Missing planId for AddParticipantsPage");
  }
  return AddParticipants(planId: args['planId']);
},

        // Profile Pages
        '/avatar_selection': (context) => const AvatarSelectionPage(),
        '/friends_profile_page': (context) => const FriendsProfilePage(friendId: '',),
        '/my_friends_page': (context) => const MyFriendsPage(),
        '/add_friends_page': (context) => const AddFriendsPage(),
        '/profile_settings': (context) => const ProfileSettingsPage(),
        '/qr_scanner_page': (context) => const QRScannerPage(),

        // Team Pages
        '/group_creation_page': (context) => const GroupCreationPage(),
        '/team_page': (context) => const TeamPage(),
        '/add_members': (context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null || !args.containsKey('groupId')) {
      throw Exception("Missing groupId for AddMembers page");
    }
    return AddMembers(groupId: args['groupId']);
  },
      },
    );
  }
}
