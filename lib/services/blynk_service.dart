import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';

class BlynkService {
  static const String baseUrl = 'https://blynk.cloud/external/api/get';
  static const String token =
      'T1y41jangmId_xwDx9d5FT9hX3zRuglg'; // Replace with your actual token

  Future<SensorData?> fetchSensorData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl?token=$token&V0&V1&V6&V7&V8&V9&V10&V11'));

      print('Blynk API status: ${response.statusCode}');
      print('Blynk API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SensorData.fromJson(data);
      } else {
        throw Exception('Failed to load sensor data');
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Return mock data for testing
      return SensorData(
        gas: 50.0,
        alcohol: 0.0,
        mpuX: 1.0,
        mpuY: 2.0,
        mpuZ: 3.0,
        temperature: 25.0,
        humidity: 65.0,
        userTemperature: 37.2,
        timestamp: DateTime.now(),
      );
    }
  }
}
