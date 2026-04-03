/// Weekly Trend Model
/// Represents daily case data for trend charts
class WeeklyTrend {
  final String id;
  final String day; // 'M', 'T', 'W', 'T', 'F', 'S', 'S'
  final int cases;
  final int recovered;
  final DateTime date;

  WeeklyTrend({
    required this.id,
    required this.day,
    required this.cases,
    required this.recovered,
    required this.date,
  });

  // Create from Firestore document
  factory WeeklyTrend.fromMap(Map<String, dynamic> map, String id) {
    return WeeklyTrend(
      id: id,
      day: map['day'] ?? '',
      cases: map['cases'] ?? 0,
      recovered: map['recovered'] ?? 0,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'cases': cases,
      'recovered': recovered,
      'date': date.toIso8601String(),
    };
  }

  // Calculate percentage for chart height (0.0 to 1.0)
  double getPercentage(int maxValue) {
    if (maxValue == 0) return 0.0;
    return cases / maxValue;
  }
}


