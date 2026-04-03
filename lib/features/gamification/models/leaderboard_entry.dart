class LeaderboardEntry {
  final String userId;
  final String userName;
  final String avatarUrl; // URL or asset path
  final String zoneId; // To filter by zone
  final int score;
  final int rank;
  final int previousRank; // To show movement (up/down)
  final double accuracy; // For quality-based tie-breaking/display
  final int impact; // Secondary metric (e.g., lives impacted)
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.avatarUrl,
    required this.zoneId,
    required this.score,
    required this.rank,
    this.previousRank = 0,
    this.accuracy = 0.0,
    this.impact = 0,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromMap(
      Map<String, dynamic> map, String currentUserId) {
    return LeaderboardEntry(
      userId: map['user_id'] ?? '',
      userName: map['user_name'] ?? 'Unknown',
      avatarUrl: map['avatar_url'] ?? 'assets/avatars/default.png',
      zoneId: map['zone_id'] ?? 'general',
      score: map['score'] ?? 0,
      rank: map['rank'] ?? 0,
      previousRank: map['previous_rank'] ?? 0,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      impact: map['impact'] ?? 0,
      isCurrentUser: (map['user_id'] ?? '') == currentUserId,
    );
  }
}

enum LeaderboardType {
  global,
  zone,
  team,
}

enum LeaderboardPeriod {
  weekly,
  monthly,
  allTime,
}

enum LeaderboardMetric {
  xp, // General progression
  visits, // Quantity
  accuracy, // Quality
  highRiskFound, // Impact
}


