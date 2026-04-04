import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/services/admin_analytics_service.dart';
import 'package:smc/data/seeders/comprehensive_data_seeder.dart';
import 'package:smc/data/models/inspection_metric.dart';
import 'package:smc/data/models/critical_alert.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';

import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/compact_widgets.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/data/seeders/csv_data_seeder.dart';
import 'package:smc/widgets/smc_map.dart';
import 'package:smc/widgets/charts/working_line_chart.dart';
import 'package:smc/widgets/predictive_resource_widget.dart';
import 'package:smc/widgets/notification_badge.dart';

/// Admin Command Center Dashboard
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AdminAnalyticsService _analyticsService = AdminAnalyticsService();

  bool _isLoading = true;
  List<InspectionMetric> _metrics = [];
  List<CriticalAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final counts = await _analyticsService.getDashboardCounts();
      _metrics = [
        InspectionMetric(
          label: 'Active Projects',
          value: counts['activeAssets']?.toString() ?? '0',
          change: 0.05,
          icon: Icons.construction_rounded,
          color: Theme.of(context).primaryColor,
        ),
        InspectionMetric(
          label: 'Asset Integrity',
          value: '${counts['assetIntegrity'] ?? 94}%',
          change: -0.02,
          icon: Icons.assessment_rounded,
          color: (counts['assetIntegrity'] ?? 94) < 90 ? Colors.red : Colors.green,
        ),
        InspectionMetric(
          label: 'Field Force',
          value: counts['activeInspectors']?.toString() ?? '0',
          change: 0.0,
          icon: Icons.badge_rounded,
          color: Colors.purple,
        ),
      ];

      final alertsData = await _firestoreService.getCollection(
        collection: 'critical_alerts',
        orderBy: 'timestamp',
        descending: true,
        limit: 10,
      );
      _alerts = alertsData.map((data) => CriticalAlert.fromMap(data, data['id'])).toList();
      setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
    final l10n = AppLocalizations.of(context);

    return DashboardBackHandler(
      dashboardName: 'Admin Dashboard',
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        drawer: const UniversalDrawer(),
        body: InfraGridBackground(
          isDark: isDark,
          child: SafeArea(
            bottom: false,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      _buildAppBar(context, isDark),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadDashboardData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
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
        floatingActionButton: IndustrialActionButton(
          width: 140,
          height: 52,
          color: Theme.of(context).colorScheme.primary,
          onTap: _seedTestData,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dataset_rounded, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(l10n.seedData.toUpperCase(), style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _seedTestData() async {
    try {
      await ComprehensiveDataSeeder().seedAllData();
      await CsvDataSeeder().seedFromCsvs();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).testDataSeededMsg), backgroundColor: Colors.green));
        _loadDashboardData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    }
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Builder(builder: (ctx) => IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () => Scaffold.of(ctx).openDrawer())),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context).overview.toUpperCase(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
          const Spacer(),
          NotificationBadge(onTap: () => Navigator.pushNamed(context, '/notifications')),
        ],
      ),
    );
  }

  Widget _buildMetricsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).translate('key_metrics').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.grey : Colors.black87)),
            Text(AppLocalizations.of(context).updatedJustNow, style: GoogleFonts.outfit(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        AdaptiveGrid(
          childAspectRatio: 1.3,
          children: _metrics.map((m) => _buildMetricCard(m, isDark)).toList(),
        ),
      ],
    );
  }

  Widget _buildMetricCard(InspectionMetric metric, bool isDark) {
    final accentColor = metric.color;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? accentColor.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Expanded(child: Text(metric.label.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: isDark ? Colors.grey[300] : Colors.black87))),
              Icon(metric.isPositive ? Icons.trending_up : Icons.trending_down, color: accentColor, size: 14),
            ],
          ),
          FittedBox(fit: BoxFit.scaleDown, child: Text(metric.value, style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: accentColor))),
          Text('${metric.isPositive ? "+" : ""}${(metric.change * 100).toStringAsFixed(0)}% Weekly', style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildResourceTrackerSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IndustrialActionButton(
        height: 80,
        width: double.infinity,
        color: Theme.of(context).primaryColor,
        onTap: () => Navigator.pushNamed(context, AppRoutes.assetInventory),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("INFRASTRUCTURE ASSET LOGISTICS", style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                  Text("Monitor city assets & project readiness", style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppLocalizations.of(context).translate('live_heatmap').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.grey : Colors.black87)),
            TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.riskHeatmap), child: Text("FULL VIEW", style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12))),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 300,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
          child: ClipRRect(borderRadius: BorderRadius.circular(8), child: const SMCMap(showMarkers: true)),
        ),
      ],
    );
  }

  Widget _buildAlertsSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context).translate('critical_alerts').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.grey : Colors.black87)),
          const SizedBox(height: 12),
          ..._alerts.take(3).map((alert) => _buildAlertCard(alert, isDark)),
        ],
      ),
    );
  }

  Widget _buildAlertCard(CriticalAlert alert, bool isDark) {
    final statusColor = alert.severity == 'danger' ? Colors.red : (alert.severity == 'warning' ? Colors.orange : Theme.of(context).primaryColor);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: isDark ? Colors.white10 : Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(alert.title, style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800))),
              Text(alert.getTimeAgo(), style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          Text(alert.description, style: GoogleFonts.outfit(fontSize: 13, color: isDark ? Colors.grey : Colors.black87)),
          if (alert.severity == 'danger') ...[
            const SizedBox(height: 12),
              IndustrialActionButton(
                height: 40, width: double.infinity, color: Colors.red,
                onTap: () {
                  HapticFeedback.vibrate();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("FIELD RESPONSE TEAM DISPATCHED"), backgroundColor: Colors.red));
                },
                child: Text(AppLocalizations.of(context).dispatchResponse.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrendsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context).translate('weekly_trends').toUpperCase(), style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: isDark ? Colors.grey : Colors.black87)),
        const SizedBox(height: 12),
        Container(
          height: 250, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(12)),
          child: WorkingLineChart(
            title: "Infrastructure Utilization Trends",
            dataFuture: Future.value([
              ChartDataPoint(label: 'Mon', value: 42),
              ChartDataPoint(label: 'Tue', value: 55),
              ChartDataPoint(label: 'Wed', value: 38),
              ChartDataPoint(label: 'Thu', value: 72),
              ChartDataPoint(label: 'Fri', value: 64),
              ChartDataPoint(label: 'Sat', value: 89),
              ChartDataPoint(label: 'Sun', value: 77),
            ]),
          ),
        ),
      ],
    );
  }
}
