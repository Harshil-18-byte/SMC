import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Defect Diagnostic Engine Screen
/// Interactive structural integrity assessment tool for Field Inspectors.
class DefectDiagnosticEngineScreen extends StatefulWidget {
  final String assetComponentId;
  final String componentName;

  const DefectDiagnosticEngineScreen({
    super.key,
    required this.assetComponentId,
    required this.componentName,
  });

  @override
  State<DefectDiagnosticEngineScreen> createState() => _DefectDiagnosticEngineScreenState();
}

class _DefectDiagnosticEngineScreenState extends State<DefectDiagnosticEngineScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final Map<String, bool> _defectIndicators = {
    'Surface Cracking': false,
    'Deep Structural Fissures': false,
    'Rebar Corrosion': false,
    'Concrete Spalling': false,
    'Buckling / Warping': false,
    'Joint Displacement': false,
    'Efflorescence / Seepage': false,
    'Vibration Abnormality': false,
    'Foundation Settlement': false,
    'Protective Coating Failure': false,
  };

  double _structuralStress = 15.0; // PSI x 100
  int _defectAgeMonths = 1;
  String _severity = 'Minor';
  bool _environmentalRisk = false;
  bool _isSaving = false;

  final List<String> _severityLevels = ['Minor', 'Moderate', 'Severe', 'Critical'];

  String get _riskLevel {
    final indicatorCount = _defectIndicators.values.where((v) => v).length;
    final hasBuckling = _defectIndicators['Buckling / Warping'] == true;
    final hasFoundation = _defectIndicators['Foundation Settlement'] == true;
    final highStress = _structuralStress > 80.0;

    if (hasBuckling || hasFoundation || (highStress && indicatorCount >= 3) || _severity == 'Critical') {
      return 'CRITICAL (CAT-1)';
    } else if (indicatorCount >= 3 || highStress || _environmentalRisk || _severity == 'Severe') {
      return 'HIGH (CAT-2)';
    } else if (indicatorCount > 0) {
      return 'ROUTINE (CAT-3)';
    }
    return 'NOMINAL';
  }

  Color get _riskColor {
    switch (_riskLevel) {
      case 'CRITICAL (CAT-1)': return IndustrialVisuals.dangerRed;
      case 'HIGH (CAT-2)': return IndustrialVisuals.cautionYellow;
      case 'ROUTINE (CAT-3)': return Colors.blue;
      default: return IndustrialVisuals.successGreen;
    }
  }

  Future<void> _saveAssessment() async {
    setState(() => _isSaving = true);
    try {
      await _firestoreService.createDocument(
        collection: 'structural_assessments',
        data: {
          'componentId': widget.assetComponentId,
          'componentName': widget.componentName,
          'indicators': _defectIndicators,
          'stressLevel': _structuralStress,
          'ageMonths': _defectAgeMonths,
          'severity': _severity,
          'environmentalRisk': _environmentalRisk,
          'riskLevel': _riskLevel,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ DIAGNOSTIC LOGGED'), backgroundColor: IndustrialVisuals.successGreen),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transmission Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DEFECT DIAGNOSTICS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
            Text(widget.componentName, style: const TextStyle(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ],
        ),
      ),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRiskAssessment(),
              const SizedBox(height: 24),
              _buildIndicatorsList(),
              const SizedBox(height: 24),
              _buildStressInput(),
              const SizedBox(height: 24),
              _buildSeveritySelector(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRiskAssessment() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _riskColor, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, color: _riskColor, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RISK CLASSIFICATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    FittedBox(child: Text(_riskLevel, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: _riskColor))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('OBSERVED DEFECT INDICATORS'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: _defectIndicators.keys.map((indicator) {
              return CheckboxListTile(
                value: _defectIndicators[indicator],
                onChanged: (value) => setState(() => _defectIndicators[indicator] = value ?? false),
                title: Text(indicator, style: const TextStyle(color: Colors.white, fontSize: 14)),
                activeColor: Colors.blue,
                dense: true,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStressInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('MEASURED STRUCTURAL STRESS (PSI x 100)'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: [
              Text(_structuralStress.toStringAsFixed(1), style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.bold, color: _structuralStress > 80 ? Colors.red : Colors.white)),
              Slider(
                value: _structuralStress,
                min: 0.0, max: 150.0,
                activeColor: Colors.blue,
                onChanged: (val) => setState(() => _structuralStress = val),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeveritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('MANUAL SEVERITY OVERRIDE'),
        const SizedBox(height: 12),
        Row(
          children: _severityLevels.map((level) {
            final isSelected = _severity == level;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _severity = level),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: isSelected ? (_severity == 'Critical' ? Colors.red.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2)) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isSelected ? (_severity == 'Critical' ? Colors.red : Colors.blue) : Colors.white10),
                    ),
                    child: Center(child: Text(level, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isSelected ? (_severity == 'Critical' ? Colors.red : Colors.blue) : Colors.grey))),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return IndustrialVisuals.largeActionButton(
      label: 'SUBMIT DIAGNOSTIC LOG',
      icon: Icons.analytics_rounded,
      onTap: _isSaving ? () {} : _saveAssessment,
      color: Colors.blue,
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1.5));
  }
}
