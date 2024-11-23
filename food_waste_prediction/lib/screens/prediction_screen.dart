import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key); // Fixed the 'key' issue

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  // Controllers for input fields
  final TextEditingController _householdController = TextEditingController();
  final TextEditingController _retailController = TextEditingController();
  final TextEditingController _foodServiceController = TextEditingController();

  String _predictionResult = ''; // To display the prediction result
  bool _isLoading = false; // To show a loading spinner while waiting for the response

  // Function to make the API call
  Future<void> getPrediction() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('http://127.0.0.1:8000/predict'); // Replace with your API URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'household_estimate': double.tryParse(_householdController.text) ?? 0.0,
          'retail_estimate': double.tryParse(_retailController.text) ?? 0.0,
          'food_service_estimate': double.tryParse(_foodServiceController.text) ?? 0.0,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _predictionResult = 'Prediction: ${data['prediction']}';
        });
      } else {
        setState(() {
          _predictionResult = 'Error: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _predictionResult = 'Error: Could not connect to API.';
      });
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
        title: const Text(
          'Food Waste Prediction For Countries',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Make the title text bold
            fontSize: 20, // Optional: Adjust the font size as needed
            fontFamily: 'DM Sans', 
        
            // Change the font family (you can choose any available font)
          ),
        ),
        backgroundColor: Colors.teal[600],
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal[100]!, Colors.blue[100]!], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Use ListView instead of Column
          children: [
            // Image at the top of the screen
            Container(
              height: 250, // Adjust the height to fill the upper part
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/FOOD.jpg'),
                  fit: BoxFit.cover, // Cover the entire space
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Background colored container under the image
            Container(
              color: Colors.teal[600], // Set the color under the white box
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // White overlay container with rounded edges
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // White background for the overlay
                      borderRadius: BorderRadius.circular(20), // Rounded corners
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Household Estimate Input
                        _buildInputField(
                          controller: _householdController,
                          label: 'Household Estimate (kg/capita/year)',
                          icon: Icons.home,
                        ),
                        const SizedBox(height: 16),

                        // Retail Estimate Input
                        _buildInputField(
                          controller: _retailController,
                          label: 'Retail Estimate (kg/capita/year)',
                          icon: Icons.store,
                        ),
                        const SizedBox(height: 16),

                        // Food Service Estimate Input
                        _buildInputField(
                          controller: _foodServiceController,
                          label: 'Food Service Estimate (kg/capita/year)',
                          icon: Icons.restaurant,
                        ),
                        const SizedBox(height: 24),

                        // Get Prediction Button
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.teal[600]!, Colors.green[600]!],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: getPrediction,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent, // Transparent background for the button
                                    shadowColor: Colors.transparent, // Remove shadow
                                    padding: EdgeInsets.zero, // Remove default padding to use the container's padding
                                  ),
                                  child: const Text(
                                    'Get Prediction',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 16),

                        // Prediction Result
                        Text(
                          _predictionResult,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build input fields with icons and rounded corners
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.teal[700]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[700]!, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.teal[800]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
