
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:tripbin_app/views/place_detail.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Explore the World',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ExplorePage(),
    );
  }
}

class ExplorePage extends StatelessWidget {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  // Fetch places from Firebase Realtime Database
  Future<List<Map<String, dynamic>>> _fetchPlaces(String category) async {
    try {
      print("Fetching data from path: places/$category");  // Debugging the path
      DataSnapshot snapshot = await _databaseRef.child('places/$category').get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> places = [];
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          places.add({
            'title': value['title'],
            'image': value['image'],
            'description': value['description'],
            'top_attractions': List<String>.from(value['top_attractions']),
          });
        });
        return places;
      } else {
        print("No data available for category: $category");
        return [];
      }
    } catch (e) {
      print("Error fetching places: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Section
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1500835556837-99ac94a94552?q=80&w=2574&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore the World',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Discover trending destinations and hidden gems.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Trending Places Section
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPlaces('trending_places'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading data"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No places found"));
                }
                return SectionWithCards(
                  title: 'Trending Places to Visit',
                  places: snapshot.data!,
                );
              },
            ),
            SizedBox(height: 16),

            // Top Rated Section
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPlaces('top_rated_places'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading data"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No places found"));
                }
                return SectionWithCards(
                  title: 'Top Rated Places',
                  places: snapshot.data!,
                );
              },
            ),
            SizedBox(height: 16),

            // Hidden Gems Section
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchPlaces('hidden_gems'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error loading data"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No places found"));
                }
                return SectionWithCards(
                  title: 'Hidden Gems',
                  places: snapshot.data!,
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class SectionWithCards extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> places;

  const SectionWithCards({
    Key? key,
    required this.title,
    required this.places,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading for each section
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),

          // Horizontal list of cards (scrollable)
          Container(
            height: 200, // Adjust this for card height
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              itemBuilder: (context, index) {
                final place = places[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the PlaceDetailPage and pass the place data
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailPage(),
                          settings: RouteSettings(
                            arguments: place,  // Pass the entire place data
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              place['image'], // Changed to network image URL
                              width: 170, // Card width
                              height: 150, // Card height
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              place['title'], // Place title
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}