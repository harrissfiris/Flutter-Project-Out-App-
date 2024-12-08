import 'package:flutter/material.dart';
import '../../widgets/plus_button.dart';

class GroupsPage extends StatelessWidget {
  const GroupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Δείγμα ονομάτων ομάδων
    final List<String> groups = [
      'Asterakia',
      'TrueMates',
      'DreamTeam',
      'Besties',
      'Tribe',
      'TheCircle',
    ];

    return Scaffold(
      body: Stack(
        children: [
          // Wallpaper Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_small_logo.jpg'), // Wallpaper
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo and Title
                  const Text(
                    "My Groups",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Plus Button
                  PlusButton(
                    onTap: () {
                      Navigator.pushNamed(context, '/group_creation_page');
                    },
                    labelText: "Create new group",
                  ),
                  const SizedBox(height: 20),

                  // List of Groups
                  Expanded(
                    child: ListView.builder(
                      itemCount: groups.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey[200],
                              child: const Icon(
                                Icons.group,
                                color: Colors.black,
                              ),
                            ),
                            title: Text(
                              groups[index],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () {
                              // Παράδειγμα πλοήγησης σε σελίδα ομάδας
                              Navigator.pushNamed(
                                context,
                                '/group_detail_page',
                                arguments: {'groupName': groups[index]},
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
