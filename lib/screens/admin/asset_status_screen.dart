import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/data/services/firestore_service.dart';

class SiteResourceTrackerScreen extends StatefulWidget {
  const SiteResourceTrackerScreen({super.key});

  @override
  State<SiteResourceTrackerScreen> createState() =>
      _SiteResourceTrackerScreenState();
}

class _SiteResourceTrackerScreenState
    extends State<SiteResourceTrackerScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _sites = [];
  int _totalBeds = 0;
  int _availableBeds = 0;
  double _avgOxygen = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _firestoreService.getCollection(
          collection: 'site_intake_status');

      int total = 0;
      int available = 0;
      double oxygenSum = 0;
      int oxyCount = 0;

      for (var h in data) {
        total += (h['bedTotal'] as num?)?.toInt() ?? 0;
        available += (h['bedAvailable'] as num?)?.toInt() ?? 0;

        // Mocking oxygen if not present, but using it if it exists
        final oxy = (h['oxygenLevel'] as num?)?.toDouble() ?? 85.0;
        oxygenSum += oxy;
        oxyCount++;
      }

      if (mounted) {
        setState(() {
          _sites = data;
          _totalBeds = total;
          _availableBeds = available;
          _avgOxygen = oxyCount > 0 ? oxygenSum / oxyCount : 0.0;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading resources: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(l10n.translate('resource_tracker')),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    FadeInDown(child: _buildResourceOverview(l10n, isDark)),
                    const SizedBox(height: 24),
                    FadeInUp(child: _buildDemandTrend(l10n, isDark)),
                    const SizedBox(height: 24),
                    _buildSiteList(l10n, isDark),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildResourceOverview(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildResourceCard(
            l10n.translate('beds'),
            "$_availableBeds/$_totalBeds",
            Icons.bed_rounded,
            Colors.blue,
            isDark,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildResourceCard(
            l10n.translate('oxygen_status'),
            "${_avgOxygen.toInt()}%",
            Icons.gas_meter_rounded,
            Colors.teal,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildResourceCard(
      String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C242D) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF111418),
            ),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDemandTrend(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C242D) : Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Weekly Bed Demand",
            style:
                GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 4),
                      const FlSpot(2, 3.5),
                      const FlSpot(3, 5),
                      const FlSpot(4, 4.5),
                      const FlSpot(5, 6),
                      const FlSpot(6, 5.5),
                    ],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteList(AppLocalizations l10n, bool isDark) {
    if (_sites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text("No site data found",
              style: TextStyle(color: Colors.grey[500])),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Site-wise Assets",
              style:
                  GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Icon(Icons.filter_list_rounded, color: Colors.grey),
          ],
        ),
        const SizedBox(height: 16),
        ..._sites.map((h) {
          final available = (h['bedAvailable'] as num?)?.toInt() ?? 0;
          final total = (h['bedTotal'] as num?)?.toInt() ?? 10;
          final oxy = (h['oxygenLevel'] as num?)?.toInt() ?? 85;
          final occupancy = total > 0 ? (total - available) / total : 0.0;

          String status = 'Stable';
          Color statusCol = Colors.blue;
          if (occupancy > 0.9) {
            status = 'Critical';
            statusCol = Colors.red;
          } else if (occupancy < 0.3) {
            status = 'Exellent';
            statusCol = Colors.green;
          }

          return FadeInLeft(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C242D) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h['name'] ?? 'Unknown Site',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildMiniStatus(Icons.bed_rounded,
                                "$available Beds", Colors.blue),
                            const SizedBox(width: 16),
                            _buildMiniStatus(Icons.gas_meter_rounded,
                                "$oxy% Oxygen", Colors.teal),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusCol.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusCol,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMiniStatus(IconData icon, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}


