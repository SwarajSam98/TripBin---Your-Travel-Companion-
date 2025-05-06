import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FlightsPage extends StatefulWidget {
  @override
  _FlightsPageState createState() => _FlightsPageState();
}

class _FlightsPageState extends State<FlightsPage> {
  final TextEditingController _startLocationController = TextEditingController();
  final TextEditingController _endLocationController = TextEditingController();
  final TextEditingController _departureDateController = TextEditingController();
  final TextEditingController _returnDateController = TextEditingController();

  List<Map<String, String>> _flights = []; // To store flight details
  bool _isLoading = false; // To show loading spinner

  @override
  void initState() {
    super.initState();
  }

  // Show date picker for both departure and return dates
  _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  // Format date into readable time format (HH:mm)
  String _formatDateTime(String dateTime) {
    try {
      DateTime parsedDate = DateTime.parse(dateTime);
      return DateFormat('HH:mm').format(parsedDate);
    } catch (e) {
      return 'N/A'; // Return 'N/A' in case of invalid date
    }
  }

  // Fetch flight data from AviationStack API
  Future<void> _fetchFlightData() async {
    setState(() {
      _isLoading = true;
    });

    final String apiKey = '64c73c56c37603c903181b5a437c2057';
    final String startLocation = _startLocationController.text;
    final String endLocation = _endLocationController.text;
    final String departureDate = _departureDateController.text;
    final String returnDate = _returnDateController.text;

    final Uri url = Uri.parse(
        'http://api.aviationstack.com/v1/flights?access_key=$apiKey&dep_iata=$startLocation&arr_iata=$endLocation&date_from=$departureDate&date_to=$returnDate');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Extract flight data and update the list
        List<Map<String, String>> fetchedFlights = [];
        if (data['data'] != null) {
          for (var flight in data['data']) {
            fetchedFlights.add({
              'startLocation': flight['departure']['airport'], // Airport name
              'endLocation': flight['arrival']['airport'], // Airport name
              'departureDate': flight['departure']['estimated'], // Departure time
              'arrivalDate': flight['arrival']['estimated'], // Arrival time
            });
          }
        }
        setState(() {
          _flights = fetchedFlights;
        });
      } else {
        print('Failed to load flight data');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Flights'),
        backgroundColor: const Color(0xFF007B7D), // Teal color
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start Location Input
            TextField(
              controller: _startLocationController,
              decoration: InputDecoration(
                labelText: 'Start Location (IATA Code)',
                border: OutlineInputBorder(),
                hintText: 'Enter start location (IATA)',
              ),
            ),
            const SizedBox(height: 16),

            // End Location Input
            TextField(
              controller: _endLocationController,
              decoration: InputDecoration(
                labelText: 'End Location (IATA Code)',
                border: OutlineInputBorder(),
                hintText: 'Enter end location (IATA)',
              ),
            ),
            const SizedBox(height: 16),

            // Departure Date Input
            TextField(
              controller: _departureDateController,
              decoration: InputDecoration(
                labelText: 'Departure Date',
                border: OutlineInputBorder(),
                hintText: 'Select departure date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _departureDateController),
            ),
            const SizedBox(height: 16),

            // Return Date Input
            TextField(
              controller: _returnDateController,
              decoration: InputDecoration(
                labelText: 'Return Date',
                border: OutlineInputBorder(),
                hintText: 'Select return date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _returnDateController),
            ),
            const SizedBox(height: 16),

            // Fetch Button
            ElevatedButton(
              onPressed: _fetchFlightData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007B7D), // Teal color for button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : const Text('Fetch Flights'),
            ),
            const SizedBox(height: 20),

            // Display the list of flights
            Expanded(
              child: _flights.isEmpty
                  ? Center(child: Text('No flights available.'))
                  : ListView.builder(
                itemCount: _flights.length,
                itemBuilder: (context, index) {
                  var flight = _flights[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(
                        '${flight['startLocation']} to ${flight['endLocation']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Departure: ${_formatDateTime(flight['departureDate']!)}'),
                          Text('Arrival: ${_formatDateTime(flight['arrivalDate']!)}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
