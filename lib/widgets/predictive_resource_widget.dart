import 'package:flutter/material.dart';

import 'package:smc/data/services/firestore_service.dart';

class PredictiveResourceWidget extends StatefulWidget {
  const PredictiveResourceWidget({super.key});

  @override
  State<PredictiveResourceWidget> createState() =>
      _PredictiveResourceWidgetState();
}

class _PredictiveResourceWidgetState extends State<PredictiveResourceWidget>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _alerts = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController);

    _analyzeData();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _analyzeData() async {
    try {
      // Fetch hospitals with high occupancy or low resources
      final hospitals = await _firestoreService.getCollection(
          collection: 'hospital_intake_status');

      final List<Map<String, dynamic>> generatedAlerts = [];

      for (var hospital in hospitals) {
        final total = (hospital['bedTotal'] as num?)?.toInt() ?? 100;
        final available = (hospital['bedAvailable'] as num?)?.toInt() ?? 0;
        final name = hospital['name'] ?? 'Unknown Hospital';
        final occupancy = total > 0 ? 1.0 - (available / total) : 0.0;

        if (occupancy > 0.9) {
          generatedAlerts.add({
            'type': 'critical',
            'icon': Icons.warning_amber_rounded,
            'color': Colors.red,
            'message': '$name is at ${(occupancy * 100).toInt()}% capacity.',
            'action': 'Divert to nearest facility',
          });
        } else if (occupancy > 0.75) {
          generatedAlerts.add({
            'type': 'warning',
            'icon': Icons.info_outline,
            'color': Colors.orange,
            'message': '$name is at ${(occupancy * 100).toInt()}% capacity.',
            'action': 'Monitor closely',
          });
        }

        // Mock Inventory Checks (since inventory.csv isn't fully linked yet)
        if (total > 500 && available < 20) {
          generatedAlerts.add({
            'type': 'resource',
            'icon': Icons.local_hospital,
            'color': Colors.blue,
            'message': '$name running low on beds.',
            'action': 'Request resource transfer',
          });
        }
      }

      // Add general AI suggestion if no critical alerts
      if (generatedAlerts.isEmpty) {
        generatedAlerts.add({
          'type': 'optimization',
          'icon': Icons.insights,
          'color': Colors.green,
          'message': 'System operating at optimal levels.',
          'action': 'View detailed analytics',
        });
      }

      if (mounted) {
        setState(() {
          // Take top 3 alerts
          _alerts = generatedAlerts.take(3).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error analyzing data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          color: Theme.of(context).primaryColor,
          strokeWidth: 2,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 4),
            blurRadius: 16,
          ),
        ],
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome,
                      color: Colors.purple, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "AI Smart Insights",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Predictive Resource Allocation",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall!.color,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._alerts.map((alert) => _buildAlertItem(context, alert)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, Map<String, dynamic> alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (alert['color'] as Color).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (alert['color'] as Color).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(alert['icon'], color: alert['color'], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['message'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "Suggested Action: ${alert['action']}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios,
              size: 14, color: Theme.of(context).disabledColor),
        ],
      ),
    );
  }
}


