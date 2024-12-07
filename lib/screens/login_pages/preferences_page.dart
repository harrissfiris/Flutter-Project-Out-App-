import 'package:flutter/material.dart';
import '../../main_app.dart';
import '../../widgets/rounded_button.dart';
import '../../widgets/back_button_widget.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  final List<String> interests = [
    'Pottery', 'Music', 'Cars', 'Extreme Sports', 'Animals', 'Sea', 'Mountain',
    'Movies', 'Books', 'Fine dining', 'Tech', 'Dance', 'Sports', 'Drinking',
    'Art', 'DIY', 'Volunteering', 'Comedy', 'Games', 'Beauty',
  ];

  final List<String> selectedInterests = [];

  void toggleSelection(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background (αν υπάρχει background)
          Container(
            color: Colors.white, // Αντικατέστησε με εικόνα αν χρειάζεται
          ),

          // Back Button
          const BackButtonWidget(),

          // Content
          Padding(
            padding: const EdgeInsets.only(top: 140, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                const Text(
                  'Choose your interests!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                const Text(
                  'Pick 3 or more categories',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Interests List
                Expanded(
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: interests.map((interest) {
                      final isSelected = selectedInterests.contains(interest);
                      return GestureDetector(
                        onTap: () => toggleSelection(interest),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFB39DDB)
                                : const Color(0xFFEDE7F6),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF7E57C2)
                                  : const Color(0xFFD1C4E9),
                            ),
                          ),
                          child: Text(
                            interest,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Rounded Button at the Bottom
          Positioned(
            bottom: 50, // Απόσταση 50 pixels από το κάτω μέρος
            left: 20, // Απόσταση από αριστερά
            right: 20, // Απόσταση από δεξιά
            child: RoundedButton(
              text: "Ready",
              onPressed: () {
                if (selectedInterests.length >= 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainApp()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select at least 3 categories'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
