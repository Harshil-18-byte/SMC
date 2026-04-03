import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get total counts for dashboard cards
  Future<Map<String, int>> getDashboardCounts() async {
    // In a real app, you might use distributed counters or a scheduled function
    // For this demo, we'll just count documents in key collections
    try {
      final hospitalData =
          await _firestore.collection('hospital_intake_status').get();

      int totalPatients = 0;
      int availableBeds = 0;

      for (var doc in hospitalData.docs) {
        final data = doc.data();
        totalPatients += (data['bedTotal'] as int? ?? 0) -
            (data['bedAvailable'] as int? ?? 0);
        availableBeds += (data['bedAvailable'] as int? ?? 0);
      }

      final doctors = await _firestore
          .collection('system_users')
          .where('role', isEqualTo: 'doctor')
          .count()
          .get();

      final criticalAlertsSnapshot = await _firestore
          .collection('critical_alerts')
          .where('isRead', isEqualTo: false)
          .where('severity', isEqualTo: 'danger')
          .count()
          .get();

      return {
        'activePatients': totalPatients,
        'availableBeds': availableBeds,
        'activeDoctors': doctors.count ?? 0,
        'criticalAlerts': criticalAlertsSnapshot.count ?? 0,
      };
    } catch (e) {
      return {
        'activePatients': 0,
        'availableBeds': 0,
        'activeDoctors': 0,
        'criticalAlerts': 0,
      };
    }
  }

  /// Get weekly trends for chart
  /// [type] can be 'cases' or 'recovered'
  Future<List<Map<String, dynamic>>> getWeeklyTrends(String type) async {
    try {
      final snapshot = await _firestore
          .collection('weekly_trends')
          .orderBy('date', descending: false)
          .limit(7)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'day': data['day'] ?? '',
          'count': type == 'cases'
              ? (data['cases'] as num?)?.toInt() ?? 0
              : (data['recovered'] as num?)?.toInt() ?? 0,
        };
      }).toList();
    } catch (e) {
      // Fallback or empty list on error
      return [];
    }
  }

  /// Get disease spread data for heatmap (Mocked for now)
  Future<List<Map<String, dynamic>>> getDiseaseHeatmapData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Bharat locations
    return [
      {
        'lat': 17.6765,
        'lng': 75.9115,
        'intensity': 0.8
      }, // Hutatma Chowk (High risk)
      {'lat': 17.6588, 'lng': 75.9145, 'intensity': 0.5}, // Ashok Chowk
      {'lat': 17.6234, 'lng': 75.8972, 'intensity': 0.3}, // Kegaon
    ];
  }

  /// Get daily admission trends
  Stream<List<Map<String, dynamic>>> getAdmissionTrends() {
    // This would typically aggregate data.
    // For Real-time, we can stream recent admissions
    return _firestore
        .collection('hospital_admissions')
        .orderBy('admissionTime', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}


