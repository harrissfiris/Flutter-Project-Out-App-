import 'package:flutter/material.dart';
import '../../widgets/back_button_widget.dart';

class MyFriendsPage extends StatelessWidget {
  const MyFriendsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          
          // Back Button
          BackButtonWidget(),

          Center(
            child: Text(
              'My Friends Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
