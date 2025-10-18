// lib/data/repositories/poster_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

// 💡 REPLACE THIS WITH YOUR ACTUAL VERSEL DEPLOYMENT URL
const String VERCEL_FUNCTION_URL = 'https://[your-project-name].vercel.app/api/generate-poster';

class PosterRepository {
  // We no longer need FirebaseFunctions instance

  Future<String> generatePoster({
    required String base64Image,
    required String description,
    required String templateName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(VERCEL_FUNCTION_URL),
        headers: {
          'Content-Type': 'application/json',
          // Optionally, add a simple custom header for security if you implement
          // a secret key validation on the Vercel side later.
        },
        body: jsonEncode({
          'base64Image': base64Image,
          'description': description,
          'templateName': templateName,
        }),
      ).timeout(const Duration(seconds: 45)); // Image generation can be slow

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return data['base64Poster'] as String;
      }
      
      // Handle non-200 HTTP status codes and backend errors
      final errorMessage = data['message'] ?? 'Unknown API error.';
      throw Exception('Generation failed: $errorMessage');

    } catch (e) {
      // Catch network errors, timeouts, and JSON decoding errors
      throw Exception('Network or API Error: $e');
    }
  }
}