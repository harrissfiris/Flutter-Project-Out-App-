import 'package:flutter/material.dart';

class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Stack(
        children: [
          Center(
            child: Text(
              'QR Code Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
