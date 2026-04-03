import 'package:flutter/material.dart';
import 'package:smc/core/visuals/magic_widgets.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/visuals/painters.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/widgets/language_selector.dart';
import 'dart:async';
import 'dart:math' as math;

class ImmersiveDashboard extends StatefulWidget {
  const ImmersiveDashboard({super.key});

  @override
  State<ImmersiveDashboard> createState() => _ImmersiveDashboardState();
}

class _ImmersiveDashboardState extends State<ImmersiveDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _parallaxController;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _parallaxController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardBackHandler(
      dashboardName: 'Immersive Dashboard',
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E), // Force dark background
        drawer: const UniversalDrawer(),
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            setState(() {
              _scrollOffset = notification.metrics.pixels;
            });
            return true;
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Parallax Hero Header
              SliverAppBar(
                expandedHeight: 350,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF1A1A2E),
                actions: const [
                  ThemeSwitcher(iconColor: Colors.white),
                  SizedBox(width: 8),
                  LanguageSwitcherButton(
                      showLabel: false, iconColor: Colors.white),
                  SizedBox(width: 16),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [
                    StretchMode.zoomBackground,
                    StretchMode.blurBackground,
                  ],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background layer
                      Transform.translate(
                        offset: Offset(0, _scrollOffset * 0.3),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                            ),
                          ),
                          child: CustomPaint(
                            painter: AnimatedBackgroundPainter(
                              animation: _parallaxController,
                            ),
                          ),
                        ),
                      ),
                      // Floating particles
                      Transform.translate(
                        offset: Offset(0, _scrollOffset * 0.5),
                        child: const ParticleField(color: Colors.white70),
                      ),
                      // Foreground content
                      Transform.translate(
                        offset: Offset(0, _scrollOffset * 0.7),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF1A1A2E).withValues(alpha: 0.8),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildGreetingWithAnimation(),
                              const SizedBox(height: 12),
                              _buildLiveHealthScore(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Content Grid
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Text(
                      AppLocalizations.of(context).magicDeck,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMagicCards(),
                    const SizedBox(height: 48),
                    _buildAIInsights(),
                    const SizedBox(height: 48),
                    _buildInteractiveHeatmap(),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingWithAnimation() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 1),
      curve: Curves.easeOutQuart,
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.white, Colors.white60],
              ).createShader(bounds),
              child: Text(
                _getContextualGreeting(context),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveHealthScore() {
    return StreamBuilder<int>(
      stream: _getCityHealthScoreStream(),
      builder: (context, snapshot) {
        final score = snapshot.data ?? 84;
        return Row(
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: GlowingCirclePainter(
                  progress: score / 100,
                  color: _getScoreColor(score),
                ),
                child: Center(
                  child: Text(
                    '$score',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).cityHealthIndex,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  _getHealthStatusText(context, score),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMagicCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        MagicCard(
          color: const Color(0xFF6366F1),
          padding: const EdgeInsets.all(16),
          child: _buildCardContent(AppLocalizations.of(context).vitality,
              Icons.favorite_rounded, '92%', '+3% spike'),
        ),
        MagicCard(
          color: const Color(0xFFEC4899),
          padding: const EdgeInsets.all(16),
          child: _buildCardContent(AppLocalizations.of(context).alerts,
              Icons.warning_amber_rounded, '04', '2 urgent'),
        ),
        MagicCard(
          color: const Color(0xFF10B981),
          padding: const EdgeInsets.all(16),
          child: _buildCardContent(AppLocalizations.of(context).air,
              Icons.air_rounded, 'AQI 42', 'Good level'),
        ),
        MagicCard(
          color: const Color(0xFFF59E0B),
          padding: const EdgeInsets.all(16),
          child: _buildCardContent(
              AppLocalizations.of(context).visits,
              Icons.location_on_rounded,
              '12',
              AppLocalizations.of(context).translate('today')),
        ),
      ],
    );
  }

  Widget _buildCardContent(
      String title, IconData icon, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const Spacer(),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(sub,
              style: const TextStyle(color: Colors.white38, fontSize: 10)),
        ),
      ],
    );
  }

  Widget _buildAIInsights() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: Colors.purpleAccent, size: 24),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context).aiInsights,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Predicting a 15% increase in respiratory cases due to upcoming seasonal changes. Recommend inventory check for Sector 7.",
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveHeatmap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).cityVitalsHeatmap,
            style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.bold,
                fontSize: 12)),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/immersive-heatmap');
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: 0.3), width: 1),
            ),
            child: Stack(
              children: [
                // Background visual hint
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Opacity(
                      opacity: 0.3,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.blue, Colors.purple],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Overlay content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blueAccent.withValues(alpha: 0.2),
                          border: Border.all(
                              color: Colors.blueAccent.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.view_in_ar_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context).launch3dAnalytics,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppLocalizations.of(context).tapToExplore,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getContextualGreeting(BuildContext context) {
    final hour = DateTime.now().hour;
    final l10n = AppLocalizations.of(context);
    if (hour < 12) return l10n.translate('good_morning');
    if (hour < 17) return l10n.translate('good_afternoon');
    return l10n.translate('good_evening');
  }

  Stream<int> _getCityHealthScoreStream() {
    return Stream.periodic(
        const Duration(seconds: 5), (i) => 80 + math.Random().nextInt(10));
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.greenAccent;
    if (score >= 80) return Colors.blueAccent;
    return Colors.orangeAccent;
  }

  String _getHealthStatusText(BuildContext context, int score) {
    final l10n = AppLocalizations.of(context);
    if (score >= 90) return l10n.exceptional;
    if (score >= 80) return l10n.stableStatus;
    return l10n.monitoring;
  }
}


