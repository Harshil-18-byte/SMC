/// Inspection Metric Model
/// Represents KPI data for the command center dashboard
class InspectionMetric {
  final String id;
  final String title;
  final String iconName;
  final int value;
  final String unit;
  final double percentage;
  final double changePercentage;
  final bool isIncreasing;
  final String trend; // 'up', 'down', 'stable'
  final String severity; // 'danger', 'warning', 'normal'
  final DateTime lastUpdated;

  InspectionMetric({
    required this.id,
    required this.title,
    required this.iconName,
    required this.value,
    this.unit = '',
    required this.percentage,
    required this.changePercentage,
    required this.isIncreasing,
    required this.trend,
    this.severity = 'normal',
    required this.lastUpdated,
  });

  // Create from Firestore document
  factory InspectionMetric.fromMap(Map<String, dynamic> map, String id) {
    return InspectionMetric(
      id: id,
      title: map['title'] ?? '',
      iconName: map['iconName'] ?? 'medical_services',
      value: map['value'] ?? 0,
      unit: map['unit'] ?? '',
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      changePercentage: (map['changePercentage'] ?? 0.0).toDouble(),
      isIncreasing: map['isIncreasing'] ?? false,
      trend: map['trend'] ?? 'stable',
      severity: map['severity'] ?? 'normal',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.parse(map['lastUpdated'])
          : DateTime.now(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'iconName': iconName,
      'value': value,
      'unit': unit,
      'percentage': percentage,
      'changePercentage': changePercentage,
      'isIncreasing': isIncreasing,
      'trend': trend,
      'severity': severity,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}


