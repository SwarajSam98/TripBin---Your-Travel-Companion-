import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'explore_page.dart'; // Import the ExplorePage
import 'feed_page.dart';
import 'new_post_page.dart';
import 'profile_page.dart';
import 'itinerary_page.dart'; // Import the Itinerary page
import 'bookings_page.dart';  // Import the Bookings page
import 'flights_page.dart';   // Import the Flights page
import 'budget_page.dart';    // Import the Budget page

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages corresponding to the selected tab
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      // Home Page with Banner Image
      Scaffold(
        appBar: AppBar(
          title: const Text('TripBin'),
          backgroundColor: Colors.teal, // Make the app bar transparent
          foregroundColor: Colors.white,
          elevation: 0, // Remove shadow under the app bar
          actions: [
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'signOut') {
                  // Log out the user
                  await FirebaseAuth.instance.signOut();
                  // Navigate back to the login page
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  const PopupMenuItem(
                    value: 'signOut',
                    child: Text('Sign Out'),
                  ),
                ];
              },
              icon: const Icon(Icons.settings), // Settings icon
            ),
          ],
        ),
        body: Column(
          children: [
            // Banner image at the top
            Container(
              width: double.infinity,
              height: 250, // Set a height for the banner
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/banner.png'), // Your banner image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Row of circular icon buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircularIcon(Icons.access_alarm, 'Itinerary', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ItinerariesPage()));
                  }),
                  _buildCircularIcon(Icons.hotel, 'Bookings', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BookingsPage()));
                  }),
                  _buildCircularIcon(Icons.flight_takeoff, 'Flights', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FlightsPage()));
                  }),
                  _buildCircularIcon(Icons.attach_money, 'Budget', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => BudgetPage()));
                  }),
                ],
              ),
            ),
            // FutureBuilder to check if the user is logged in
            FutureBuilder<User?>(
              future: FirebaseAuth.instance.currentUser != null
                  ? Future.value(FirebaseAuth.instance.currentUser)
                  : Future.value(null),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData) {
                  return Center(child: Text('No user logged in.'));
                }

                String currentUserId = snapshot.data!.uid;

                // Fetch trips from Firestore where userId matches
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('trips')
                      .where('userId', isEqualTo: currentUserId)
                      .snapshots(),
                  builder: (context, tripSnapshot) {
                    if (tripSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!tripSnapshot.hasData || tripSnapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No trips found.'));
                    }

                    // Iterate through all the trips
                    return Expanded(
                      child: ListView.builder(
                        itemCount: tripSnapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var tripData = tripSnapshot.data!.docs[index];
                          var title = tripData['title'];
                          var place = tripData['place'];
                          var budget = tripData['budget'];
                          var startDate = (tripData['startDate'] as Timestamp).toDate();
                          var endDate = (tripData['endDate'] as Timestamp).toDate();

                          // Create a card for each trip
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            elevation: 5,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(15),
                              title: Text(title, style: TextStyle(fontSize: 18)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Place: $place'),
                                  Text('Budget: \$${budget}'),
                                  Text('Start Date: ${DateFormat.yMd().format(startDate)}'),
                                  Text('End Date: ${DateFormat.yMd().format(endDate)}'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // Navigate to trip creation page
            Navigator.pushNamed(context, '/createTrip');
          },
          backgroundColor: const Color(0xFF007B7D),
          foregroundColor: const Color(0xFFFFFFFF), // Teal color for FAB
          child: const Icon(Icons.add),
          tooltip: 'Add Trip',
        ),
      ),
      FeedPage(),
      NewPostPage(),
      ExplorePage(),
      ProfilePage(),
    ]);
  }

  // Helper method to create circular icon buttons
  Widget _buildCircularIcon(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF007B7D), // Teal color for the circle
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Method to handle tab changes
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected tab's page content
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped, // Handle tab change
        backgroundColor: Colors.white, // White background for the bar
        selectedItemColor: const Color(0xFF007B7D), // Teal for selected item
        unselectedItemColor: Colors.grey, // Gray for unselected items
        selectedFontSize: 14.0, // Highlighted font size
        unselectedFontSize: 12.0, // Smaller font for unselected items
        type: BottomNavigationBarType.fixed, // Ensures all icons are visible
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.feed),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
