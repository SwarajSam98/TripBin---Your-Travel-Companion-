import 'package:flutter/material.dart';

class ItinerariesPage extends StatelessWidget {
  // Sample data to represent itinerary items
  final List<Map<String, String>> itineraries = [
    {
      'destination': 'Bali, Indonesia',
      'startDate': '2024-12-10',
      'endDate': '2024-12-20',
      'description': 'A relaxing beach vacation with a few excursions.',
    },
    {
      'destination': 'New York, USA',
      'startDate': '2025-01-05',
      'endDate': '2025-01-10',
      'description': 'Explore the city with sightseeing, museums, and Broadway.',
    },
    {
      'destination': 'Paris, France',
      'startDate': '2025-03-15',
      'endDate': '2025-03-25',
      'description': 'Romantic getaway to explore art, culture, and food.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itineraries'),
        backgroundColor: const Color(0xFF007B7D), // Teal color
        foregroundColor: Colors.white, // Teal color

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: itineraries.length,
          itemBuilder: (context, index) {
            final itinerary = itineraries[index];
            return Card(
              elevation: 4.0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Destination Name
                    Text(
                      itinerary['destination']!,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Dates (Start and End)
                    Row(
                      children: [
                        Text(
                          'Start: ${itinerary['startDate']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'End: ${itinerary['endDate']}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12.0),
                    // Description
                    Text(
                      itinerary['description']!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    // Action button (e.g., Edit or View Details)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          // Implement the navigation or action
                          // For example, navigate to a detailed itinerary page
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007B7D), // Teal button
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text('View Details'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
