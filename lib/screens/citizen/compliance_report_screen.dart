import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/data/models/inspection_record.dart';
import 'package:smc/data/services/pdf_report_service.dart';

class ComplianceReportScreen extends StatefulWidget {
  const ComplianceReportScreen({super.key});

  @override
  State<ComplianceReportScreen> createState() => _ComplianceReportScreenState();
}

class _ComplianceReportScreenState extends State<ComplianceReportScreen> {
  final _pdfService = PdfReportService();

  final List<Map<String, dynamic>> _mockReports = [
    {
      'id': 'REP-220-X',
      'title': 'Structural Audit: Sector 4 Overpass',
      'date': '2024-04-01',
      'status': 'Verified',
      'author': 'Ins-402 (Mechanical)',
      'isCritical': false,
      'assetType': AssetType.bridge,
    },
    {
      'id': 'REP-119-A',
      'title': 'Sewer Integrity Scan: Central Hub',
      'date': '2024-03-28',
      'status': 'Pending Approval',
      'author': 'Ins-771 (Utilities)',
      'isCritical': true,
      'assetType': AssetType.sewerLine,
    },
    {
      'id': 'REP-330-B',
      'title': 'Pavement Quality Report: High St',
      'date': '2024-03-15',
      'status': 'Verified',
      'author': 'Ins-901 (Civil)',
      'isCritical': false,
      'assetType': AssetType.pavement,
    },
    {
      'id': 'REP-001-Z',
      'title': 'Electrical Substation X2 Diagnostic',
      'date': '2024-03-05',
      'status': 'Under Review',
      'author': 'Ins-411 (Electrical)',
      'isCritical': true,
      'assetType': AssetType.powerGrid,
    },
  ];

  void _downloadPdf(Map<String, dynamic> data) async {
    // Scaffold showing generation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating Professional Audit Certificate...'), duration: Duration(seconds: 1)),
    );

    final record = InspectionRecord(
      id: data['id'],
      inspectorId: data['author'],
      assetId: 'ASSET_${data['id']}',
      assetType: data['assetType'] as AssetType,
      assetName: data['title'],
      address: 'Industrial Sector 4, Grid Hub',
      latitude: 28.6139,
      longitude: 77.2090,
      inspectionDate: DateTime.parse(data['date']),
      type: 'Structural Audit',
      defects: [],
      aiAnalysisResult: {
        'patternId': 'PAT-${data['id'].split('-').last}RT',
        'severity': data['isCritical'] ? 'CRITICAL' : 'LOW',
        'finding': data['title'],
        'recommendation': 'Conduct deep secondary audit within 14 business days.',
        'description': 'Automated scan detected structural fatigue markers consistent with late-cycle masonry stress.',
      },
      photoUrls: [],
      notes: 'Routine industrial compliance check.',
      status: data['status'] == 'Verified' ? ComplianceStatus.compliant : ComplianceStatus.pendingReview,
    );

    await _pdfService.generateAndPrintReport(record);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amber = const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Compliance Reports',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildComplianceHeader(amber, isDark),
            const SizedBox(height: 24),
            Text(
              'RECENT DOCUMENTATION',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.grey,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            ..._mockReports.map((report) => _buildReportCard(report, isDark, amber)),
          ],
        ),
      ),
    );
  }

  Widget _buildComplianceHeader(Color amber, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: amber,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark) BoxShadow(color: amber.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_user_rounded, color: Colors.black87, size: 32),
          const SizedBox(height: 16),
          Text(
            'Infrastructure Status: COMPLIANT',
            style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Last Regional Audit: 24 hours ago',
            style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report, bool isDark, Color amber) {
    final statusColor = report['status'] == 'Verified' ? const Color(0xFF10B981) : amber;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.description_rounded, color: isDark ? Colors.white60 : Colors.black54, size: 24),
              ),
              if (report['isCritical'] as bool)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: const Color(0xFFEF4444), shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(report['title'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text('${report['date']} • ${report['author']}', style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                report['status'] as String,
                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
              ),
              const SizedBox(height: 4),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf, color: Colors.grey, size: 24),
                onPressed: () => _downloadPdf(report),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
