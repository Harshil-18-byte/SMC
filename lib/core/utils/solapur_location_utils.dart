import 'dart:math';

/// Utility to find nearby Solapur landmarks
class SolapurLocationUtils {
  static final Map<String, Map<String, double>> solapurLandmarks = {
    'Hutatma Chowk': {'lat': 17.6765, 'lng': 75.9115},
    'Solapur Railway Station': {'lat': 17.6714, 'lng': 75.9103},
    'Siddheshwar Temple': {'lat': 17.6743, 'lng': 75.9182},
    'Kegaon Bus Stand': {'lat': 17.6234, 'lng': 75.8972},
    'Civil Hospital': {'lat': 17.6698, 'lng': 75.9034},
    'Saat Rasta Chowk': {'lat': 17.6622, 'lng': 75.9068},
    'Market Yard': {'lat': 17.6812, 'lng': 75.9224},
    'Ashok Chowk': {'lat': 17.6588, 'lng': 75.9145},
    'Rupa Bhavani Temple': {'lat': 17.6856, 'lng': 75.9301},
    'Bhuikot Fort': {'lat': 17.6750, 'lng': 75.9090},
    'Smriti Udyan': {'lat': 17.6730, 'lng': 75.9160},
    'Navi Peth': {'lat': 17.6780, 'lng': 75.9120},
    'WIT College': {'lat': 17.6600, 'lng': 75.9100},
  };

  /// Returns a human-readable location string (e.g. "Near Siddheshwar Temple")
  static String getHumanReadableLocation(double lat, double lng) {
    if (lat == 0 || lng == 0) return "Location pending...";

    String? nearestLandmark;
    double minDistance = double.infinity;

    solapurLandmarks.forEach((name, coords) {
      final dist = _calculateDistance(lat, lng, coords['lat']!, coords['lng']!);
      if (dist < minDistance) {
        minDistance = dist;
        nearestLandmark = name;
      }
    });

    if (nearestLandmark != null && minDistance < 1.0) {
      // Within 1 km
      return "📍 Near $nearestLandmark\n(Vijapur Ward)";
    }

    return "📍 ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
  }

  /// Harversine formula to calculate distance in KM
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}


