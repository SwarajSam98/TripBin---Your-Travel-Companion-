import 'package:cloud_firestore/cloud_firestore.dart';

class Trip {
  String id;
  String name;
  DateTime startDate;
  DateTime endDate;
  List<String> destinations;
  double budget;
  String userId; // To associate trip with a user
  List<String> photos; // URLs of trip photos

  Trip({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.destinations,
    required this.budget,
    required this.userId,
    required this.photos,
  });

  // Convert Firestore document to Trip object
  factory Trip.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Trip(
      id: doc.id,
      name: data['name'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      destinations: List<String>.from(data['destinations'] ?? []),
      budget: (data['budget'] ?? 0).toDouble(),
      userId: data['userId'] ?? '',
      photos: List<String>.from(data['photos'] ?? []),
    );
  }

  // Convert Trip object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'destinations': destinations,
      'budget': budget,
      'userId': userId,
      'photos': photos,
    };
  }
}
