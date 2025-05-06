
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Convert user data to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bio': bio,
      'birthdate': birthdate,
      'profileImageUrl': profileImageUrl,
    };
  }

  // Create a UserProfile from a Firestore document snapshot
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'],
      bio: map['bio'],
      birthdate: (map['birthdate'] as Timestamp).toDate(),
      profileImageUrl: map['profileImageUrl'],
    );
  }
}