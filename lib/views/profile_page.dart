import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class UserProfile {
  String name;
  String bio;
  DateTime birthdate;
  String profileImageUrl;

  UserProfile({
    required this.name,
    required this.bio,
    required this.birthdate,
    required this.profileImageUrl,
  });

  // Convert UserProfile object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'birthdate': birthdate,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Convert Firestore document to UserProfile object
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      bio: map['bio'],
      birthdate: (map['birthdate'] as Timestamp).toDate(),
      profileImageUrl: map['profileImageUrl'],
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  DateTime? _birthdate;
  String? _profileImageUrl;

  late UserProfile _userProfile;

  bool _isLoading = true; // To show loading spinner while fetching data

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // Handle user not logged in (e.g., redirect to login screen)
        if (kDebugMode) {
          print('User is not logged in');
        }
      } else {
        // Fetch user profile if logged in
        _fetchUserProfile();
      }
    });
  }

  // Fetch user profile data from Firestore
  Future<void> _fetchUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user is signed in");
        setState(() {
          _isLoading = false;
        });
        return; // If no user is authenticated, stop loading
      }

      // Fetch user data from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!docSnapshot.exists) {
        print("User document does not exist in Firestore");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Convert the Firestore document to UserProfile object
      _userProfile = UserProfile.fromMap(docSnapshot.data()!);

      _nameController.text = _userProfile.name;
      _bioController.text = _userProfile.bio;
      _birthdate = _userProfile.birthdate;
      _profileImageUrl = _userProfile.profileImageUrl;

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print("Error fetching user profile: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImageUrl = pickedFile.path;
      });
    }
  }

  // Save profile data to Firestore
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final userProfile = UserProfile(
        name: _nameController.text,
        bio: _bioController.text,
        birthdate: _birthdate!,
        profileImageUrl: _profileImageUrl!,
      );

      final userId = FirebaseAuth.instance.currentUser!.uid;

      FirebaseFirestore.instance.collection('users').doc(userId).set(userProfile.toMap())
          .then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Profile updated")));
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile")));
      });
    }
  }

  // Date picker for birthdate
  Future<void> _pickBirthdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _birthdate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
        ),
        body: Center(child: CircularProgressIndicator()), // Show loading spinner
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF007B7D),  // Accent color for the app bar
        foregroundColor: Color(0xFFFFFFFF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Image
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 200,
                  backgroundImage: _profileImageUrl != null
                      ? FileImage(File(_profileImageUrl!))
                      : null,
                  child: _profileImageUrl == null
                      ? Icon(Icons.camera_alt, size: 40, color: Colors.white)
                      : null,
                  backgroundColor: Colors.grey[300],
                ),
              ),
              SizedBox(height: 20),

              // Name field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Bio field
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bio';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Birthdate picker
              Row(
                children: [
                  Text('Birthdate: ', style: TextStyle(fontSize: 16)),
                  Text(
                    _birthdate != null
                        ? DateFormat('yyyy-MM-dd').format(_birthdate!)
                        : 'Select a date',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickBirthdate,
                    color: Color(0xFF007B7D),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Save Button
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF007B7D),  // Accent color for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Save Profile',
                  style: TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
