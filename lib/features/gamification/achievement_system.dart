import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:smc/core/visuals/gamification_painters.dart';

// Achievement Model Definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int target;
  final String realImpact;
  final int? progress;
  final bool isUnlocked;
  final bool isNew;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.target,
    required this.realImpact,
    this.progress,
    this.isUnlocked = false,
    this.isNew = false,
  });
}

class AchievementSystem extends StatefulWidget {
  const AchievementSystem({super.key});

  @override
  State<AchievementSystem> createState() => _AchievementSystemState();
}

class _AchievementSystemState extends State<AchievementSystem> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Achievement>>(
      stream: _getAchievementsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievements = snapshot.data!;
        final unlockedCount = achievements.where((a) => a.isUnlocked).length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress overview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Impact',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Impact stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildImpactStat(
                        icon: Icons.people,
                        value: '${_getTotalFamiliesHelped()}',
                        label: 'Families Helped',
                      ),
                      _buildImpactStat(
                        icon: Icons.favorite,
                        value: '${_getEarlyDetections()}',
                        label: 'Lives Protected',
                      ),
                      _buildImpactStat(
                        icon: Icons.emoji_events,
                        value: '$unlockedCount/${achievements.length}',
                        label: 'Achievements',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Achievement grid
            const Text(
              'Achievements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 600 ? 4 : 3;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75, // Lower ratio = more vertical space
                  ),
                  itemCount: achievements.length,
                  itemBuilder: (context, index) {
                    return _buildAchievementCard(achievements[index]);
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImpactStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return GestureDetector(
      onTap: () => _showAchievementDetails(achievement),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: achievement.isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    achievement.color,
                    achievement.color.withValues(alpha: 0.7),
                  ],
                )
              : LinearGradient(
                  colors: [Colors.grey[300]!, Colors.grey[400]!],
                ),
          boxShadow: achievement.isUnlocked
              ? [
                  BoxShadow(
                    color: achievement.color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Background pattern
            if (achievement.isUnlocked)
              Positioned.fill(
                child: CustomPaint(
                  painter: PatternPainter(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with glow effect
                  Flexible(
                    child: Container(
                      constraints: const BoxConstraints(
                        maxWidth: 60,
                        maxHeight: 60,
                        minWidth: 40,
                        minHeight: 40,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                        boxShadow: achievement.isUnlocked
                            ? [
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                )
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Icon(
                          achievement.icon,
                          size: 28,
                          color: achievement.isUnlocked
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    achievement.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: achievement.isUnlocked
                          ? Colors.white
                          : Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Progress
                  if (!achievement.isUnlocked && achievement.progress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: LinearProgressIndicator(
                              value: achievement.progress! / achievement.target,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                              valueColor:
                                  const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            child: Text(
                              '${achievement.progress}/${achievement.target}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // "New" badge
            if (achievement.isUnlocked && achievement.isNew)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement) {
    if (achievement.isUnlocked) {
      showDialog(
        context: context,
        builder: (context) => AchievementUnlockAnimation(
          achievement: achievement,
          onComplete: () => Navigator.pop(context),
        ),
      );
    }
  }

  // Mock Data Generators
  int _getTotalFamiliesHelped() => 42;
  int _getEarlyDetections() => 3;

  Stream<List<Achievement>> _getAchievementsStream() async* {
    yield _defineAchievements();
  }

  List<Achievement> _defineAchievements() {
    return [
      Achievement(
        id: 'first_visit',
        title: 'First Steps',
        description: 'Complete your first household visit',
        icon: Icons.home,
        color: Colors.green,
        target: 1,
        realImpact: 'You helped 1 family stay inspectiony',
        isUnlocked: true,
        progress: 1,
      ),
      Achievement(
        id: 'century_visits',
        title: 'Century Club',
        description: 'Complete 100 household visits',
        icon: Icons.emoji_events,
        color: Colors.amber,
        target: 100,
        realImpact: 'You monitored inspection of 100 families',
        progress: 42,
      ),
      Achievement(
        id: 'early_detection',
        title: 'Life Saver',
        description: 'Detect a high-risk case early',
        icon: Icons.favorite,
        color: Colors.red,
        target: 1,
        realImpact: 'Your quick action may have saved a life',
        isUnlocked: true,
        isNew: true,
        progress: 1,
      ),
      Achievement(
        id: 'streak_7',
        title: 'Dedicated',
        description: 'Work 7 days in a row',
        icon: Icons.local_fire_department,
        color: Colors.orange,
        target: 7,
        realImpact: 'Your dedication keeps the city safe',
        progress: 5,
      ),
      Achievement(
        id: 'outbreak_prevention',
        title: 'Outbreak Preventer',
        description: 'Help identify and contain a defect cluster',
        icon: Icons.shield,
        color: Colors.blue,
        target: 1,
        realImpact: 'Prevented potential outbreak affecting hundreds',
        progress: 0,
      ),
    ];
  }
}

// Achievement unlock animation
class AchievementUnlockAnimation extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onComplete;

  const AchievementUnlockAnimation({
    super.key,
    required this.achievement,
    required this.onComplete,
  });

  @override
  State<AchievementUnlockAnimation> createState() =>
      _AchievementUnlockAnimationState();
}

class _AchievementUnlockAnimationState extends State<AchievementUnlockAnimation>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _playAnimation();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _playAnimation() async {
    // Haptic feedback
    HapticFeedback.heavyImpact();

    // Play sound (Commented out until dependency is added)
    // AudioPlayer().play(AssetSource('sounds/achievement_unlock.mp3'));

    // Animations
    await _scaleController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(seconds: 3));

    // widget.onComplete(); // Don't auto complete to let user admire
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Particle explosion
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticleExplosionPainter(
                  animation: _particleController,
                  color: widget.achievement.color,
                ),
              );
            },
          ),

          // Scale Transition container
          Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _scaleController,
                curve: Curves.elasticOut,
              ),
              child: GestureDetector(
                onTap: widget.onComplete,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.achievement.color,
                        widget.achievement.color.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: widget.achievement.color.withValues(alpha: 0.5),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Achievement Unlocked!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Icon with glow
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.achievement.icon,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        widget.achievement.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      Text(
                        widget.achievement.description,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      // Real impact
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.eco,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                widget.achievement.realImpact,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: widget.onComplete,
                        child: const Text('Close',
                            style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


