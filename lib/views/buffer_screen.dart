import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BufferScreen extends StatefulWidget {
  @override
  _BufferScreenState createState() => _BufferScreenState();
}

class _BufferScreenState extends State<BufferScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  void _checkUserStatus() async {
    // Simulate a delay for splash effect (optional)
    await Future.delayed(Duration(seconds: 2));

    // Check if the user is logged in
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // User is logged in, navigate to Home page
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // User is not logged in, navigate to Login/Sign-Up page
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            // Add your app's logo or name here
            Image.asset(
              'lib/images/TripBin.png', // Ensure you have a logo in your assets
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              "TripBin",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(), // Loading spinner
          ],
        ),
      ),
    );
  }
}