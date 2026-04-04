import 'package:flutter/material.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/smc_back_button.dart';

class IntegrityCertificateScreen extends StatelessWidget {
  const IntegrityCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: Text(
          AppLocalizations.of(context).translate('vaccination_card'),
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.vaccines, color: Colors.white, size: 32),
                      Icon(Icons.verified, color: Colors.white, size: 32),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)
                        .translate('digital_vaccination_record'),
                    style: const TextStyle(
                      color: Colors.white70,
                      letterSpacing: 1.5,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoColumn(
                          AppLocalizations.of(context).translate('dose_1'),
                          'Apr 12, 2024'),
                      _buildInfoColumn(
                          AppLocalizations.of(context).translate('dose_2'),
                          'May 12, 2024'),
                      _buildInfoColumn(
                          AppLocalizations.of(context).translate('status'),
                          AppLocalizations.of(context)
                              .translate('fully_vaccinated')),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildHistoryItem(
                    context,
                    'COVID-19 Booster',
                    'Jan 15, 2025',
                    'City Site',
                  ),
                  _buildHistoryItem(
                    context,
                    'Influenza',
                    'Oct 10, 2024',
                    'Community Clinic',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String vaccine,
    String date,
    String location,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccine,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  '$date • $location',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
