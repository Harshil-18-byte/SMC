import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AssetInventoryScreen extends StatefulWidget {
  const AssetInventoryScreen({super.key});

  @override
  State<AssetInventoryScreen> createState() => _AssetInventoryScreenState();
}

class _AssetInventoryScreenState extends State<AssetInventoryScreen> {
  final List<Map<String, dynamic>> _mockAssets = [
    {
      'id': 'INF-001',
      'name': 'Route 7 Sewer Line',
      'category': 'Utilities',
      'status': 'Operational',
      'health': 0.85,
      'lastInspection': '2024-03-15',
    },
    {
      'id': 'INF-002',
      'name': 'East Bridge Support',
      'category': 'Bridges',
      'status': 'Under Maintenance',
      'health': 0.42,
      'lastInspection': '2024-04-01',
    },
    {
      'id': 'INF-003',
      'name': 'Central Power Grid X1',
      'category': 'Electrical',
      'status': 'Operational',
      'health': 0.98,
      'lastInspection': '2024-03-28',
    },
    {
      'id': 'INF-004',
      'name': 'North Water Main',
      'category': 'Water',
      'status': 'Critical Alert',
      'health': 0.12,
      'lastInspection': '2024-04-03',
    },
    {
      'id': 'INF-005',
      'name': 'Main St Pavement',
      'category': 'Roads',
      'status': 'Operational',
      'health': 0.76,
      'lastInspection': '2024-02-20',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amber = const Color(0xFFF59E0B);
    final slate = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Asset Inventory',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search_rounded)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list_rounded)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCards(amber, isDark),
            const SizedBox(height: 24),
            Text(
              'OPERATIONAL ASSET LIST',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            _buildAssetTable(isDark, amber, slate),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCards(Color amber, bool isDark) {
    return Row(
      children: [
        _statCard('Total Assets', '1,248', Icons.inventory_2_rounded, amber, isDark),
        const SizedBox(width: 12),
        _statCard('Critical Items', '14', Icons.warning_amber_rounded, const Color(0xFFEF4444), isDark),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)),
            Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTable(bool isDark, Color amber, Color slate) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        children: _mockAssets.map((asset) => _buildAssetRow(asset, isDark, amber)).toList(),
      ),
    );
  }

  Widget _buildAssetRow(Map<String, dynamic> asset, bool isDark, Color amber) {
    final statusColor = _getStatusColor(asset['status'] as String);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(_getCategoryIcon(asset['category'] as String), color: statusColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset['name'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(asset['id'] as String, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(asset['status'] as String, style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: statusColor)),
              ),
              const SizedBox(height: 4),
              Text('Inspected: ${asset['lastInspection']}', style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Operational': return const Color(0xFF10B981);
      case 'Under Maintenance': return const Color(0xFFF59E0B);
      case 'Critical Alert': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Utilities': return Icons.settings_input_component_rounded;
      case 'Bridges': return Icons.architecture_rounded;
      case 'Electrical': return Icons.electric_bolt_rounded;
      case 'Water': return Icons.water_drop_rounded;
      case 'Roads': return Icons.add_road_rounded;
      default: return Icons.category_rounded;
    }
  }
}
