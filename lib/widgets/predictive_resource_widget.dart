import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:google_fonts/google_fonts.dart';

/// AI-Driven Predictive Maintenance & Resource Analysis Widget
/// Analyzes infrastructure telemetry to predict structural failure points and maintenance requirements.
class PredictiveResourceWidget extends StatefulWidget {
  const PredictiveResourceWidget({super.key});

  @override
  State<PredictiveResourceWidget> createState() => _PredictiveResourceWidgetState();
}

class _PredictiveResourceWidgetState extends State<PredictiveResourceWidget> with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _insights = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(duration: const Duration(seconds: 3), vsync: this)..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _runDiagnostics();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _runDiagnostics() async {
    if (!mounted) return;
    try {
      final assets = await _firestoreService.getCollection(collection: 'asset_intake_status');
      final List<Map<String, dynamic>> generatedInsights = [];

      for (var asset in assets) {
        final health = (asset['healthScore'] as num?)?.toDouble() ?? 100.0;
        final maxHealth = (asset['maxHealth'] as num?)?.toDouble() ?? 100.0;
        final name = asset['name'] ?? 'Asset';
        final integrityRatio = health / maxHealth;

        if (integrityRatio < 0.4) {
          generatedInsights.add({
            'type': 'critical',
            'icon': Icons.warning_rounded,
            'color': Colors.red,
            'message': 'CRITICAL: $name - Structural Integrity < 40%.',
            'action': 'Immediate closure recommended for inspection.',
          });
        } else if (integrityRatio < 0.7) {
          generatedInsights.add({
            'type': 'warning',
            'icon': Icons.engineering_rounded,
            'color': Colors.orange,
            'message': '$name - Degradation detected.',
            'action': 'Schedule maintenance within 7 days.',
          });
        }
      }

      if (generatedInsights.isEmpty) {
        generatedInsights.add({
          'type': 'status',
          'icon': Icons.check_circle_rounded,
          'color': Colors.green,
          'message': 'All Regional Systems Operational.',
          'action': 'Next global audit in 48 hours.',
        });
      }

      if (mounted) {
        setState(() {
          _insights = generatedInsights.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Diagnostic Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));

    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.1)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.blue, size: 18),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("AI PREDICTIVE TERMINAL", style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.blue)),
                    const Text("STRUCTURAL HEALTH ANALYSIS", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._insights.map((insight) => _insightItem(insight)),
          ],
        ),
      ),
    );
  }

  Widget _insightItem(Map<String, dynamic> insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (insight['color'] as Color).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (insight['color'] as Color).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(insight['icon'], color: insight['color'], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(insight['message'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                Text("Action: ${insight['action']}", style: TextStyle(fontSize: 10, color: Colors.grey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
