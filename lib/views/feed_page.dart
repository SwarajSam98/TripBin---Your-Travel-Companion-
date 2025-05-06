import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        backgroundColor: const Color(0xFF007B7D), // Teal theme color
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('posts').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              String base64Image = post['imageBase64'] ?? '';
              Uint8List? imageBytes = base64Image.isNotEmpty ? base64Decode(base64Image) : null;

              // Fetch user details dynamically
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(post['userId']).get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const SizedBox.shrink(); // Return an empty widget while loading
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                  if (userData == null) {
                    return const SizedBox.shrink();
                  }

                  // Extract user data
                  String username = userData['name'] ?? 'Anonymous';
                  String profilePicUrl = userData['profileImageUrl'] ?? 'lib/assets/default-profile-pic.jpg';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Username and Post Time
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage(profilePicUrl),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                username,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _formatTimestamp(post['timestamp']),
                                style: TextStyle(color: const Color(0xFF007B7D), fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Post Title
                          Text(
                            post['title'],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Post Description
                          Text(
                            post['description'],
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          // Image (if exists)
                          if (imageBytes != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(imageBytes, fit: BoxFit.cover),
                            ),
                          const SizedBox(height: 10),
                          // Divider and like/comment actions
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Like button
                              IconButton(
                                icon: Icon(
                                  post['likes'].contains(_auth.currentUser?.uid)
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  color: post['likes'].contains(_auth.currentUser?.uid) ? const Color(0xFF007B7D) : Colors.grey,
                                ),
                                onPressed: () => _toggleLike(post.id, post['likes']),
                              ),
                              Text('${post['likes'].length} likes'),
                              IconButton(
                                icon: const Icon(Icons.comment_outlined, color: Color(0xFF007B7D)),
                                onPressed: () {
                                  _showComments(context, post.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }


  // Toggle like/unlike
  void _toggleLike(String postId, List<dynamic> currentLikes) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    if (currentLikes.contains(user.uid)) {
      // Remove like
      await postRef.update({
        'likes': FieldValue.arrayRemove([user.uid]),
      });
    } else {
      // Add like
      await postRef.update({
        'likes': FieldValue.arrayUnion([user.uid]),
      });
    }
  }

  // Format the timestamp for readability
  String _formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  // Show comments for the post
  void _showComments(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the bottom sheet to take up more space
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: CommentsSection(postId: postId),
        );
      },
    );
  }
}

class CommentsSection extends StatefulWidget {
  final String postId;
  CommentsSection({required this.postId});

  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  final TextEditingController _commentController = TextEditingController();

  void _submitComment() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null && _commentController.text.isNotEmpty) {
      // Fetch user data from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final userData = userDoc.data();

      if (userData != null) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(widget.postId)
            .collection('comments')
            .add({
          'comment': _commentController.text,
          'userId': user.uid,
          'username': userData['name'] ?? 'Anonymous', // Fetch from user model
          'userProfilePic': userData['profileImageUrl'] ?? 'lib/assets/default-profile-pic.jpg', // Fetch profile picture
          'timestamp': FieldValue.serverTimestamp(),
        });

        _commentController.clear();
        setState(() {}); // Refresh the comment list
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.8, // Set height for better usability
      child: Column(
        children: [
          const Text(
            'Comments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final comments = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index];

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(comment['userId']).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return const SizedBox.shrink();
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                        String username = userData?['name'] ?? 'Anonymous';
                        String profilePicUrl = userData?['profileImageUrl'] ?? 'lib/assets/default-profile-pic.jpg';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(profilePicUrl), // Profile picture from Firestore
                          ),
                          title: Text(
                            username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(comment['comment']),
                          trailing: Text(
                            _formatTimestamp(comment['timestamp']),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF007B7D)),
                onPressed: _submitComment,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}