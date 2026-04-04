import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/surveillance_models.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/widgets/smc_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/widgets/charts/working_line_chart.dart';

/// Professional Infrastructure Risk & Compliance Analysis Screen
/// High-fidelity Charts, maps, and raw defect logs for strategic verification.
class DefectSurveillanceScreen extends StatefulWidget {
  const DefectSurveillanceScreen({super.key});

  @override
  State<DefectSurveillanceScreen> createState() => _DefectSurveillanceScreenState();
}

class _DefectSurveillanceScreenState extends State<DefectSurveillanceScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  bool _isLoading = true;
  List<DefectCaseData> _caseData = [];
  List<ZoneHeatmapData> _heatmapData = [];
  List<RawCaseEntry> _rawLogs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSurveillanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSurveillanceData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final caseDataList = await _firestoreService.getCollection(collection: 'defect_case_data', orderBy: 'date', descending: false, limit: 30);
      _caseData = caseDataList.map((data) => DefectCaseData.fromMap(data, data['id'])).toList();

      final heatmapDataList = await _firestoreService.getCollection(collection: 'zone_heatmap_data');
      _heatmapData = heatmapDataList.map((data) => ZoneHeatmapData.fromMap(data, data['id'] ?? '')).toList();

      final rawLogsList = await _firestoreService.getCollection(collection: 'raw_case_entries', orderBy: 'reportedDate', descending: true, limit: 50);
      _rawLogs = rawLogsList.map((data) => RawCaseEntry.fromMap(data, data['id'] ?? '')).toList();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading surveillance: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushReplacementNamed(context, AppRoutes.nationalDashboard);
      },
      child: Scaffold(
        drawer: const UniversalDrawer(),
        appBar: AppBar(
          title: Text("INFRA RISK ANALYSIS", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          actions: [
            const ThemeSwitcher(),
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadSurveillanceData),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorWeight: 3,
            tabs: const [Tab(text: 'TRENDS'), Tab(text: 'HEATMAP'), Tab(text: 'AUDIT LOGS')],
          ),
        ),
        body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildTrendsTab(), _buildHeatmapTab(), _buildLogsTab()],
            ),
      ),
    );
  }

  Widget _buildTrendsTab() {
    return RefreshIndicator(
      onRefresh: _loadSurveillanceData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader('DEFECT INGRESS TRENDS'),
            const SizedBox(height: 20),
            _buildChartPlaceholder(),
            const SizedBox(height: 32),
            _buildSummaryStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: WorkingLineChart(
        title: "30-Day Defect Telemetry",
        dataFuture: Future.value(_caseData.map((d) => ChartDataPoint(
          label: "${d.date.day}/${d.date.month}",
          value: d.newDefects.toDouble(),
        )).toList()),
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalNew = _caseData.fold<int>(0, (sum, d) => sum + d.newDefects);
    final totalResolved = _caseData.fold<int>(0, (sum, d) => sum + d.resolvedDefects);
    final critical = _caseData.isNotEmpty ? _caseData.last.criticalFailures : 0;

    return Row(
      children: [
        _statCard('NEW ISSUES', totalNew.toString(), Colors.red),
        const SizedBox(width: 12),
        _statCard('RESOLVED', totalResolved.toString(), Colors.green),
        const SizedBox(width: 12),
        _statCard('CRITICAL', critical.toString(), Colors.orange),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(child: Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold))),
            Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapTab() {
    return Column(
      children: [
        Expanded(
          child: SMCMap(
            showHeatmap: true,
            heatPoints: _heatmapData.map((e) => LatLng(e.latitude, e.longitude)).toList(),
          ),
        ),
        Container(
          height: 180,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _heatmapData.length,
            itemBuilder: (context, index) => _zoneRiskCard(_heatmapData[index]),
          ),
        ),
      ],
    );
  }

  Widget _zoneRiskCard(ZoneHeatmapData zone) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: zone.riskColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(zone.zoneName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: zone.riskColor),
              const SizedBox(width: 4),
              Text('${zone.defectCount} DEFECTS', style: TextStyle(color: zone.riskColor, fontWeight: FontWeight.bold, fontSize: 10)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: zone.riskColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(zone.riskLevel.toUpperCase(), style: TextStyle(color: zone.riskColor, fontSize: 8, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLogsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rawLogs.length,
      itemBuilder: (context, index) {
        final log = _rawLogs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text(log.assetId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: log.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                  child: Text(log.status.toUpperCase(), style: TextStyle(color: log.statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(log.defectType, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 4),
                Text('Location: ${log.zone} | Severity: ${log.severity}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, letterSpacing: 1.5));
  }
}
