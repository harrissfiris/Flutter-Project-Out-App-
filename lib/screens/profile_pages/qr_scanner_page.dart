import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class QRScannerPage extends StatefulWidget {
 const QRScannerPage({super.key});


 @override
 State<QRScannerPage> createState() => _QRScannerPageState();
}


class _QRScannerPageState extends State<QRScannerPage> {
 bool _isProcessing = false;


 Future<void> _addFriend(String scannedUid) async {
   try {
     final currentUser = FirebaseAuth.instance.currentUser;
     if (currentUser == null) {
       throw Exception("No logged-in user");
     }


     final currentUid = currentUser.uid;


     // Ενημέρωση φίλων για τον τρέχοντα χρήστη
     await FirebaseFirestore.instance.collection('users').doc(currentUid).update({
       'friends': FieldValue.arrayUnion([scannedUid])
     });


     // Ενημέρωση φίλων για τον σκαναρισμένο χρήστη
     await FirebaseFirestore.instance.collection('users').doc(scannedUid).update({
       'friends': FieldValue.arrayUnion([currentUid])
     });


     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('You are now friends with $scannedUid')),
     );
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Error adding friend: $e')),
     );
   }
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     extendBodyBehindAppBar: true, // Το AppBar πίσω από το περιεχόμενο
appBar: AppBar(
  backgroundColor: Colors.transparent, // Διαφάνεια
  elevation: 0, // Αφαιρεί τη σκιά
  iconTheme: const IconThemeData(color: Colors.black), // Χρώμα του back button
  leading: IconButton(
    icon: const Icon(Icons.arrow_back_ios), // Χρησιμοποιεί το "<" για όλα τα platforms
    onPressed: () {
      Navigator.pop(context);
    },
  ),
),
     body: MobileScanner(
       onDetect: (capture) async {
         if (_isProcessing) return;


         setState(() {
           _isProcessing = true;
         });


         final barcodes = capture.barcodes;
         if (barcodes.isNotEmpty) {
           final barcode = barcodes.first;


           if (barcode.rawValue != null) {
             final String scannedUid = barcode.rawValue!;


             // Επεξεργασία του σκαναρισμένου QR code
             await _addFriend(scannedUid);
           }
         }


         setState(() {
           _isProcessing = false;
         });
       },
     ),
   );
 }
}
