import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/surveillance_models.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/widgets/smc_map.dart';
import 'package:latlong2/latlong.dart';

/// Disease Surveillance Analysis Screen
/// Charts, maps, and raw case data for verification
class DiseaseSurveillanceScreen extends StatefulWidget {
  const DiseaseSurveillanceScreen({super.key});

  @override
  State<DiseaseSurveillanceScreen> createState() =>
      _DiseaseSurveillanceScreenState();
}

class _DiseaseSurveillanceScreenState extends State<DiseaseSurveillanceScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;

  bool _isLoading = true;
  List<DiseaseCaseData> _caseData = [];
  List<ZoneHeatmapData> _heatmapData = [];
  List<RawCaseEntry> _rawCases = [];
  String _selectedDisease = 'All';
  final List<String> _diseases = [
    'All',
    'Dengue',
    'Malaria',
    'Covid-19',
    'Typhoid'
  ];

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
    setState(() => _isLoading = true);

    try {
      // Load time-series case data
      final caseDataList = await _firestoreService.getCollection(
        collection: 'disease_case_data',
        orderBy: 'date',
        descending: false,
        limit: 30,
      );
      _caseData = caseDataList
          .map((data) => DiseaseCaseData.fromMap(data, data['id']))
          .toList();

      // Load heatmap data
      final heatmapDataList = await _firestoreService.getCollection(
        collection: 'zone_heatmap_data',
      );
      _heatmapData = heatmapDataList
          .map((data) => ZoneHeatmapData.fromMap(data, data['id'] ?? ''))
          .toList();

      // Load raw case entries
      final rawCasesList = await _firestoreService.getCollection(
        collection: 'raw_case_entries',
        orderBy: 'reportedDate',
        descending: true,
        limit: 50,
      );
      _rawCases = rawCasesList
          .map((data) => RawCaseEntry.fromMap(data, data['id'] ?? ''))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).surveillance,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSurveillanceData,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (val) {
              setState(() => _selectedDisease = val);
            },
            itemBuilder: (context) => _diseases
                .map((d) => PopupMenuItem<String>(
                      value: d,
                      child: Text(d),
                    ))
                .toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          labelColor: Theme.of(context).colorScheme.secondary,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          tabs: [
            Tab(text: AppLocalizations.of(context).translate('charts')),
            Tab(text: AppLocalizations.of(context).translate('map')),
            Tab(text: AppLocalizations.of(context).translate('raw_data')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildChartsTab(), _buildMapTab(), _buildRawDataTab()],
            ),
    );
  }

  /// Charts Tab - Time-series visualization
  Widget _buildChartsTab() {
    return RefreshIndicator(
      onRefresh: _loadSurveillanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)
                  .translate('weekly_trends')
                  .toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeSeriesChart(),
            const SizedBox(height: 24),
            _buildSummaryCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSeriesChart() {
    if (_caseData.isEmpty) {
      return Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    // Simple line chart visualization
    final maxValue = _caseData
        .map(
          (d) => d.newCases > d.recoveredCases ? d.newCases : d.recoveredCases,
        )
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                  AppLocalizations.of(context).translate('active_patients'),
                  const Color(0xFFFF4D4D)),
              const SizedBox(width: 24),
              _buildLegendItem(
                  AppLocalizations.of(context).translate('recovered'),
                  const Color(0xFF10B981)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _caseData.take(14).map((data) {
                return _buildChartBar(
                  data.newCases.toDouble(),
                  data.recoveredCases.toDouble(),
                  maxValue,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(double newCases, double recovered, double maxValue) {
    return SizedBox(
      width: 16,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (newCases > 0)
            Container(
              width: 16,
              height: (newCases / (maxValue == 0 ? 1 : maxValue)) * 200,
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D4D),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const SizedBox(height: 2),
          if (recovered > 0)
            Container(
              width: 16,
              height: (recovered / (maxValue == 0 ? 1 : maxValue)) * 200,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
      ],
    );
  }

  Widget _buildSummaryCards() {
    final totalNew = _caseData.fold<int>(0, (sum, data) => sum + data.newCases);
    final totalRecovered = _caseData.fold<int>(
      0,
      (sum, data) => sum + data.recoveredCases,
    );
    final totalActive = _caseData.isNotEmpty ? _caseData.last.activeCases : 0;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Total New',
            totalNew.toString(),
            Icons.trending_up,
            const Color(0xFFFF4D4D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Recovered',
            totalRecovered.toString(),
            Icons.check_circle,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Active',
            totalActive.toString(),
            Icons.coronavirus,
            const Color(0xFFFFAB00),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }

  /// Map Tab - Geospatial heatmap
  Widget _buildMapTab() {
    return RefreshIndicator(
      onRefresh: _loadSurveillanceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'DISEASE SPREAD BY ZONE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                    letterSpacing: 1.2,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.adminHeatmap),
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('Advanced Analysis'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeatmapContainer(),
            const SizedBox(height: 24),
            Text(
              'ZONE BREAKDOWN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            ..._heatmapData.map((zone) => _buildZoneCard(zone)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapContainer() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SMCMap(
          showHeatmap: true,
          showMarkers: false,
          heatPoints:
              _heatmapData.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        ),
      ),
    );
  }

  Widget _buildZoneCard(ZoneHeatmapData zone) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: zone.severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on, color: zone.severityColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.zoneName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${zone.caseCount} active cases',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: zone.severityColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              zone.severity.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: zone.severityColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Raw Data Tab - Read-only case entries
  Widget _buildRawDataTab() {
    return RefreshIndicator(
      onRefresh: _loadSurveillanceData,
      child: _rawCases.isEmpty
          ? Center(
              child: Text(
                'No case data available',
                style: TextStyle(color: Colors.grey[500]),
              ),
            )
          : _buildCaseTable(),
    );
  }

  Widget _buildCaseTable() {
    final filteredCases = _selectedDisease == 'All'
        ? _rawCases
        : _rawCases
            .where((c) =>
                c.disease.toLowerCase() == _selectedDisease.toLowerCase())
            .toList();

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredCases.length,
            itemBuilder: (context, index) =>
                _buildCaseItem(filteredCases[index]),
          );
  }

  Widget _buildCaseItem(RawCaseEntry caseEntry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient ID: ${caseEntry.patientId}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      caseEntry.disease,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: caseEntry.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  caseEntry.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: caseEntry.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDataField('Zone', caseEntry.zone),
              const SizedBox(width: 24),
              _buildDataField('Age', '${caseEntry.age}'),
              const SizedBox(width: 24),
              _buildDataField('Gender', caseEntry.gender),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reported: ${_formatDate(caseEntry.reportedDate)}',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildDataField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}


