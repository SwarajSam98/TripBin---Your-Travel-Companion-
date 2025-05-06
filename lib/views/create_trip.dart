import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_autocomplete/smart_autocomplete.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart'; // For formatting dates
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'; // For date picker
import 'package:cloud_firestore/cloud_firestore.dart';



class CreateTripPage extends StatefulWidget {
  @override
  _CreateTripPageState createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateTripPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _budgetController = TextEditingController();
  TextEditingController _placeController = TextEditingController();
  TextEditingController _autocompleteController = TextEditingController();
  TextEditingController _startDateController = TextEditingController(); // Added controller for start date
  TextEditingController _endDateController = TextEditingController();   // Added controller for end date
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  // Cities list from JSON
  List<Map<String, String>> cities = [];
  bool showSuggestions = true;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _startDateController.text = DateFormat.yMd().format(_startDate); // Initialize start date controller text
    _endDateController.text = DateFormat.yMd().format(_endDate); // Initialize end date controller text
  }

  // Load cities from the JSON file
  Future<void> _loadCities() async {
    final String data = await rootBundle.loadString('lib/assets/cities.json');
    final List<dynamic> jsonData = json.decode(data);

    setState(() {
      // Map the JSON data to List<Map<String, String>> and cast each field properly
      cities = jsonData.map((cityData) {
        return {
          'city': cityData['city'] as String,
          'country': cityData['country'] as String,
        };
      }).toList();
    });

    print("Cities loaded: ${cities.length}");
  }

  // Fetch suggestions based on the user's query
  Future<List<String>> getSuggestions(String key) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (key.isEmpty) return [];

    // Filter cities based on the query
    return cities
        .where((city) =>
        city['city']!.toLowerCase().startsWith(key.toLowerCase()))
        .map((city) => "${city['city']}, ${city['country']}")
        .toList();
  }

  // Handle when a suggestion is selected
  void _onSuggestionSelected(String suggestion) {
    _autocompleteController.text = suggestion;
    setState(() {
      showSuggestions = false; // Hide suggestions after selection
    });
  }

  // Date picker for start date
  void _selectStartDate() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        onConfirm: (date) {
          setState(() {
            _startDate = date;
            _startDateController.text = DateFormat.yMd().format(_startDate); // Update start date text field
          });
        },
        currentTime: _startDate, locale: LocaleType.en);
  }

  // Date picker for end date
  void _selectEndDate() {
    DatePicker.showDatePicker(context,
        showTitleActions: true,
        onConfirm: (date) {
          setState(() {
            _endDate = date;
            _endDateController.text = DateFormat.yMd().format(_endDate); // Update end date text field
          });
        },
        currentTime: _endDate, locale: LocaleType.en);
  }

  // Submit the form data
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Get the current user UID
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        // If no user is logged in, show error and return
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in.')),
        );
        return;
      }

      // Prepare data to send to Firestore
      final Map<String, dynamic> tripData = {
        'title': _titleController.text,
        'startDate': _startDate,
        'endDate': _endDate,
        'budget': _budgetController.text,
        'place': _autocompleteController.text,
        'userId': user.uid, // Store the user ID to link the trip with the user
      };

      // Reference to Firestore collection
      CollectionReference trips = FirebaseFirestore.instance.collection('trips');

      try {
        // Add data to Firestore
        await trips.add(tripData);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Trip created successfully!')),
        );

        // Navigate back to the Home screen
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } catch (e) {
        // Handle errors (e.g., network issues)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create trip: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Trip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Start Date field
              GestureDetector(
                onTap: _selectStartDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _startDateController, // Use the start date controller
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // End Date field
              GestureDetector(
                onTap: _selectEndDate,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _endDateController, // Use the end date controller
                    decoration: InputDecoration(
                      labelText: 'End Date',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Budget field
              TextFormField(
                controller: _budgetController,
                decoration: InputDecoration(labelText: 'Budget'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a budget';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Place Autocomplete using SmartAutoCompleteWidget
              SmartAutoCompleteWidget<String>(
                controller: _autocompleteController,
                loadingWidgetBuilder: () => showSuggestions
                    ? const SizedBox(
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                )
                    : const SizedBox.shrink(),
                suggestionsBuilder: (context, data) {
                  if (!showSuggestions || data.isEmpty) {
                    return const SizedBox.shrink();
                  } else {
                    return LimitedBox(
                      maxHeight: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final item = data[index];
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              _onSuggestionSelected(item);
                            },
                          );
                        },
                      ),
                    );
                  }
                },
                getSuggestions: getSuggestions,
                onChanged: (f) {
                  setState(() {
                    showSuggestions = true; // Show suggestions on input change
                  });
                },
                getAutocompletion: (text) async {
                  return null; // Not using autocompletion in this case
                },
              ),
              SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
