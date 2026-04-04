import 'package:smc/data/models/inspection_record.dart';
import 'package:smc/data/services/defect_library_service.dart';

/// Professional Defect Analysis Engine
/// Enhanced with 10,000+ pattern matching logic.
class DefectAnalysisEngine {
  final DefectLibraryService _library = DefectLibraryService();
  
  /// Analyzes a defect using a multi-parameter scoring matrix and 10k library match.
  Map<String, dynamic> analyzeDefect({
    required AssetType assetType,
    required String defectLabel,
    required String description,
    Map<String, double>? metrics,
  }) {
    // 1. Base Severity based on defect nature
    double score = _getInitialSeverityScore(defectLabel);
    
    // 2. Multiplier based on Asset critical nature
    double multiplier = _getAssetRiskMultiplier(assetType);
    
    // 3. Nuance detection (Keyword density)
    double nuanceBonus = _calculateKeywordDensityScore(description);
    
    // 4. Metric evaluation
    double metricImpact = _analyzeMetrics(metrics);

    // Compute Final Risk Index (FRI)
    double finalScore = (score * multiplier) + nuanceBonus + metricImpact;
    finalScore = finalScore.clamp(0, 100);

    // 5. Intelligent Pattern Matching (The "10k" Logic)
    final patternMatch = _library.matchPattern(
      assetType: assetType,
      initialLabel: defectLabel,
      severityScore: finalScore,
    );

    return {
      'patternId': patternMatch['patternId'],
      'severity': _getSeverityLabel(finalScore),
      'score': finalScore,
      'finding': patternMatch['verdict'],
      'recommendation': patternMatch['correctiveAction'],
      'confidence': patternMatch['confidence'],
      'description': patternMatch['analysis'],
    };
  }

  double _getInitialSeverityScore(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('crack')) return 40.0;
    if (lower.contains('corrosion')) return 50.0;
    if (lower.contains('spalling')) return 55.0;
    if (lower.contains('shear')) return 85.0;
    if (lower.contains('settlement')) return 75.0;
    if (lower.contains('leakage')) return 35.0;
    if (lower.contains('buckling')) return 90.0;
    if (lower.contains('scour')) return 65.0;
    return 25.0;
  }

  double _getAssetRiskMultiplier(AssetType type) {
    switch (type) {
      case AssetType.bridge: return 1.5;
      case AssetType.powerGrid: return 1.7;
      case AssetType.pipeline: return 1.6;
      case AssetType.dam: return 2.0;
      case AssetType.tunnel: return 1.8;
      case AssetType.sewerLine: return 1.4;
      case AssetType.pavement: return 1.1;
      case AssetType.building: return 1.3;
      case AssetType.road: return 1.1;
      default: return 1.0;
    }
  }

  double _calculateKeywordDensityScore(String text) {
    final highRiskKeywords = ['exposed rebar', 'efflorescence', 'buckling', 'seepage', 'progressive'];
    double bonus = 0;
    for (var word in highRiskKeywords) {
      if (text.toLowerCase().contains(word)) bonus += 7.5;
    }
    return bonus;
  }

  double _analyzeMetrics(Map<String, double>? metrics) {
    if (metrics == null) return 0;
    double offset = 0;
    // Rule example: Crack width > 0.3mm is a structural threshold
    if ((metrics['width'] ?? 0) > 0.3) offset += 15.0;
    if ((metrics['length'] ?? 0) > 15.0) offset += 10.0;
    return offset;
  }

  String _getSeverityLabel(double score) {
    if (score >= 80) return 'CRITICAL';
    if (score >= 60) return 'HIGH';
    if (score >= 40) return 'MEDIUM';
    return 'LOW';
  }
}
