enum ChallengeType {
  visit, // "Complete 5 visits"
  accuracy, // "Maintain 100% accuracy"
  streak, // "Work 3 days in a row"
  impact, // "Identify 1 high-risk case"
  social, // "Help a colleague"
}

enum ChallengeDifficulty {
  easy,
  medium,
  hard,
  epic,
}

enum ChallengeStatus {
  active,
  completed,
  claimed,
  expired,
}

class Challenge {
  final String id;
  final String title;
  final String description;
  final String icon;
  final ChallengeType type;
  final ChallengeDifficulty difficulty;
  final int xpReward;
  final int coinsReward;

  // Progress
  final int targetValue;
  final int currentValue;
  final double progressPercent; // 0.0 to 1.0
  final DateTime expiresAt;
  final ChallengeStatus status;

  // Metadata
  final String? badgeId; // If completing unlocks a challenge-specific badge

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.difficulty,
    required this.xpReward,
    required this.coinsReward,
    required this.targetValue,
    required this.currentValue,
    required this.progressPercent,
    required this.expiresAt,
    required this.status,
    this.badgeId,
  });

  factory Challenge.fromMap(Map<String, dynamic> map, String id) {
    int current = map['current_value'] ?? 0;
    int target = map['target_value'] ?? 1;
    double percent = (current / target).clamp(0.0, 1.0);

    return Challenge(
      id: id,
      title: map['title'] ?? 'Challenge',
      description: map['description'] ?? '',
      icon: map['icon'] ?? 'assets/icons/default_challenge.svg',
      type: ChallengeType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => ChallengeType.visit,
      ),
      difficulty: ChallengeDifficulty.values.firstWhere(
        (e) => e.toString().split('.').last == map['difficulty'],
        orElse: () => ChallengeDifficulty.medium,
      ),
      xpReward: map['xp_reward'] ?? 0,
      coinsReward: map['coins_reward'] ?? 0,
      targetValue: target,
      currentValue: current,
      progressPercent: percent,
      expiresAt: (map['expires_at'] as dynamic)?.toDate() ??
          DateTime.now().add(const Duration(days: 1)),
      status: ChallengeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ChallengeStatus.active,
      ),
      badgeId: map['badge_id'],
    );
  }
}


