import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trip_model.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch trips for a specific user
  Stream<List<Trip>> getTrips(String userId) {
    return _db
        .collection('trips')
        .where('userId', isEqualTo: userId)
        .orderBy('startDate')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Trip.fromDocument(doc)).toList());
  }

  // Add a new trip
  Future<void> addTrip(Trip trip) {
    return _db.collection('trips').add(trip.toMap());
  }

  // Update an existing trip
  Future<void> updateTrip(Trip trip) {
    return _db.collection('trips').doc(trip.id).update(trip.toMap());
  }

  // Delete a trip
  Future<void> deleteTrip(String tripId) {
    return _db.collection('trips').doc(tripId).delete();
  }
}
