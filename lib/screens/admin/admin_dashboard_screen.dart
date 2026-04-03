import 'package:flutter/material.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/services/admin_analytics_service.dart';
import 'package:smc/data/seeders/comprehensive_data_seeder.dart';
import 'package:smc/data/models/health_metric.dart';
import 'package:smc/data/models/critical_alert.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';

import 'package:smc/core/localization/app_localizations.dart';

import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/theme/universal_theme.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/compact_widgets.dart';
import 'package:smc/core/visuals/medical_textures.dart';
import 'package:smc/core/visuals/medical_buttons.dart';
import 'package:smc/core/visuals/medical_loaders.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/data/seeders/csv_data_seeder.dart';
import 'package:smc/widgets/smc_map.dart';
import 'package:smc/widgets/charts/working_line_chart.dart';
import 'package:smc/widgets/predictive_resource_widget.dart';

import 'package:smc/widgets/notification_badge.dart';

/// Admin Command Center Dashboard
/// Real-time healthcare monitoring dashboard with Firebase backend
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AdminAnalyticsService _analyticsService =
      AdminAnalyticsService(); // Add Analytics Service

  // State variables
  bool _isLoading = true;
  List<HealthMetric> _metrics = [];
  List<CriticalAlert> _alerts = [];
  String _selectedTrendType = 'cases'; // 'cases' or 'recovered'

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// Load all dashboard data from Firestore
  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load Analytics Counts
      final counts = await _analyticsService.getDashboardCounts();

      // Mock Metrics based on live counts
      _metrics = [
        HealthMetric(
          id: '1',
          title: 'Active Patients',
          value: counts['activePatients']!,
          iconName: 'personal_injury',
          percentage: 0,
          changePercentage: 5,
          isIncreasing: true,
          trend: 'up',
          severity: 'normal',
          lastUpdated: DateTime.now(),
        ),
        HealthMetric(
          id: '2',
          title: 'Available Beds',
          value: counts['availableBeds']!,
          iconName: 'bed',
          percentage: 0,
          changePercentage: 2,
          isIncreasing: false,
          trend: 'down',
          severity: counts['availableBeds']! < 10 ? 'danger' : 'normal',
          lastUpdated: DateTime.now(),
        ),
        HealthMetric(
          id: '3',
          title: 'Active Doctors',
          value: counts['activeDoctors']!,
          iconName: 'medical_services',
          percentage: 0,
          changePercentage: 0,
          isIncreasing: true,
          trend: 'stable',
          severity: 'normal',
          lastUpdated: DateTime.now(),
        ),
      ];

      // Load alerts (unread first)
      final alertsData = await _firestoreService.getCollection(
        collection: 'critical_alerts',
        orderBy: 'timestamp',
        descending: true,
        limit: 10,
      );
      _alerts = alertsData
          .map((data) => CriticalAlert.fromMap(data, data['id']))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(
            content: Text(
                '${AppLocalizations.of(context).translate('error_loading_data')}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveLayout(
      compactBody: _buildDashboardBody(context),
      mediumBody: _buildDashboardBody(context),
      expandedBody: _buildDashboardBody(context),
      largeBody: _buildDashboardBody(context),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DashboardBackHandler(
      dashboardName: 'Admin Dashboard',
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: const UniversalDrawer(),
        body: PaperTextureBackground(
          isDark: isDark,
          child: SafeArea(
            bottom: false,
            child: _isLoading
                ? Center(
                    child: ECGLoader(
                      message: AppLocalizations.of(context).connectingMsg,
                    ),
                  )
                : Column(
                    children: [
                      _buildAppBar(context, isDark),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadDashboardData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.only(
                              bottom: 80,
                              left: UniversalTheme.getSpacing(
                                  context, SpacingSize.md),
                              right: UniversalTheme.getSpacing(
                                  context, SpacingSize.md),
                            ),
                            child: Column(
                              children: [
                                _buildMetricsSection(isDark),
                                const PredictiveResourceWidget(),
                                _buildResourceTrackerSection(isDark),
                                _buildHeatmapSection(isDark),
                                _buildAlertsSection(isDark),
                                _buildTrendsSection(isDark),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        floatingActionButton: RubberStampButton(
          width: 140,
          height: 52,
          color: Theme.of(context).colorScheme.primary,
          onTap: _seedTestData,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dataset_rounded, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).seedData.toUpperCase(),
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.0,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  /// Seed test data into Firestore
  Future<void> _seedTestData() async {
    final seeder = ComprehensiveDataSeeder();
    final csvSeeder = CsvDataSeeder();

    try {
      await seeder.seedAllData();
      await csvSeeder.seedFromCsvs();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).testDataSeededMsg),
            backgroundColor: const Color(0xFF0bda5b),
          ),
        );

        // Reload data
        await _loadDashboardData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${AppLocalizations.of(context).errorSeedingMsg}: $e'),
            backgroundColor: const Color(0xFFff4d4d),
          ),
        );
      }
    }
  }

  /// App Bar
  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.98),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              color: isDark ? Colors.white : const Color(0xFF111418),
              tooltip: 'Menu',
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context).overview.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: isDark ? Colors.white : const Color(0xFF2C2825),
            ),
          ),
          const Spacer(),
          NotificationBadge(
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                color: isDark ? Colors.white : const Color(0xFF111418)),
            onSelected: (value) async {
              if (value == 'seed_csv') {
                try {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context).seedingCsvMsg)),
                  );
                  await CsvDataSeeder().seedFromCsvs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text(AppLocalizations.of(context).csvSeededMsg)),
                  );
                  setState(() => _isLoading = true);
                  await _loadDashboardData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Error: $e')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'seed_csv',
                child: Row(
                  children: [
                    Icon(Icons.upload_file, size: 20, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Seed CSV Data'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: UniversalTheme.getSpacing(context, SpacingSize.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('key_metrics')
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey[400] : const Color(0xFF2C2825),
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).updatedJustNow,
                style: GoogleFonts.caveat(
                  fontSize: 16,
                  color: const Color(0xFF137fec),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.md)),
          AdaptiveGrid(
            childAspectRatio: 1.25, // Increased height
            children: _metrics.map((m) => _buildMetricCard(m, isDark)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(HealthMetric metric, bool isDark) {
    Color accentColor;
    if (metric.severity == 'danger') {
      accentColor = Theme.of(context).colorScheme.error;
    } else if (metric.severity == 'warning') {
      accentColor = const Color(0xFFF59E0B);
    } else {
      accentColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? accentColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  metric.title.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey[300] : const Color(0xFF2C2825),
                    letterSpacing: 1.0,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                  metric.isIncreasing ? Icons.trending_up : Icons.trending_down,
                  color: accentColor,
                  size: 16),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value.toString(),
              style: GoogleFonts.caveat(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '${metric.changePercentage.toStringAsFixed(0)}%',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF2C2825),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).translate('vs_last_week'),
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResourceTrackerSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: RubberStampButton(
        height: 80,
        color: const Color(0xFF137fec),
        onTap: () => Navigator.pushNamed(context, AppRoutes.resourceTracker),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.analytics_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "LIVE RESOURCE LOGISTICS",
                    style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        fontSize: 14),
                  ),
                  Text(
                    "Monitor hospital assets & oxygen levels",
                    style: GoogleFonts.caveat(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  /// Heatmap Section
  Widget _buildHeatmapSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)
                      .translate('live_heatmap')
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: isDark ? Colors.grey[400] : const Color(0xFF2C2825),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.adminHeatmap),
                  icon: const Icon(Icons.map_rounded, size: 14),
                  label: Text("FULL VIEW",
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            AppLocalizations.of(context).filterOptionsSoon)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(AppLocalizations.of(context).filter.toUpperCase(),
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F22) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color:
                    isDark ? const Color(0xFF2D3135) : const Color(0xFFD6CFC7),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                height: 300,
                child: SMCMap(showMarkers: true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Critical Alerts Section
  Widget _buildAlertsSection(bool isDark) {
    final unreadCount = _alerts.where((a) => !a.isRead).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('critical_alerts')
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey[400] : const Color(0xFF2C2825),
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unreadCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFff4d4d),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '$unreadCount NEW',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ..._alerts.take(3).map((alert) => _buildAlertCard(alert, isDark)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(CriticalAlert alert, bool isDark) {
    Color statusColor;

    if (alert.severity == 'danger') {
      statusColor = Theme.of(context).colorScheme.error;
    } else if (alert.severity == 'warning') {
      statusColor = const Color(0xFFF59E0B);
    } else {
      statusColor = Theme.of(context).colorScheme.secondary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3135) : const Color(0xFFD6CFC7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.title,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF2C2825),
                  ),
                ),
              ),
              Text(
                alert.getTimeAgo(),
                style: GoogleFonts.caveat(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            alert.description,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[700],
              height: 1.5,
            ),
          ),
          if (alert.severity == 'danger') ...[
            const SizedBox(height: 16),
            RubberStampButton(
              height: 40,
              width: double.infinity,
              color: Theme.of(context).colorScheme.error,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '${AppLocalizations.of(context).dispatchAlertMsg}: ${alert.title}'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              },
              child: Text(
                AppLocalizations.of(context).dispatchResponse.toUpperCase(),
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Weekly Trends Section
  Widget _buildTrendsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)
                      .translate('weekly_trends')
                      .toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.grey[400] : const Color(0xFF2C2825),
                    letterSpacing: 1.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C1F22) : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2D3135)
                        : const Color(0xFFD6CFC7),
                  ),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _buildTrendToggle(
                        AppLocalizations.of(context).cases, 'cases', isDark),
                    _buildTrendToggle(AppLocalizations.of(context).recovered,
                        'recovered', isDark),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          WorkingLineChart(
            title: _selectedTrendType == 'cases'
                ? AppLocalizations.of(context).cases
                : AppLocalizations.of(context).recovered,
            dataFuture: _analyticsService
                .getWeeklyTrends(_selectedTrendType)
                .then((list) => list
                    .map((item) => ChartDataPoint(
                        label: item['day'] as String,
                        value: (item['count'] as num).toDouble()))
                    .toList()),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendToggle(String label, String value, bool isDark) {
    final isSelected = _selectedTrendType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTrendType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF2D3135) : const Color(0xFFE5E7EB))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: isSelected
                ? (isDark ? Colors.white : const Color(0xFF2C2825))
                : (isDark ? Colors.grey[600] : Colors.grey[500]),
          ),
        ),
      ),
    );
  }
}
