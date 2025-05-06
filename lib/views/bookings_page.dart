import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:shared_preferences/shared_preferences.dart';

class BookingsPage extends StatefulWidget {
  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final TextEditingController _hotelNameController = TextEditingController();
  final TextEditingController _checkInDateController = TextEditingController();
  final TextEditingController _checkOutDateController = TextEditingController();

  List<Map<String, String>> _bookings = []; // To store bookings

  @override
  void initState() {
    super.initState();
    _loadBookings(); // Load saved bookings when the page loads
  }

  // Load saved bookings from shared preferences
  _loadBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedBookings = prefs.getStringList('bookings');

    if (savedBookings != null) {
      setState(() {
        _bookings = savedBookings
            .map((item) => Map.fromEntries(item.split(';').map((e) {
          final keyValue = e.split(':');
          return MapEntry(keyValue[0], keyValue[1]);
        })))
            .toList();
      });
    }
  }

  // Save new booking to shared preferences
  _saveBooking() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String newBooking =
        'hotelName:${_hotelNameController.text};checkIn:${_checkInDateController.text};checkOut:${_checkOutDateController.text}';
    _bookings.add({
      'hotelName': _hotelNameController.text,
      'checkIn': _checkInDateController.text,
      'checkOut': _checkOutDateController.text
    });

    // Save the new list of bookings
    List<String> bookingsList =
    _bookings.map((item) => item.entries.map((e) => '${e.key}:${e.value}').join(';')).toList();
    prefs.setStringList('bookings', bookingsList);
    setState(() {});
  }

  // Show date picker for check-in and check-out dates
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hotel Bookings'),
        backgroundColor: const Color(0xFF007B7D), // Teal color
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Name Input
            TextField(
              controller: _hotelNameController,
              decoration: InputDecoration(
                labelText: 'Hotel Name',
                border: OutlineInputBorder(),
                hintText: 'Enter hotel name',
              ),
            ),
            const SizedBox(height: 16),

            // Check-In Date Input
            TextField(
              controller: _checkInDateController,
              decoration: InputDecoration(
                labelText: 'Check-In Date',
                border: OutlineInputBorder(),
                hintText: 'Select check-in date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _checkInDateController),
            ),
            const SizedBox(height: 16),

            // Check-Out Date Input
            TextField(
              controller: _checkOutDateController,
              decoration: InputDecoration(
                labelText: 'Check-Out Date',
                border: OutlineInputBorder(),
                hintText: 'Select check-out date',
              ),
              readOnly: true,
              onTap: () => _selectDate(context, _checkOutDateController),
            ),
            const SizedBox(height: 16),

            // Save Button
            ElevatedButton(
              onPressed: _saveBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007B7D), // Teal color for button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Save Booking'),
            ),
            const SizedBox(height: 20),

            // Display the list of saved bookings
            Expanded(
              child: _bookings.isEmpty
                  ? Center(child: Text('No bookings available.'))
                  : ListView.builder(
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  var booking = _bookings[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      title: Text(
                        'Hotel: ${booking['hotelName']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Check-In: ${booking['checkIn']}'),
                          Text('Check-Out: ${booking['checkOut']}'),
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
