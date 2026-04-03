import 'package:flutter/material.dart';
import 'package:smc/features/gamification/models/challenge.dart';
import 'package:smc/features/gamification/models/leaderboard_entry.dart';
import 'package:smc/features/gamification/widgets/challenge_card.dart';
import 'package:smc/features/gamification/widgets/leaderboard_list.dart';
import 'package:smc/features/gamification/widgets/impact_summary_widget.dart';
import 'package:smc/features/gamification/achievement_system.dart'; // Reuse the badge grid if possible or refactor

class GamificationHub extends StatefulWidget {
  const GamificationHub({super.key});

  @override
  State<GamificationHub> createState() => _GamificationHubState();
}

class _GamificationHubState extends State<GamificationHub>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: primary,
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: isDark
                ? Colors.white.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.45),
            labelPadding: const EdgeInsets.symmetric(vertical: 8),
            labelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'CHALLENGES'),
              Tab(text: 'RANKINGS'),
              Tab(text: 'BADGES'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildChallengesTab(),
              _buildRankingsTab(),
              _buildBadgesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Mock challenges
    final challenges = [
      Challenge(
        id: '1',
        title: 'Early Bird',
        description: 'Complete 3 visits before 10 AM',
        icon: '',
        type: ChallengeType.visit,
        difficulty: ChallengeDifficulty.easy,
        xpReward: 100,
        coinsReward: 10,
        targetValue: 3,
        currentValue: 1,
        progressPercent: 0.33,
        expiresAt: DateTime.now().add(const Duration(hours: 4)),
        status: ChallengeStatus.active,
      ),
      Challenge(
        id: '2',
        title: 'Precision Streak',
        description: '10 visits with 100% accuracy',
        icon: '',
        type: ChallengeType.accuracy,
        difficulty: ChallengeDifficulty.hard,
        xpReward: 500,
        coinsReward: 50,
        targetValue: 10,
        currentValue: 10,
        progressPercent: 1.0,
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        status: ChallengeStatus.completed,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const ImpactSummaryWidget(
          livesSaved: 12,
          outbreaksPrevented: 2,
          qualityScore: 98,
          familiesHelped: 450,
        ),
        const SizedBox(height: 24),
        Text(
          'ACTIVE CHALLENGES',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ...challenges.map((c) => ChallengeCard(challenge: c)),
      ],
    );
  }

  Widget _buildRankingsTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Mock entries
    final entries = [
      LeaderboardEntry(
        userId: '1',
        userName: 'Ramesh Kumar',
        avatarUrl: '',
        zoneId: 'Bharat North',
        score: 12450,
        rank: 1,
        previousRank: 2,
        impact: 50,
      ),
      LeaderboardEntry(
        userId: '2',
        userName: 'Priya Sharma',
        avatarUrl: '',
        zoneId: 'Bharat West',
        score: 11200,
        rank: 2,
        previousRank: 1,
        impact: 45,
      ),
      LeaderboardEntry(
        userId: '3',
        userName: 'Amit Patel',
        avatarUrl: '',
        zoneId: 'Bharat East',
        score: 9800,
        rank: 3,
        previousRank: 3,
        impact: 40,
      ),
      LeaderboardEntry(
        userId: 'current',
        userName: 'You (Ashok)',
        avatarUrl: '',
        zoneId: 'Bharat South',
        score: 8500,
        rank: 12,
        previousRank: 15,
        impact: 32,
        isCurrentUser: true,
      ),
    ];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Global Rank',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '#12',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Icon(Icons.arrow_drop_up,
                      color: Colors.greenAccent, size: 32),
                  const Text(
                    '+3 spots',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Bharat LEADERBOARD',
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        LeaderboardList(entries: entries),
      ],
    );
  }

  Widget _buildBadgesTab() {
    // Current AchievementSystem does most of this, but it uses its own model.
    // We'll refactor it later or bridge it.
    // For now, let's just use the AchievementSystem widget.
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: AchievementSystem(),
    );
  }
}
