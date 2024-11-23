import 'package:flutter/material.dart';
import 'screens/prediction_screen.dart'; // Import the PredictionScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Waste Prediction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PredictionScreen(), // Set PredictionScreen as the home screen
    );
  }
}
