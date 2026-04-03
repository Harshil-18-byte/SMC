import 'package:latlong2/latlong.dart';

/// Pan-India Location Utilities for Bharat Infra Platform
class IndiaLocationUtils {
  // Center of India (Nagpur Region)
  static const double defaultLat = 20.5937;
  static const double defaultLng = 78.9629;

  static const LatLng indiaCenter = LatLng(defaultLat, defaultLng);

  // Geographic bounds for National View
  static const double nationalZoom = 4.5;
  
  // State Capitals for regional dashboards
  static const Map<String, LatLng> stateCapitals = {
    'Maharashtra': LatLng(18.9220, 72.8347),
    'Karnataka': LatLng(12.9716, 77.5946),
    'Delhi': LatLng(28.7041, 77.1025),
    'Gujarat': LatLng(23.2156, 72.6369),
    'Tamil Nadu': LatLng(13.0827, 80.2707),
    'West Bengal': LatLng(22.5726, 88.3639),
    'UP': LatLng(26.8467, 80.9462),
    'Telangana': LatLng(17.3850, 78.4867),
    'Rajasthan': LatLng(26.9124, 75.7873),
    'Punjab': LatLng(30.7333, 76.7794),
  };

  /// Get center for a specific state
  static LatLng getStateCenter(String state) {
    return stateCapitals[state] ?? indiaCenter;
  }

  /// Get simplified human readable location string
  static String getHumanReadableLocation(double lat, double lng) {
    if (lat == 17.6599 && lng == 75.9064) return 'Bharat Central\nAdministrative Zone';
    if (lat > 28.0) return 'North India Hub\nCapital Region';
    if (lat < 15.0) return 'South India Hub\nCoastal Region';
    if (lng > 85.0) return 'East India Hub\nRiver Valley';
    if (lng < 72.0) return 'West India Hub\nIndustrial Zone';
    
    return 'Bharat Sector\nUrban Grid ${lat.toStringAsFixed(2)}, ${lng.toStringAsFixed(2)}';
  }
}
