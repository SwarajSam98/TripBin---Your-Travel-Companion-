import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetPage extends StatefulWidget {
  @override
  _BudgetPageState createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final TextEditingController _budgetController = TextEditingController();
  String _storedBudget = '0';

  @override
  void initState() {
    super.initState();
    _loadBudget();
  }

  // Load the saved budget from shared preferences
  _loadBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _storedBudget = prefs.getString('budget') ?? '0';  // Default value is '0' if no value is found
    });
  }

  // Save the budget to shared preferences
  _saveBudget() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('budget', _budgetController.text);  // Save the budget
    _loadBudget();  // Reload the saved budget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        backgroundColor: const Color(0xFF007B7D), // Teal color
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the saved budget
            Text(
              'Saved Budget: \$$_storedBudget',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Budget input field
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(
                labelText: 'Enter Budget',
                border: OutlineInputBorder(),
                hintText: 'Enter your budget for the trip',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // Optionally, you can do real-time validation here
              },
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: () {
                if (_budgetController.text.isNotEmpty) {
                  _saveBudget(); // Save the budget
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007B7D), // Teal color for the button
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: const Text('Save Budget'),
            ),
          ],
        ),
      ),
    );
  }
}
