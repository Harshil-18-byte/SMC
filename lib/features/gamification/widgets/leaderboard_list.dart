import 'package:flutter/material.dart';
import 'package:smc/features/gamification/models/leaderboard_entry.dart';

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardList({
    super.key,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return _buildLeaderboardTile(entry, index);
      },
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry, int index) {
    bool isTopThree = index < 3;
    Color rankColor = _getRankColor(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? Colors.indigo.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: entry.isCurrentUser
            ? Border.all(color: Colors.indigo.withValues(alpha: 0.5))
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 30,
            child: isTopThree
                ? Icon(Icons.emoji_events, color: rankColor, size: 20)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: 8),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white10,
            child: Text(
              entry.userName[0],
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),

          // Name and Zone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.userName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: entry.isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                Text(
                  entry.zoneId,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Score and Rank Movement
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.score} XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              _buildRankChange(entry),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankChange(LeaderboardEntry entry) {
    if (entry.previousRank == 0 || entry.previousRank == entry.rank) {
      return const SizedBox.shrink();
    }

    bool improved = entry.rank < entry.previousRank;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          improved ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: improved ? Colors.greenAccent : Colors.redAccent,
          size: 16,
        ),
        Text(
          '${(entry.previousRank - entry.rank).abs()}',
          style: TextStyle(
            color: improved ? Colors.greenAccent : Colors.redAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Gold
      case 1:
        return const Color(0xFFC0C0C0); // Silver
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white54;
    }
  }
}


