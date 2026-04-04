import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegionalAnalyticsScreen extends StatefulWidget {
  const RegionalAnalyticsScreen({super.key});

  @override
  State<RegionalAnalyticsScreen> createState() => _RegionalAnalyticsScreenState();
}

class _RegionalAnalyticsScreenState extends State<RegionalAnalyticsScreen> {
  final List<Map<String, dynamic>> _mockRegionalData = [
    {
      'region': 'Sector 1 (Industrial)',
      'development': 0.92,
      'budget': '4.2M',
      'lastAudit': '2024-03-10',
      'infrastructureHealth': 0.88,
    },
    {
      'region': 'Sector 2 (Residential)',
      'development': 0.76,
      'budget': '1.8M',
      'lastAudit': '2024-03-25',
      'infrastructureHealth': 0.65,
    },
    {
      'region': 'Sector 3 (Central)',
      'development': 0.84,
      'budget': '3.5M',
      'lastAudit': '2024-04-02',
      'infrastructureHealth': 0.94,
    },
    {
      'region': 'Sector 4 (Utilities Hub)',
      'development': 0.60,
      'budget': '8.1M',
      'lastAudit': '2024-04-04',
      'infrastructureHealth': 0.72,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amber = const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Regional Analytics',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalMetricCard(amber, isDark),
            const SizedBox(height: 24),
            Text(
              'SECTOR-WISE PERFORMANCE',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ..._mockRegionalData.map((data) => _buildRegionCard(data, isDark, amber)),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalMetricCard(Color amber, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics_rounded, color: amber, size: 24),
              const SizedBox(width: 12),
              Text('National Infrastructure Score', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('82.4%', style: GoogleFonts.outfit(fontSize: 48, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
              const Spacer(),
              _buildSimpleTrend(true, '4.2', amber),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 0.824,
              backgroundColor: isDark ? Colors.white10 : Colors.black12,
              valueColor: AlwaysStoppedAnimation<Color>(amber),
              minHeight: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleTrend(bool isPositive, String value, Color amber) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: amber.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded, color: amber, size: 18),
          const SizedBox(width: 6),
          Text(isPositive ? '+$value%' : '-$value%', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: amber)),
        ],
      ),
    );
  }

  Widget _buildRegionCard(Map<String, dynamic> data, bool isDark, Color amber) {
    final double development = data['development'] as double;
    final double health = data['infrastructureHealth'] as double;
    final String lastAudit = data['lastAudit'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(data['region'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16)),
              Text('Allocated: ${data['budget']}', style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w800, color: amber)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _metricCol('Development', '${(development * 100).toInt()}%', amber)),
              Expanded(child: _metricCol('Infra Health', '${(health * 100).toInt()}%', Colors.grey)),
              Expanded(child: _metricCol('Last Audit', lastAudit, Colors.grey)),
            ],
          ),
          const SizedBox(height: 20),
          _buildHealthBar(health, amber, isDark),
        ],
      ),
    );
  }

  Widget _metricCol(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildHealthBar(double value, Color amber, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: isDark ? Colors.white10 : Colors.black12,
        valueColor: AlwaysStoppedAnimation<Color>(amber.withValues(alpha: 0.6)),
        minHeight: 6,
      ),
    );
  }
}
