import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/city_model.dart';

class CityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to fetch cities matching the search query
  Future<List<City>> findCities(String query) async {
    final snapshot = await _firestore
        .collection('cities') // Ensure your Firestore collection is called 'cities'
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    return snapshot.docs
        .map((doc) => City.fromFirestore(doc))
        .toList();
  }
}
