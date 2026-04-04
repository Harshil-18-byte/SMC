import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/command_center_models.dart';
import 'package:google_fonts/google_fonts.dart';

/// Site Status & Operational Capacity Screen
/// Detailed monitoring of city assets, structural stability, and maintenance locks.
class SiteStatusScreen extends StatefulWidget {
  const SiteStatusScreen({super.key});

  @override
  State<SiteStatusScreen> createState() => _SiteStatusScreenState();
}

class _SiteStatusScreenState extends State<SiteStatusScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<AssetStatus> _sites = [];

  @override
  void initState() {
    super.initState();
    _loadSites();
  }

  Future<void> _loadSites() async {
    setState(() => _isLoading = true);
    try {
      final sitesData = await _firestoreService.getCollection(
        collection: 'site_status', // Updated collection name
        orderBy: 'name',
      );
      _sites = sitesData.map((data) => AssetStatus.fromMap(data, data['id'])).toList();
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading sites: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showLockMaintenanceDialog(AssetStatus site) {
    showDialog(
      context: context,
      builder: (context) => MaintenanceLockDialog(
        site: site,
        onConfirm: (reason, note) => _lockMaintenance(site, reason, note),
      ),
    );
  }

  Future<void> _lockMaintenance(AssetStatus site, String reason, String note) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'site_status',
        docId: site.id,
        data: {'maintenanceLocked': true, 'lockReason': '$reason: $note'},
      );
      await _loadSites();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Maintenance lock initiated')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _unlockMaintenance(AssetStatus site) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'site_status',
        docId: site.id,
        data: {'maintenanceLocked': false, 'lockReason': null},
      );
      await _loadSites();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: Text('SITE OPERATIONAL STATUS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [const ThemeSwitcher(), IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _loadSites)],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _sites.length,
              itemBuilder: (context, index) => _buildSiteCard(_sites[index]),
            ),
    );
  }

  Widget _buildSiteCard(AssetStatus site) {
    final bool coreRisk = site.integrityPercentage < 60 || site.stabilityLevel < 40;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: site.maintenanceLocked ? Colors.red : Colors.white10, width: site.maintenanceLocked ? 2 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(site.name.toUpperCase(), style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
              _statusBadge(site),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _metricTile('INTEGRITY', '${site.integrityPercentage.toInt()}%', Icons.account_tree_rounded, site.statusColor)),
              const SizedBox(width: 12),
              Expanded(child: _metricTile('STABILITY', '${site.stabilityLevel}%', Icons.speed_rounded, site.stabilityLevel < 50 ? Colors.orange : Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          _metricTile('REPAIR BACKLOG', '${site.repairBacklogDays} DAYS', Icons.history_rounded, site.repairBacklogDays > 10 ? Colors.orange : Colors.blue),
          
          if (site.maintenanceLocked) ...[
            const SizedBox(height: 16),
            _lockAlert(site),
          ],

          const SizedBox(height: 24),
          _actionButtons(site, coreRisk),
        ],
      ),
    );
  }

  Widget _statusBadge(AssetStatus site) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: site.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
      child: Text(site.maintenanceLocked ? 'LOCKED' : 'NOMINAL', style: TextStyle(color: site.statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
    );
  }

  Widget _metricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
          Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _lockAlert(AssetStatus site) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red)),
      child: Row(
        children: [
          const Icon(Icons.lock_clock_rounded, color: Colors.red, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Text(site.lockReason ?? 'MAINTENANCE IN PROGRESS', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _actionButtons(AssetStatus site, bool coreRisk) {
    return Row(
      children: [
        if (!site.maintenanceLocked && coreRisk)
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showLockMaintenanceDialog(site),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('LOCK FOR REPAIR'),
            ),
          ),
        if (site.maintenanceLocked)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _unlockMaintenance(site),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green)),
              child: const Text('RELEASE LOCK'),
            ),
          ),
      ],
    );
  }
}

class MaintenanceLockDialog extends StatefulWidget {
  final AssetStatus site;
  final Function(String reason, String note) onConfirm;

  const MaintenanceLockDialog({super.key, required this.site, required this.onConfirm});

  @override
  State<MaintenanceLockDialog> createState() => _MaintenanceLockDialogState();
}

class _MaintenanceLockDialogState extends State<MaintenanceLockDialog> {
  String _reason = 'Structural Defect';
  final _note = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      title: Text('MAINTENANCE LOCKDOWN', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w900)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _reason,
            items: ['Structural Defect', 'Sensor Failure', 'Power Grid Issue', 'Urgent Overhaul']
                .map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(color: Colors.white)))).toList(),
            onChanged: (v) => setState(() => _reason = v!),
            dropdownColor: const Color(0xFF1E293B),
          ),
          const SizedBox(height: 16),
          TextField(controller: _note, decoration: const InputDecoration(labelText: 'Engineer Notes'), style: const TextStyle(color: Colors.white)),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL')),
        ElevatedButton(onPressed: () { widget.onConfirm(_reason, _note.text); Navigator.pop(context); }, child: const Text('INITIATE LOCK')),
      ],
    );
  }
}
