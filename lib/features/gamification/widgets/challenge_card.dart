import 'package:flutter/material.dart';
import 'package:smc/features/gamification/models/challenge.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback? onClaim;

  const ChallengeCard({
    super.key,
    required this.challenge,
    this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = challenge.status == ChallengeStatus.completed;
    final isClaimed = challenge.status == ChallengeStatus.claimed;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted && !isClaimed
              ? Colors.amber.withValues(alpha: 0.5)
              : Colors.white10,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Difficulty Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getDifficultyColor(challenge.difficulty)
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForType(challenge.type),
              color: _getDifficultyColor(challenge.difficulty),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  challenge.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),

                // Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: challenge.progressPercent,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getDifficultyColor(challenge.difficulty),
                              _getDifficultyColor(challenge.difficulty)
                                  .withValues(alpha: 0.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: _getDifficultyColor(challenge.difficulty)
                                  .withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${challenge.currentValue} / ${challenge.targetValue}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '+${challenge.xpReward} XP',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Action Button
          if (isCompleted && !isClaimed)
            ElevatedButton(
              onPressed: onClaim,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('CLAIM',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            )
          else if (isClaimed)
            const Icon(Icons.check_circle, color: Colors.green, size: 28)
          else
            Text(
              '${(challenge.progressPercent * 100).toInt()}%',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(ChallengeDifficulty difficulty) {
    switch (difficulty) {
      case ChallengeDifficulty.easy:
        return Colors.greenAccent;
      case ChallengeDifficulty.medium:
        return Colors.blueAccent;
      case ChallengeDifficulty.hard:
        return Colors.orangeAccent;
      case ChallengeDifficulty.epic:
        return Colors.purpleAccent;
    }
  }

  IconData _getIconForType(ChallengeType type) {
    switch (type) {
      case ChallengeType.visit:
        return Icons.home_outlined;
      case ChallengeType.accuracy:
        return Icons.verified_user_outlined;
      case ChallengeType.streak:
        return Icons.local_fire_department_outlined;
      case ChallengeType.impact:
        return Icons.favorite_border;
      case ChallengeType.social:
        return Icons.people_outline;
    }
  }
}


