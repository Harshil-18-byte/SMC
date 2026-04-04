import 'package:flutter/material.dart';
import 'package:smc/data/services/auth_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/citizen_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smc/core/services/pdf_service.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tactical Digital Identity Screen
/// Repurposed from Health ID to a professional City Operational / Resident ID.
class TacticalIDScreen extends StatelessWidget {
  const TacticalIDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid ?? 'cit_001';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        leading: const SMCBackButton(),
        title: Text('TACTICAL IDENTITY', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FirestoreService().streamDocument(collection: 'citizens', docId: uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(child: Text('NO REGISTRY DATA FOUND', style: GoogleFonts.outfit(color: Colors.grey)));
          }

          final citizen = Citizen.fromMap(data, uid);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildTacticalIDCard(context, citizen),
                const SizedBox(height: 32),
                _buildRegistryDetails(context, citizen, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTacticalIDCard(BuildContext context, Citizen citizen) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(color: Theme.of(context).primaryColor.withValues(alpha: 0.1), blurRadius: 30, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REGISTRY CLEARANCE', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    const SizedBox(height: 8),
                    Text(citizen.name.toUpperCase(), style: GoogleFonts.outfit(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                Icon(Icons.verified_user_rounded, color: Theme.of(context).primaryColor, size: 36),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _idField('REGISTRY ID', citizen.inspectionId),
                      const SizedBox(height: 16),
                      _idField('SECTOR ACCESS', 'LEVEL-4 (NORTH)'),
                      const SizedBox(height: 16),
                      _idField('VALID UNTIL', 'DEC 2026'),
                    ],
                  ),
                ),
                QrImageView(
                  data: citizen.inspectionId,
                  version: QrVersions.auto,
                  size: 100.0,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => PdfService.generateInspectionIDCard(citizen),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_download_outlined, color: Theme.of(context).primaryColor, size: 18),
                  const SizedBox(width: 8),
                  Text('EXPORT DIGITAL CREDENTIALS', style: GoogleFonts.outfit(color: Theme.of(context).primaryColor, fontSize: 11, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _idField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 15, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildRegistryDetails(BuildContext context, Citizen citizen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CONTACT REGISTRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        _detailTile(Icons.phone_android_rounded, 'SECURE LINE', citizen.phone),
        _detailTile(Icons.alternate_email_rounded, 'WORK EMAIL', citizen.email),
        _detailTile(Icons.map_rounded, 'ASSIGNED ZONE', citizen.address),
      ],
    );
  }

  Widget _detailTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
