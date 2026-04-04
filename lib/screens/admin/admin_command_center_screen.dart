import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/command_center_models.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Admin Command Center
/// Real-time infrastructure monitoring, defect alerts, and asset health scoring.
class AdminCommandCenterScreen extends StatefulWidget {
  const AdminCommandCenterScreen({super.key});

  @override
  State<AdminCommandCenterScreen> createState() => _AdminCommandCenterScreenState();
}

class _AdminCommandCenterScreenState extends State<AdminCommandCenterScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  InfraKPI? _kpi;
  List<SystemAlert> _alerts = [];
  List<AssetStatus> _assets = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final kpiData = await _firestoreService.readDocument(collection: 'command_center_kpi', docId: 'current');
      if (kpiData != null) _kpi = InfraKPI.fromMap(kpiData);

      final alertsData = await _firestoreService.getCollection(collection: 'system_alerts', orderBy: 'timestamp', descending: true, limit: 10);
      _alerts = alertsData.map((data) => SystemAlert.fromMap(data, data['id'])).toList();

      final assetsData = await _firestoreService.getCollection(collection: 'asset_intake_status', orderBy: 'name');
      _assets = assetsData.map((data) => AssetStatus.fromMap(data, data['id'])).toList();

      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading command center: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _showExitConfirmation(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        drawer: const UniversalDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu_open_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('INFRA COMMAND CENTER', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
              Text('GLOBAL STRATEGIC TERMINAL', style: GoogleFonts.outfit(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          actions: [
            IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadDashboardData),
            const SizedBox(width: 12),
          ],
        ),
        body: IndustrialVisuals.blueprintBackground(
          isDark: true,
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildKPIGrid(),
                      const SizedBox(height: 32),
                      _buildAlertsFeed(),
                      const SizedBox(height: 32),
                      _buildAssetStatusSection(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Terminate Command Session?", style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          TextButton(onPressed: () => Navigator.pushReplacementNamed(context, '/auth/login'), child: const Text("TERMINATE", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildKPIGrid() {
    if (_kpi == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('STRATEGIC METRICS'),
        const SizedBox(height: 16),
        Row(
          children: [
            _kpiCard('Critical Defects', _kpi!.criticalDefects.toString(), Icons.warning_amber_rounded, Colors.red),
            const SizedBox(width: 12),
            _kpiCard('Infra Uptime', '${_kpi!.infrastructureUptime.toInt()}%', Icons.timer_rounded, Colors.green),
            const SizedBox(width: 12),
            _kpiCard('Risk Index', _kpi!.structuralRiskIndex.toInt().toString(), Icons.security_rounded, _kpi!.riskColor),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 12),
            FittedBox(child: Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white))),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('REAL-TIME SYSTEM ALERTS'),
        const SizedBox(height: 16),
        Container(
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: _alerts.isEmpty 
            ? const Center(child: Text('All systems nominal.', style: TextStyle(color: Colors.grey)))
            : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _alerts.length,
                separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.05)),
                itemBuilder: (context, index) {
                  final alert = _alerts[index];
                  return ListTile(
                    dense: true,
                    leading: Icon(Icons.circle, size: 8, color: alert.severityColor),
                    title: Text(alert.message, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(alert.getTimeAgo(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    trailing: const Icon(Icons.chevron_right, size: 14, color: Colors.grey),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildAssetStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('CRITICAL ASSET INTEGRITY'),
        const SizedBox(height: 16),
        if (_assets.isEmpty) 
          const Center(child: Text('Scanning assets...', style: TextStyle(color: Colors.grey)))
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, 
              crossAxisSpacing: 12, 
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemCount: _assets.length,
            itemBuilder: (context, index) => _assetCard(_assets[index]),
          ),
      ],
    );
  }

  Widget _assetCard(AssetStatus asset) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(asset.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${asset.integrityPercentage.toInt()}%', style: TextStyle(color: asset.statusColor, fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('INTEGRITY', style: TextStyle(color: Colors.grey, fontSize: 8)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: asset.integrityPercentage / 100,
                backgroundColor: Colors.black26,
                color: asset.statusColor,
                minHeight: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1.5));
  }
}
