import 'dart:convert';
import 'dart:io';  // Required for File class
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class NewPostPage extends StatefulWidget {
  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  XFile? _image;  // Store the selected image
  String? _imageBase64;  // Store base64-encoded image string
  final ImagePicker _picker = ImagePicker();  // Image picker instance

  // Firebase instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });

      // Convert image to base64 string
      _convertImageToBase64(_image!);
    }
  }

  // Function to compress and convert the image to base64
  Future<void> _convertImageToBase64(XFile imageFile) async {
    try {
      final file = File(imageFile.path);

      // Read the image file and convert it to base64
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBase64 = base64Encode(bytes);  // Convert image to base64 string
      });
    } catch (e) {
      print('Error while converting image to base64: $e');
    }
  }

  // Function to submit the post (either text or image post)
  void _submitPost() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final user = _auth.currentUser;
        if (user != null) {
          // Fetch user details from Firestore
          final userDoc = await _firestore.collection('users').doc(user.uid).get();
          final userData = userDoc.data();

          if (userData == null) {
            throw 'User data not found in Firestore';
          }

          // Extract username and profileUrl from Firestore
          final username = userData['name'] ?? 'Anonymous';
          final profileUrl = userData['profileImageUrl'] ?? 'lib/assets/default-profile-pic.jpg';

          // Add post data to Firestore
          await _firestore.collection('posts').add({
            'title': _title,
            'description': _description,
            'imageBase64': _imageBase64 ?? '', // Store the base64 string or an empty string
            'userId': user.uid,
            'username': username,
            'userProfilePic': profileUrl, // Use profile picture from Firestore
            'timestamp': FieldValue.serverTimestamp(),
            'likes': [],
            'comments': [],
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Post created successfully!')),
          );

          // Navigate to FeedPage after submitting the post
          Navigator.pushReplacementNamed(context, '/home'); // Assuming the FeedPage is part of HomePage
        }
      } catch (e) {
        print('Error creating post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create post')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Post'),
        backgroundColor: const Color(0xFF007B7D), // Teal theme color
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create a New Post',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
                const SizedBox(height: 16),
                // Image Upload Button
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Upload Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007B7D),
                    foregroundColor: Colors.white,
                  ),
                ),
                if (_image != null) // Display the selected image
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Image.file(File(_image!.path), height: 150),
                  ),
                const SizedBox(height: 32),
                // Submit Post Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF007B7D), // Teal button
                        foregroundColor: Colors.white
                    ),
                    child: const Text('Submit Post'),
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