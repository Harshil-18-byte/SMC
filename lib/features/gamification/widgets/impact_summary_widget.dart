import 'package:flutter/material.dart';

class ImpactSummaryWidget extends StatelessWidget {
  final int livesSaved;
  final int outbreaksPrevented;
  final int qualityScore;
  final int familiesHelped;

  const ImpactSummaryWidget({
    super.key,
    required this.livesSaved,
    required this.outbreaksPrevented,
    required this.qualityScore,
    required this.familiesHelped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.public, color: Colors.blueAccent, size: 20),
              SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'YOUR REAL-WORLD IMPACT',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    letterSpacing: 1.2,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildImpactCard(
                  'LIVES SAVED',
                  livesSaved.toString(),
                  Icons.favorite,
                  Colors.redAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImpactCard(
                  'OUTBREAKS STOPPED',
                  outbreaksPrevented.toString(),
                  Icons.shield,
                  Colors.blueAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildImpactCard(
                  'DATA QUALITY',
                  '$qualityScore%',
                  Icons.verified,
                  Colors.greenAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildImpactCard(
                  'FAMILIES HELPED',
                  familiesHelped.toString(),
                  Icons.people,
                  Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline,
                    color: Colors.indigoAccent, size: 16),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Your data provides crucial insights to the Bharat Inspection Board.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}


