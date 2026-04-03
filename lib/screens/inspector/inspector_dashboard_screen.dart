import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/visuals/infra_visuals.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/compact_widgets.dart';
import 'package:smc/config/routes.dart';
import 'package:flutter/services.dart';

class InspectorDashboardScreen extends StatefulWidget {
  const InspectorDashboardScreen({super.key});

  @override
  State<InspectorDashboardScreen> createState() => _InspectorDashboardScreenState();
}

class _InspectorDashboardScreenState extends State<InspectorDashboardScreen> {
  bool _isOffline = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AdaptiveLayout(
      compactBody: _buildDashboardBody(context, isDark),
      mediumBody: _buildDashboardBody(context, isDark),
      expandedBody: _buildDashboardBody(context, isDark),
      largeBody: _buildDashboardBody(context, isDark),
    );
  }

  Widget _buildDashboardBody(BuildContext context, bool isDark) {
    return Scaffold(
      drawer: const UniversalDrawer(),
      appBar: AppBar(
        title: Text(
          "FIELD INSPECTOR TERMINAL",
          style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        actions: [
          _buildOfflineToggle(),
        ],
      ),
      body: InfraGridBackground(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInspectorStats(isDark),
              const SizedBox(height: 24),
              _buildSiteSafetyBanner(isDark),
              const SizedBox(height: 24),
              _buildActiveInspections(isDark),
              const SizedBox(height: 24),
              _buildOperationalFeatures(isDark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: IndustrialActionButton(
        width: 180,
        height: 56,
        color: Theme.of(context).colorScheme.primary,
        onTap: () {
          HapticFeedback.heavyImpact();
          Navigator.pushNamed(
            context,
            AppRoutes.newInspection,
            arguments: {'fieldWorkerId': 'INS_PRO_001'},
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_enhance_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              "START INSPECTION",
              style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfflineToggle() {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Text(
            _isOffline ? "OFFLINE" : "LIVE",
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _isOffline ? Colors.orange : Colors.green,
            ),
          ),
          Switch(
            value: !_isOffline,
            onChanged: (val) => setState(() => _isOffline = !val),
            activeThumbColor: Colors.green,
            activeTrackColor: Colors.green.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }

  Widget _buildInspectorStats(bool isDark) {
    return AdaptiveGrid(
      childAspectRatio: 1.5,
      children: [
        _buildMetricTile("Tasks Today", "5/8", Icons.assignment_turned_in_rounded, Colors.blue),
        _buildMetricTile("Efficiency", "92%", Icons.speed_rounded, Colors.teal),
        _buildMetricTile("Defects Found", "14", Icons.bug_report_rounded, Colors.orange),
        _buildMetricTile("Sync Status", "Synced", Icons.cloud_done_rounded, Colors.green),
      ],
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 20, color: color),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSiteSafetyBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SITE SAFETY PROTOCOL ACTIVE",
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 12, color: Colors.orange[800]),
                ),
                Text(
                  "Ensure hard hat and high-vis vest are worn before starting data capture.",
                  style: GoogleFonts.outfit(fontSize: 11, color: Colors.orange[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveInspections(bool isDark) {
    final inspections = [
      {'asset': 'Railway Bridge #42', 'location': 'North Sector', 'status': 'Pending'},
      {'asset': 'Major Road Pave G', 'location': 'City Center', 'status': 'In Progress'},
      {'asset': 'Utility Tunnel B', 'location': 'West Industrial', 'status': 'Queued'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("MY INSPECTION QUEUE", Icons.list_alt_rounded),
        const SizedBox(height: 12),
        ...inspections.map((insp) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 20, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(insp['asset']!, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(insp['location']!, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(insp['status']!.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildOperationalFeatures(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("INSPECTION UTILITIES", Icons.construction_rounded),
        const SizedBox(height: 16),
        AdaptiveGrid(
          childAspectRatio: 1.2,
          children: [
            _buildFeatureStub("Geo-Evidence", "Forced GPS + Timestamp capture.", Icons.camera_alt_rounded),
            _buildFeatureStub("AI Defect ID", "Visual crack/spall scanning.", Icons.biotech_rounded),
            _buildFeatureStub("AR Measure", "Estimate defect size via camera.", Icons.view_in_ar_rounded),
            _buildFeatureStub("Offline Vault", "Captured data remains safe locally.", Icons.storage_rounded),
            _buildFeatureStub("Hazards Map", "Real-time dangerous site alerts.", Icons.warning_rounded),
            _buildFeatureStub("Site Requests", "Order urgent site materials.", Icons.shopping_basket_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureStub(String title, String desc, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        if (title == "Geo-Evidence") _showGeoEvidenceVault(isDark);
        if (title == "Hazards Map") _showHazardsAlerts(isDark);
        if (title == "Site Requests") _showSiteRequests(isDark);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Colors.blue),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Text(desc, style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  void _showGeoEvidenceVault(bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.3), width: 2),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("GEO-EVIDENCE VAULT", style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 2)),
                    Text("Site Captures", style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildEvidenceItem("CRACK_SURVEY_001.JPG", "Sector 4 Bridge", "Synced", isDark),
                  _buildEvidenceItem("PAVEMENT_ANOMALY_04.PNG", "South Highway", "Pending Sync", isDark),
                  _buildEvidenceItem("UTILITY_EXPOSURE_B.JPG", "City Center", "Synced", isDark),
                  _buildEvidenceItem("DRAINAGE_BLOCK_12.JPG", "Industrial Rd", "Synced", isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHazardsAlerts(bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Hazard Layer Injected into Tactical Map Overlay."), backgroundColor: Colors.orange),
    );
  }

  void _showSiteRequests(bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Site Resource Request Form Initialized."), backgroundColor: Colors.blue),
    );
  }

  Widget _buildEvidenceItem(String fileName, String loc, String status, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.image_rounded, color: Colors.blue, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(loc, style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: status == "Synced" ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(status.toUpperCase(), style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.bold, color: status == "Synced" ? Colors.green : Colors.orange)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            letterSpacing: 1.2,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }
}
