import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/data/services/firestore_service.dart';

class VolunteerNetworkScreen extends StatefulWidget {
  const VolunteerNetworkScreen({super.key});

  @override
  State<VolunteerNetworkScreen> createState() => _VolunteerNetworkScreenState();
}

class _VolunteerNetworkScreenState extends State<VolunteerNetworkScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final firestoreService =
        Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(l10n.translate('volunteer_network')),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context, l10n, isDark, firestoreService),
            const SizedBox(height: 32),
            _buildSectionTitle(l10n.translate('inspection_camps')),
            _buildCampsList(context, isDark, firestoreService),
            const SizedBox(height: 32),
            _buildVolunteerBenefits(isDark),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppLocalizations l10n, bool isDark,
      FirestoreService firestore) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF137fec),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            child:
                const Icon(Icons.groups_rounded, color: Colors.white, size: 56),
          ),
          const SizedBox(height: 20),
          FadeInLeft(
            child: Text(
              "Join the SMC Volunteer Force",
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            child: Text(
              "Help us make Bharat a inspectionier city. Volunteer for upcoming medical camps and inspection drives.",
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            child: ElevatedButton(
              onPressed: () async {
                await firestore.createDocument(collection: 'volunteers', data: {
                  'joinedAt': DateTime.now().toIso8601String(),
                  'status': 'active',
                  'userId': 'CIT001',
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("You have joined the volunteer force!")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF137fec),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(l10n.translate('join_as_volunteer')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style:
                GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text("View All",
              style:
                  TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCampsList(
      BuildContext context, bool isDark, FirestoreService firestore) {
    return StreamBuilder<List<Map<String, dynamic>>>(
        stream:
            firestore.streamCollection(collection: 'volunteer_opportunities'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
                height: 200, child: Center(child: CircularProgressIndicator()));
          }
          final camps = snapshot.data ?? [];
          if (camps.isEmpty) {
            return const Center(child: Text("No upcoming camps."));
          }

          return SizedBox(
            height: 200,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: camps.length,
              itemBuilder: (context, index) {
                final camp = camps[index];
                final color = Color(camp['colorValue'] ?? 0xFF137fec);
                return FadeInRight(
                  delay: Duration(milliseconds: index * 100),
                  child: Container(
                    width: 280,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C242D) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            camp['date'] ?? '',
                            style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 11),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(camp['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(camp['location'] ?? '',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 13)),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(camp['needed'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                    color: Colors.blueGrey)),
                            const Icon(Icons.arrow_forward_rounded,
                                color: Theme.of(context).primaryColor, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _buildVolunteerBenefits(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.orange, size: 32),
                const SizedBox(width: 12),
                Text(
                  "Volunteer Rewards",
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Earn certificates, city inspection credits, and special SMC insurance benefits for your contribution to the community.",
              style:
                  TextStyle(color: Colors.blueGrey, fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}


