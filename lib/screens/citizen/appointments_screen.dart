import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:smc/screens/citizen/book_inspection_sheet.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inspections & Audit Schedule Screen
/// Replaces AppointmentsScreen. Tracks active and completed site audits.
class InspectionsScreen extends StatelessWidget {
  const InspectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: const SMCBackButton(),
        title: Text('ACTIVE AUDIT CYCLES', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().streamCollection(
          collection: 'inspections', // Updated collection name
          orderBy: 'scheduledTime',
          descending: true,
        ),
        builder: (context, snapshot) {
          final rawInspections = snapshot.data ?? [];
          final inspections = rawInspections.isEmpty
              ? [
                  {
                    'id': 'insp1',
                    'inspectorName': 'Arnav Desai',
                    'assetName': 'City Bridge-04',
                    'scheduledTime': DateTime.now().add(const Duration(days: 2)).toIso8601String(),
                    'status': 'confirmed',
                    'type': 'Structural Audit'
                  },
                  {
                    'id': 'insp2',
                    'inspectorName': 'Sasha Roy',
                    'assetName': 'Sector 4 Grid',
                    'scheduledTime': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
                    'status': 'completed',
                    'type': 'Electrical Integrity'
                  },
                ]
              : rawInspections;

          if (inspections.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: inspections.length,
            itemBuilder: (context, index) => _buildInspectionCard(context, inspections[index], isDark),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookInspectionSheet(context),
        backgroundColor: Theme.of(context).primaryColor,
        label: Text('NEW AUDIT CYCLE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 12)),
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildInspectionCard(BuildContext context, Map<String, dynamic> insp, bool isDark) {
    final time = insp['scheduledTime'] != null ? DateTime.parse(insp['scheduledTime']) : DateTime.now();
    final status = insp['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: _getStatusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(_getStatusIcon(status), color: _getStatusColor(status)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insp['inspectorName']?.toUpperCase() ?? 'UNASSIGNED', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                Text(insp['assetName'] ?? 'Unknown Asset', style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 4),
                    Text(DateFormat('MMM dd, yyyy - hh:mm a').format(time), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          _statusBadge(status),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: _getStatusColor(status).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(status))),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'completed': return Theme.of(context).primaryColor;
      default: return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed': return Icons.verified_rounded;
      case 'cancelled': return Icons.cancel_rounded;
      case 'completed': return Icons.task_alt_rounded;
      default: return Icons.pending_actions_rounded;
    }
  }

  void _showBookInspectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookInspectionSheet(onBooked: (insp) {}),
    );
  }
}
