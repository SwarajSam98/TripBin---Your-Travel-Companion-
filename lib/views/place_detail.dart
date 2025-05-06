import 'package:flutter/material.dart';

class PlaceDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Retrieve the data passed from the ExplorePage (via Navigator)
    final Map<String, dynamic> place = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(place['title']),  // Title of the place
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the place image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  place['image'], // Place image from data
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 16),
              // Display the place description
              Text(
                place['description'],
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              SizedBox(height: 16),
              // Display the top attractions section
              Text(
                'Top Attractions',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Display each top attraction as a list
              for (var attraction in place['top_attractions'])
                ListTile(
                  leading: Icon(Icons.star, color: Colors.yellow),
                  title: Text(attraction),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
