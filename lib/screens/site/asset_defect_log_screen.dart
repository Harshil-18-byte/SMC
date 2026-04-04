import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Critical Defect Registry Screen
/// Dynamic log of discovered infrastructure defects, logging their severity, ingress time, and audit status.
class AssetDefectLogScreen extends StatelessWidget {
  const AssetDefectLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: const SMCBackButton(),
        title: Text('DEFECT REGISTRY', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_toggle_off_rounded, color: Colors.blue),
            onPressed: () {},
          ),
        ],
      ),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('site_admissions') // Internal collection name remains for data compatibility
              .orderBy('admissionTime', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Telemetry Sync Error', style: TextStyle(color: Colors.red)));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('NO ACTIVE DEFECTS LOGGED', style: GoogleFonts.outfit(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;
                final severity = data['severity'] ?? 'Low';
                final color = _getRiskColor(severity);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.2)),
                  ),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(Icons.report_problem_rounded, color: color, size: 20),
                    ),
                    title: Text(data['assetName'] ?? 'Asset Element', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    subtitle: Text('RISK: ${severity.toUpperCase()} • INGRESS: ${data['status'] ?? 'Pending'}', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                    trailing: const Icon(Icons.more_vert_rounded, color: Colors.grey, size: 18),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getRiskColor(String severity) {
    switch (severity) {
      case 'Critical': return Colors.red;
      case 'Medium': return Colors.orange;
      case 'Low': return Colors.green;
      default: return Colors.grey;
    }
  }
}
