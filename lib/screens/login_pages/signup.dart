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

  // Έλεγχος αν το username είναι μοναδικό
  Future<bool> _isUsernameUnique(String username) async {
  final querySnapshot = await _firestore
      .collection('users')
      .where('username', isEqualTo: username.toLowerCase()) // Συγκρίνει πάντα πεζά
      .get();

  return querySnapshot.docs.isEmpty; // Επιστρέφει true αν δεν υπάρχει
}

// Έλεγχος αν το email υπάρχει ήδη στη Firestore
Future<bool> _isEmailUnique(String email) async {
  final querySnapshot = await _firestore
      .collection('users')
      .where('email', isEqualTo: email)
      .get();

  return querySnapshot.docs.isEmpty;
}

// Μέθοδος για εγγραφή χρήστη
Future<void> _signUp() async {
  final username = _usernameController.text.trim();
  final email = _emailController.text.trim();
  final phone = _phoneController.text.trim();
  final password = _passwordController.text.trim();

  if (username.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
    return;
  }

  try {
    // Έλεγχος για μοναδικότητα του email
    bool isEmailUnique = await _isEmailUnique(email);
    if (!isEmailUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An account with this email already exists.')),
      );
      return;
    }

    // Έλεγχος για μοναδικότητα του username
    bool isUnique = await _isUsernameUnique(username);
    if (!isUnique) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is already taken. Please choose another one.')),
      );
      return;
    }

    // Δημιουργία χρήστη με email και password
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Παίρνουμε το UID του χρήστη
    String uid = userCredential.user!.uid;

    // Αποθήκευση των δεδομένων του χρήστη στη Firestore
    await _firestore.collection('users').doc(uid).set({
      'username': username.toLowerCase(), // Αποθηκεύουμε πάντα σε πεζά γράμματα
      'email': email,
      'phone': phone,
      'selectedCategories': [],
      'createdAt': Timestamp.now(),
    });

    // Μεταφορά στη σελίδα προτιμήσεων (preferences)
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      '/preferences',
      arguments: {'origin': 'signup'},
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: ${e.toString()}')),
      );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Αποτρέπει το "ανέβασμα" των στοιχείων
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
                  const SizedBox(height: 90), // Spacing from the top

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