import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';

/// Symptom Checker Screen
/// Interactive symptom assessment tool for field workers
class SymptomCheckerScreen extends StatefulWidget {
  final String householdMemberId;
  final String memberName;

  const SymptomCheckerScreen({
    super.key,
    required this.householdMemberId,
    required this.memberName,
  });

  @override
  State<SymptomCheckerScreen> createState() => _SymptomCheckerScreenState();
}

class _SymptomCheckerScreenState extends State<SymptomCheckerScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final Map<String, bool> _symptoms = {
    'Fever': false,
    'Cough': false,
    'Shortness of Breath': false,
    'Fatigue': false,
    'Body Aches': false,
    'Headache': false,
    'Loss of Taste/Smell': false,
    'Sore Throat': false,
    'Runny Nose': false,
    'Nausea': false,
    'Diarrhea': false,
  };

  double _temperature = 98.6;
  int _symptomDuration = 1;
  String _severity = 'Mild';
  bool _hasContactHistory = false;
  bool _isSaving = false;

  final List<String> _severityLevels = ['Mild', 'Moderate', 'Severe'];

  String get _riskLevel {
    final symptomCount = _symptoms.values.where((v) => v).length;
    final hasFever = _symptoms['Fever'] == true && _temperature > 100.4;
    final hasBreathing = _symptoms['Shortness of Breath'] == true;

    if (hasBreathing ||
        (_severity == 'Severe') ||
        (hasFever && symptomCount >= 3)) {
      return 'High';
    } else if (symptomCount >= 2 || hasFever || _hasContactHistory) {
      return 'Medium';
    } else if (symptomCount > 0) {
      return 'Low';
    }
    return 'None';
  }

  Color get _riskColor {
    switch (_riskLevel) {
      case 'High':
        return const Color(0xFFFF4D4D);
      case 'Medium':
        return const Color(0xFFFFAB00);
      case 'Low':
        return const Color(0xFF137fec);
      default:
        return const Color(0xFF10B981);
    }
  }

  Future<void> _saveAssessment() async {
    setState(() => _isSaving = true);

    try {
      await _firestoreService.createDocument(
        collection: 'symptom_assessments',
        data: {
          'memberId': widget.householdMemberId,
          'memberName': widget.memberName,
          'symptoms': _symptoms,
          'temperature': _temperature,
          'symptomDuration': _symptomDuration,
          'severity': _severity,
          'hasContactHistory': _hasContactHistory,
          'riskLevel': _riskLevel,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      setState(() => _isSaving = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Assessment saved'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Symptom Checker',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            Text(
              widget.memberName,
              style: const TextStyle(fontSize: 12, color: Color(0xFF137fec)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRiskAssessment(),
            const SizedBox(height: 24),
            _buildSymptomsList(),
            const SizedBox(height: 24),
            _buildTemperatureInput(),
            const SizedBox(height: 24),
            _buildDurationInput(),
            const SizedBox(height: 24),
            _buildSeveritySelector(),
            const SizedBox(height: 24),
            _buildContactHistory(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskAssessment() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _riskColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _riskColor, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                _riskLevel == 'High'
                    ? Icons.error
                    : _riskLevel == 'Medium'
                        ? Icons.warning
                        : Icons.info,
                color: _riskColor,
                size: 32,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RISK LEVEL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _riskLevel,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _riskColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_riskLevel == 'High') ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D4D).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_hospital, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Immediate medical attention recommended',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSymptomsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT SYMPTOMS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: _symptoms.keys.map((symptom) {
              return CheckboxListTile(
                value: _symptoms[symptom],
                onChanged: (value) {
                  setState(() => _symptoms[symptom] = value ?? false);
                },
                title: Text(
                  symptom,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 15,
                  ),
                ),
                activeColor: const Color(0xFF137fec),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTemperatureInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BODY TEMPERATURE (°F)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              Text(
                _temperature.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _temperature > 100.4
                      ? const Color(0xFFFF4D4D)
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              Slider(
                value: _temperature,
                min: 95.0,
                max: 106.0,
                divisions: 110,
                activeColor: _temperature > 100.4
                    ? const Color(0xFFFF4D4D)
                    : const Color(0xFF137fec),
                inactiveColor: Colors.grey[800],
                onChanged: (value) {
                  setState(() => _temperature = value);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '95°F',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Text(
                    '106°F',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SYMPTOM DURATION (DAYS)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _symptomDuration > 1
                    ? () => setState(() => _symptomDuration--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: const Color(0xFF137fec),
                iconSize: 32,
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$_symptomDuration ${_symptomDuration == 1 ? 'day' : 'days'}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _symptomDuration++),
                icon: const Icon(Icons.add_circle_outline),
                color: const Color(0xFF137fec),
                iconSize: 32,
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
        Text(
          'SEVERITY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _severityLevels.map((level) {
            final isSelected = _severity == level;
            final color = level == 'Severe'
                ? const Color(0xFFFF4D4D)
                : level == 'Moderate'
                    ? const Color(0xFFFFAB00)
                    : const Color(0xFF137fec);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _severity = level),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.1)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? color
                            : Colors.grey.withValues(alpha: 0.2),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        level,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildContactHistory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: CheckboxListTile(
        value: _hasContactHistory,
        onChanged: (value) {
          setState(() => _hasContactHistory = value ?? false);
        },
        title: Text(
          'Contact with confirmed case',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'In the past 14 days',
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
        ),
        activeColor: const Color(0xFFFFAB00),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveAssessment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF137fec),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Save Assessment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}


