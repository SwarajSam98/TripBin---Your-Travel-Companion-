import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tripbin_app/views/create_trip.dart';
import 'package:tripbin_app/views/feed_page.dart';
import 'firebase_options.dart';
import 'views/buffer_screen.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TripBin',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/buffer',
      routes: {
        '/buffer': (context) => BufferScreen(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
        '/createTrip': (context) => CreateTripPage(),
      },
    );
  }
}
