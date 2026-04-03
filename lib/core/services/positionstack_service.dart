import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_keys.dart';

class PositionStackService {
  static const String _baseUrl = 'http://api.positionstack.com/v1';

  /// Forward Geocoding: Convert an address to coordinates (latitude, longitude)
  static Future<Map<String, double>?> getCoordinates(String address) async {
    final uri = Uri.parse(
        '$_baseUrl/forward?access_key=${ApiKeys.positionStack}&query=${Uri.encodeComponent(address)}&limit=1');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final firstResult = data['data'][0];
          return {
            'latitude': (firstResult['latitude'] as num).toDouble(),
            'longitude': (firstResult['longitude'] as num).toDouble(),
          };
        }
      } else {
        print(
            'PositionStack API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error verifying address with PositionStack: $e');
    }
    return null;
  }

  /// Reverse Geocoding: Convert coordinates (latitude, longitude) to an address
  static Future<String?> getAddress(double latitude, double longitude) async {
    final uri = Uri.parse(
        '$_baseUrl/reverse?access_key=${ApiKeys.positionStack}&query=$latitude,$longitude&limit=1');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && (data['data'] as List).isNotEmpty) {
          final result = data['data'][0];
          // Construct a readable address from available fields
          final List<String> addressParts = [];
          if (result['name'] != null) addressParts.add(result['name']);
          if (result['street'] != null && result['name'] != result['street'])
            addressParts.add(result['street']);
          if (result['locality'] != null) addressParts.add(result['locality']);
          if (result['region'] != null) addressParts.add(result['region']);
          if (result['country'] != null) addressParts.add(result['country']);

          return result['label'] ?? addressParts.join(', ');
        }
      } else {
        print(
            'PositionStack API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error reverse geocoding with PositionStack: $e');
    }
    return null;
  }
}


