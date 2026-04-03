class UserData {
  final String id;
  final String name;
  final int daysWorked;
  final int currentStreak;
  final int totalDaysWorked;
  final int totalVisits;
  final int maxVisitsInDay;
  final int highRiskDetections;
  final double averageAccuracy;
  final int clusterDetections;
  final int teamAssists;
  final int menteesTrained;

  UserData({
    required this.id,
    required this.name,
    this.daysWorked = 0,
    this.currentStreak = 0,
    this.totalDaysWorked = 0,
    this.totalVisits = 0,
    this.maxVisitsInDay = 0,
    this.highRiskDetections = 0,
    this.averageAccuracy = 0.0,
    this.clusterDetections = 0,
    this.teamAssists = 0,
    this.menteesTrained = 0,
  });

  factory UserData.fromMap(Map<String, dynamic> map, String id) {
    return UserData(
      id: id,
      name: map['name'] ?? 'Unknown User',
      daysWorked: map['days_worked'] ?? 0,
      currentStreak: map['current_streak'] ?? 0,
      totalDaysWorked: map['total_days_worked'] ?? 0,
      totalVisits: map['total_visits'] ?? 0,
      maxVisitsInDay: map['max_visits_in_day'] ?? 0,
      highRiskDetections: map['high_risk_detections'] ?? 0,
      averageAccuracy: (map['average_accuracy'] ?? 0.0).toDouble(),
      clusterDetections: map['cluster_detections'] ?? 0,
      teamAssists: map['team_assists'] ?? 0,
      menteesTrained: map['mentees_trained'] ?? 0,
    );
  }
}


