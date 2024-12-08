import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/custom_text_field.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Μέθοδος για εγγραφή χρήστη
  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      _showErrorDialog('Please fill in all fields.');
      return;
    }

    try {
      // Δημιουργία χρήστη με email και password
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Παίρνουμε το UID του χρήστη
      String uid = userCredential.user!.uid;

      // Αποθήκευση των δεδομένων του χρήστη στη Firestore
      await _firestore.collection('users').doc(uid).set({
        'username': username,
        'email': email,
        'phone': phone,
        'selectedCategories': [], // Αρχικά κενές κατηγορίες
        'createdAt': Timestamp.now(),
      });

      // Μεταφορά στη σελίδα προτιμήσεων (preferences)
      Navigator.pushNamed(context, '/preferences');
    } catch (e) {
      _showErrorDialog(e.toString());
    }
  }

  // Μέθοδος εμφάνισης σφάλματος
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small.jpg'), // Background Image
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 50), // Spacing from the top

                  // Title and Subtitle
                  const Text(
                    "Create an account",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Connect with your friends today!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Username Field
                  CustomTextField(
                    hintText: "Enter Your Username",
                    controller: _usernameController,
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  CustomTextField(
                    hintText: "Enter Your Email",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),

                  // Phone Number Field
                  CustomTextField(
                    hintText: "Enter Your Phone Number",
                    controller: _phoneController,
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    hintText: "Enter Your Password",
                    isPassword: true,
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 40),

                  // Sign Up Button
                  RoundedButton(
                    text: "Sign up",
                    onPressed: _signUp, // Κλήση της μεθόδου εγγραφής
                  ),
                  const SizedBox(height: 20),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to Login Page
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Απελευθέρωση controllers
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}