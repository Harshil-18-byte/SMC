import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/data/models/inspection_record.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:smc/core/widgets/universal_drawer.dart';

class InspectorDashboardScreen extends StatefulWidget {
  const InspectorDashboardScreen({super.key});

  @override
  State<InspectorDashboardScreen> createState() => _InspectorDashboardScreenState();
}

class _InspectorDashboardScreenState extends State<InspectorDashboardScreen> {
  final FirestoreService _firestore = FirestoreService();
  bool _isLoading = true;
  List<InspectionRecord> _recentInspections = [];

  @override
  void initState() {
    super.initState();
    _loadInspections();
  }

  Future<void> _loadInspections() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await _firestore.getCollection(
        collection: 'inspections',
        orderBy: 'inspectionDate',
        descending: true,
        limit: 10,
      );
      if (mounted) {
        setState(() {
          _recentInspections = data.map((m) => InspectionRecord.fromMap(m, m['id'])).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error loading inspections: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // PopScope prevents accidental app exit on back button from the root dashboard
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
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: Text('FIELD INSPECTOR HUB', 
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 18, color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync, color: Colors.white), 
              onPressed: _loadInspections,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: IndustrialVisuals.blueprintBackground(
          isDark: true,
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: IndustrialVisuals.primaryTech))
            : RefreshIndicator(
                onRefresh: _loadInspections,
                color: IndustrialVisuals.primaryTech,
                child: CustomScrollView(
                  slivers: [
                    _buildHeader(),
                    _buildStatsGrid(),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                        child: Text('RECENT FIELD RECONNAISSANCE', 
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.grey, fontSize: 12, letterSpacing: 1.2)),
                      ),
                    ),
                    _buildInspectionList(),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: IndustrialVisuals.primaryTech,
          onPressed: () async {
            final result = await Navigator.pushNamed(context, '/inspector/new-inspection', arguments: {'inspectorId': 'INS-402'});
            if (result == true) {
              _loadInspections();
            }
          },
          icon: const Icon(Icons.add_task_rounded, color: Colors.white),
          label: Text('START INSPECTION', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white)),
        ),
      ),
    );
  }

  void _showExitConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Exit Session?", style: TextStyle(color: Colors.white)),
        content: const Text("Are you sure you want to exit the Field Inspector Hub?", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CONTINUE")),
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/auth/login', (route) => false), 
            child: const Text("EXIT", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome, Inspector.', 
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Status: ACTIVE DUTY | Sector: 07-B', 
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use Flexible/Expanded with a fallback to scrollable if extremely narrow
            return Row(
              children: [
                _statCard('PENDING', '04', IndustrialVisuals.cautionYellow),
                const SizedBox(width: 12),
                _statCard('COMPLETED', '28', IndustrialVisuals.successGreen),
                const SizedBox(width: 12),
                _statCard('CRITICAL', '02', IndustrialVisuals.dangerRed),
              ],
            );
          }
        ),
      ),
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInspectionList() {
    if (_recentInspections.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text('No reconnaissance data found.', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final insp = _recentInspections[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(insp.assetName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(insp.address, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IndustrialVisuals.statusBadge(insp.status.name),
                      const Spacer(),
                      Text('${insp.inspectionDate.day}/${insp.inspectionDate.month} ${insp.inspectionDate.hour}:${insp.inspectionDate.minute}', 
                        style: const TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              onTap: () => Navigator.pushNamed(context, '/common/visit-summary', arguments: insp),
            ),
          );
        },
        childCount: _recentInspections.length,
      ),
    );
  }
}
