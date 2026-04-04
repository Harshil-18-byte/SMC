import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/services/pdf_service.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/smc_back_button.dart';

class VaccinationPortalScreen extends StatelessWidget {
  const VaccinationPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: Text(AppLocalizations.of(context).vaccination),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 32),
            _buildSectionTitle(context,
                AppLocalizations.of(context).translate('available_vaccines')),
            const SizedBox(height: 16),
            _buildVaccineCard(
              context,
              'COVID-19 Booster',
              'Available for 18+ years',
              'Civil Site Bharat',
              Icons.vaping_rooms_rounded,
              const Color(0xFF137fec),
            ),
            const SizedBox(height: 16),
            _buildVaccineCard(
              context,
              'Influenza (Flu)',
              'Annual seasonal vaccine',
              'Ashwini Rugnalaya',
              Icons.opacity_rounded,
              const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context,
                AppLocalizations.of(context).translate('my_certificates')),
            const SizedBox(height: 16),
            _buildCertificateCard(
              context,
              'COVID-19 Primary Dose',
              'Dose 1 & 2 Completed',
              'Verified',
              isDark,
            ),
            const SizedBox(height: 32),
            _buildDigitalCardPrompt(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalCardPrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          const Icon(Icons.qr_code_2_rounded,
              color: Color(0xFF8B5CF6), size: 48),
          const SizedBox(height: 16),
          const Text(
            'Digital Vaccination Card',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Text(
            'Keep your records handy for travel and access to public spaces.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(
                  context, AppRoutes.viewerHome),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('View Digital Card',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Inspection, Protected',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Book appointments and download certificates for all your vaccinations.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.shield_rounded, color: Colors.white, size: 64),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildVaccineCard(
    BuildContext context,
    String title,
    String subtitle,
    String location,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: color),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booking slot for $title...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(AppLocalizations.of(context).translate('book')),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(
    BuildContext context,
    String title,
    String subtitle,
    String status,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded,
              color: Color(0xFF10B981), size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating certificate...')),
              );
              await PdfService.generateVaccinationCertificate(
                citizenName: 'Mahesh Shinde',
                vaccineName: title,
                dose: subtitle,
                date: '15 Jan 2026',
                site: 'SMC Civil Site, Bharat',
                certificateId: 'SMC-VAC-2026-X89',
              );
            },
            icon: const Icon(Icons.download_rounded, size: 20),
            label: const Text('PDF'),
            style:
                TextButton.styleFrom(foregroundColor: const Color(0xFF10B981)),
          ),
        ],
      ),
    );
  }
}
