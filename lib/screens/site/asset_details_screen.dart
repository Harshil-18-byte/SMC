import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Asset Details Screen
/// High-fidelity technical oversight for a specific infrastructure asset.
class AssetDetailsScreen extends StatefulWidget {
  final String assetId;
  final String assetName;

  const AssetDetailsScreen({
    super.key,
    required this.assetId,
    required this.assetName,
  });

  @override
  State<AssetDetailsScreen> createState() => _AssetDetailsScreenState();
}

class _AssetDetailsScreenState extends State<AssetDetailsScreen> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _assetData;
  List<Map<String, dynamic>> _components = [];
  List<Map<String, dynamic>> _team = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAssetDetails();
  }

  Future<void> _loadAssetDetails() async {
    try {
      final doc = await _firestoreService.readDocument(collection: 'site_status', docId: widget.assetId);
      final staff = await _firestoreService.queryCollection(collection: 'system_users', field: 'siteId', value: widget.assetId);

      if (mounted) {
        setState(() {
          _assetData = doc;
          _components = [
            {'name': 'Structural Foundation', 'status': 'Stable', 'rating': 0.9},
            {'name': 'Electrical Grid-A', 'status': 'Maintenance Required', 'rating': 0.6},
            {'name': 'Hydraulic Systems', 'status': 'Degraded', 'rating': 0.4},
          ];
          _team = staff;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading asset info: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(backgroundColor: Color(0xFF0F172A), body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: const Color(0xFF1E293B),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.assetName, style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.blue.withValues(alpha: 0.2)),
                    const Center(child: Opacity(opacity: 0.2, child: Icon(Icons.architecture_rounded, color: Colors.blue, size: 80))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.blue,
                tabs: const [
                  Tab(text: "ANALYTICS"),
                  Tab(text: "COMPONENTS"),
                  Tab(text: "FIELD TEAM"),
                ],
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildAnalyticsTab(),
              _buildComponentsTab(),
              _buildTeamTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final health = (_assetData?['healthScore'] as num?)?.toDouble() ?? 100.0;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _statCard('HEALTH SCORE', '${health.toInt()}%', Icons.health_and_safety_rounded, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('STRESS INDEX', 'MODERATE', Icons.compress_rounded, Colors.orange)),
            ],
          ),
          const SizedBox(height: 24),
          Text("STRUCTURAL STABILITY TREND", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 80), FlSpot(1, 85), FlSpot(2, 70), FlSpot(3, 75), FlSpot(4, 90)],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                    belowBarData: BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _infoTile(Icons.pin_drop_rounded, 'COORDINATES', _assetData?['location'] ?? '19.0760° N, 72.8777° E'),
          _infoTile(Icons.update_rounded, 'LAST AUDIT', '48 hours ago'),
        ],
      ),
    );
  }

  Widget _buildComponentsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _components.length,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            CircularProgressIndicator(value: _components[i]['rating'], strokeWidth: 3, color: Colors.blue, backgroundColor: Colors.white10),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_components[i]['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('STATUS: ${_components[i]['status']}', style: TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _team.length,
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Colors.blueGrey, child: Icon(Icons.person_rounded, color: Colors.white)),
          title: Text(_team[i]['fullName'] ?? 'Field Engineer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(_team[i]['role'] ?? 'Inspector', style: const TextStyle(color: Colors.grey, fontSize: 11)),
          trailing: const Icon(Icons.message_rounded, color: Colors.blue, size: 20),
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 8, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}
