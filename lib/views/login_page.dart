import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF007B7D), // Teal background
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                // Logo outside the white container
                Image.asset(
                  'lib/assets/tripbin_logo.png', // Ensure the image path is correct
                  width: 180,
                ),

                // White container with login form inside
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white, // White card background
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Let’s Bin Your Trip In",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007B7D),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Explore the World with Every Log In",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF336749),
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Email or Phone Input
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0), // Added horizontal padding
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          validator: (val) => val!.isEmpty ? 'Enter an email or phone number' : null,
                          onChanged: (val) => setState(() => email = val),
                        ),
                        const SizedBox(height: 16),
                        // Password Input
                        TextFormField(
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12.0), // Add horizontal padding
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),

                          validator: (val) => val!.length < 6 ? 'Enter a password 6+ chars long' : null,
                          onChanged: (val) => setState(() => password = val),
                        ),
                        const SizedBox(height: 8),
                        // Forgot Password Link
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Handle forgot password
                            },
                            child: const Text(
                              'Forgot password?',
                              style: TextStyle(
                                color: Color(0xFF336749),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Sign In Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                dynamic result = await _auth.signIn(email, password);
                                if (result == null) {
                                  setState(() => error = 'Invalid email or password');
                                } else {
                                  // Navigate to home
                                  Navigator.pushReplacementNamed(context, '/home');
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF007B7D),
                              foregroundColor: Colors.white, // Teal text
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error,
                          style: const TextStyle(color: Colors.red, fontSize: 14.0),
                        ),
                        const SizedBox(height: 40),
                        // Sign Up Section
                        Column(
                          children: [
                            const Text(
                              "I don’t have an account?",
                              style: TextStyle(color: Colors.black),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignUpPage()),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.black),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: const Color(0xFF007B7D),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
