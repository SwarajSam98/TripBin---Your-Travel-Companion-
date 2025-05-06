import 'package:cloud_firestore/cloud_firestore.dart';

class City {
  final String name;
  final String country;

  City({required this.name, required this.country});

  // Factory constructor to create a City from Firestore data
  factory City.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return City(
      name: data['name'] ?? '',
      country: data['country'] ?? '',
    );
  }
}
