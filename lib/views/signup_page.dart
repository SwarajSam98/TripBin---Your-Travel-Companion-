import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String confirmPassword = '';
  String name = ''; // Added name field
  String error = '';
  bool isAccepted = false; // Checkbox state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007B7D), // Teal background color
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white, // White card background
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Center(
                      child: Text(
                        'Create your account',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),

                    // Name TextField
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'ex: jon smith',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (val) =>
                      val!.isEmpty ? 'Enter your name' : null,
                      onChanged: (val) => setState(() => name = val),
                    ),
                    const SizedBox(height: 16.0),

                    // Email TextField
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'ex: jon.smith@email.com',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (val) =>
                      val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) => setState(() => email = val),
                    ),
                    const SizedBox(height: 16.0),

                    // Password TextField
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      obscureText: true,
                      validator: (val) {
                        if (val!.isEmpty) return 'Enter a password';
                        if (val.length < 6) {
                          return 'Password should be at least 6 characters';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => password = val),
                    ),
                    const SizedBox(height: 16.0),

                    // Confirm Password TextField
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      obscureText: true,
                      validator: (val) {
                        if (val!.isEmpty) return 'Confirm your password';
                        if (val != password) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      onChanged: (val) => setState(() => confirmPassword = val),
                    ),
                    const SizedBox(height: 16.0),

                    // Checkbox with Terms and Policy
                    Row(
                      children: [
                        Checkbox(
                          value: isAccepted,
                          onChanged: (val) {
                            setState(() => isAccepted = val!);
                          },
                        ),
                        const Text('I understood the '),
                        GestureDetector(
                          onTap: () {
                            // Handle terms & policy link
                          },
                          child: Text(
                            'terms & policy',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          if (!isAccepted) {
                            setState(() =>
                            error = 'Please accept the terms & policy');
                            return;
                          }
                          dynamic result = await _auth.register(email, password);
                          if (result == null) {
                            setState(() =>
                            error = 'Could not sign up with provided details');
                          } else {
                            // Navigate to Home Page
                            Navigator.pop(context);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007B7D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      child: Center(
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    // Error message
                    if (error.isNotEmpty)
                      Text(
                        error,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 14.0,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
