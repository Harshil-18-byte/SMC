import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/data/services/firestore_service.dart';

class VitalsAnalyticsScreen extends StatefulWidget {
  const VitalsAnalyticsScreen({super.key});

  @override
  State<VitalsAnalyticsScreen> createState() => _VitalsAnalyticsScreenState();
}

class _VitalsAnalyticsScreenState extends State<VitalsAnalyticsScreen> {
  String _selectedPeriod = '7D';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final firestore = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(l10n.translate('vitals_trends')),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_chart_rounded),
              onPressed: () async {
                await firestore.createDocument(
                    collection: 'citizens/CIT001/vitals',
                    data: {
                      'timestamp': DateTime.now().toIso8601String(),
                      'heartRate': 75,
                      'systolic': 120,
                      'diastolic': 80,
                      'temp': 98.6,
                      'oxygen': 99,
                    });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("New vitals recorded.")),
                );
              }),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
          stream:
              firestore.streamCollection(collection: 'citizens/CIT001/vitals'),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text(l10n.translate('err_generic')));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final vitals = snapshot.data ?? [];
            vitals.sort((a, b) =>
                (a['timestamp'] as String).compareTo(b['timestamp'] as String));

            List<FlSpot> hrSpots = [];
            List<FlSpot> bpSpots = [];

            for (int i = 0; i < vitals.length; i++) {
              hrSpots.add(FlSpot(
                  i.toDouble(), (vitals[i]['heartRate'] ?? 70).toDouble()));
              bpSpots.add(FlSpot(
                  i.toDouble(), (vitals[i]['systolic'] ?? 120).toDouble()));
            }

            if (hrSpots.isEmpty) {
              hrSpots = [const FlSpot(0, 70), const FlSpot(6, 72)];
              bpSpots = [const FlSpot(0, 120), const FlSpot(6, 122)];
            }

            final latestHR =
                vitals.isNotEmpty ? vitals.last['heartRate'].toString() : "70";
            final latestBP = vitals.isNotEmpty
                ? "${vitals.last['systolic']}/${vitals.last['diastolic']}"
                : "120/80";

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildPeriodSelector(isDark),
                  const SizedBox(height: 24),
                  _buildVitalsCard(
                    l10n.translate('bp_trend'),
                    latestBP,
                    "mmHg",
                    Colors.red,
                    bpSpots,
                    isDark,
                  ),
                  const SizedBox(height: 24),
                  _buildVitalsCard("Heart Rate", latestHR, "bpm", Colors.orange,
                      hrSpots, isDark),
                  const SizedBox(height: 32),
                  _buildWeightGoal(isDark),
                  const SizedBox(height: 80),
                ],
              ),
            );
          }),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    final periods = ['7D', '1M', '3M', '6M', '1Y'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: periods
          .map((p) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = p),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _selectedPeriod == p
                          ? const Color(0xFF137fec)
                          : (isDark ? const Color(0xFF1C242D) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        p,
                        style: TextStyle(
                          color:
                              _selectedPeriod == p ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildVitalsCard(String title, String value, String unit, Color color,
      List<FlSpot> spots, bool isDark) {
    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C242D) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                value,
                                style: GoogleFonts.outfit(
                                    fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            unit,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.show_chart_rounded, color: color),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: color,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightGoal(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF137fec).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Weight Goal",
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF137fec)),
              ),
              const Text("72 / 68 kg",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: const LinearProgressIndicator(
              value: 0.7,
              minHeight: 12,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Almost there! You have lost 4kg since January. Keep maintaining your diet.",
            style: TextStyle(fontSize: 13, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}


