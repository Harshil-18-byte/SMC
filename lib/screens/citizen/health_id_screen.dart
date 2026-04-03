import 'package:flutter/material.dart';
import 'package:smc/data/services/auth_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/citizen_model.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/services/pdf_service.dart';
import 'package:smc/core/widgets/smc_back_button.dart';

class HealthIDScreen extends StatelessWidget {
  const HealthIDScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid ?? 'cit_001';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: Text(AppLocalizations.of(context).healthID),
      ),
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FirestoreService()
            .streamDocument(collection: 'citizens', docId: uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
                child: Text(AppLocalizations.of(context)
                    .translate('no_data_available')));
          }

          final citizen = Citizen.fromMap(data, uid);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildIDCard(context, citizen, isDark),
                const SizedBox(height: 32),
                _buildInfoSection(context, citizen, isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIDCard(BuildContext context, Citizen citizen, bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
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
                    Text(
                      AppLocalizations.of(context).translate('health_identity'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      citizen.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.health_and_safety_rounded,
                      color: Colors.white, size: 32),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              // borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMetaInfo(
                          AppLocalizations.of(context)
                              .translate('health_id_label'),
                          citizen.healthId),
                      const SizedBox(height: 16),
                      _buildMetaInfo(
                          AppLocalizations.of(context).translate('blood_group'),
                          citizen.bloodGroup),
                      const SizedBox(height: 16),
                      _buildMetaInfo(
                          AppLocalizations.of(context).translate('age'),
                          '${citizen.age} ${AppLocalizations.of(context).translate('years')}'),
                    ],
                  ),
                ),
                QrImageView(
                  data: citizen.healthId,
                  version: QrVersions.auto,
                  size: 100.0,
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          // Download Action
          InkWell(
            onTap: () => PdfService.generateHealthIDCard(citizen),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.05),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.file_download_outlined,
                      color: Color(0xFF64748B), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'DOWNLOAD DIGITAL COPY',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Citizen citizen, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).translate('contact_information'),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 16),
        _buildInfoTile(Icons.phone_rounded, 'Phone', citizen.phone, isDark),
        _buildInfoTile(Icons.email_rounded, 'Email', citizen.email, isDark),
        _buildInfoTile(
            Icons.location_on_rounded, 'Address', citizen.address, isDark),
      ],
    );
  }

  Widget _buildInfoTile(
      IconData icon, String label, String value, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
