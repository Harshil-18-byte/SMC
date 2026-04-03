import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/core/theme/universal_theme.dart';
import 'package:smc/data/models/patient_medication.dart';

import 'package:smc/data/services/firestore_service.dart';

class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({super.key});

  @override
  State<MedicationRemindersScreen> createState() =>
      _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final String _citizenId = 'citizen_1'; // Demo ID

  List<PatientMedication> _medications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    try {
      final data = await _firestoreService.getCollection(
        collection: 'citizens/$_citizenId/medications',
      );

      if (mounted) {
        setState(() {
          _medications = data
              .map((m) => PatientMedication.fromMap(m, m['id'] as String))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading medications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addMedication(PatientMedication med) async {
    setState(() => _isLoading = true);
    try {
      await _firestoreService.createDocument(
        collection: 'citizens/$_citizenId/medications',
        data: med.toMap(),
      );

      await _loadMedications(); // Reload list

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Medication added successfully!')),
        );
      }
    } catch (e) {
      debugPrint('Error adding medication: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding medication: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(
          'Medications & Reminders',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddMedicationDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(
                  UniversalTheme.getSpacing(context, SpacingSize.md)),
              children: [
                if (_medications.isNotEmpty) ...[
                  _buildSectionHeader('Today\'s Schedule', isDark),
                  const SizedBox(height: 12),
                  ..._buildTodaySchedule(isDark),
                  const SizedBox(height: 24),
                ],
                _buildSectionHeader('All Medications', isDark),
                const SizedBox(height: 12),
                if (_medications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No medications added yet.'),
                  )
                else
                  ..._medications
                      .map((med) => _buildMedicationCard(med, isDark)),
              ],
            ),
    );
  }

  // ... _buildSectionHeader, _buildTodaySchedule, _buildTimelineItem, _buildMedicationCard, _buildSupplyBar, _formatTime remain mostly same ...

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.grey[300] : const Color(0xFF111418),
      ),
    );
  }

  List<Widget> _buildTodaySchedule(bool isDark) {
    return _medications
        .where((m) => m.frequency == MedicationFrequency.daily)
        .expand(
            (m) => m.reminderTimes.map((t) => _buildTimelineItem(m, t, isDark)))
        .toList();
  }

  // Need to bring back other helper methods here since replacing whole file
  Widget _buildTimelineItem(
      PatientMedication med, TimeOfDay time, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C242D) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF137fec).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _formatTime(time),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF137fec),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF111418),
                  ),
                ),
                Text(
                  '${med.dosage} • ${med.instructions}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Checkbox(
            value: false,
            onChanged: (val) {},
            activeColor: const Color(0xFF10B981),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationCard(PatientMedication med, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C242D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    med.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111418),
                    ),
                  ),
                  Text(
                    'Prescribed by ${med.doctorName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (med.isLow ? Colors.amber : Colors.blue)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medication_liquid_sharp,
                  color: med.isLow ? Colors.amber : Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSupplyBar(med, isDark),
        ],
      ),
    );
  }

  Widget _buildSupplyBar(PatientMedication med, bool isDark) {
    final progress = med.progress;
    final color = med.isLow ? Colors.amber : const Color(0xFF10B981);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Supply Left',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '${med.dosesLeft} / ${med.totalDoses} doses',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        if (med.isLow)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  'Low supply. Request refill soon.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.amber[200] : Colors.amber[800],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute $period";
  }

  void _showAddMedicationDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddMedicationDialog(onAdd: _addMedication),
    );
  }
}

class _AddMedicationDialog extends StatefulWidget {
  final Function(PatientMedication) onAdd;

  const _AddMedicationDialog({required this.onAdd});

  @override
  State<_AddMedicationDialog> createState() => _AddMedicationDialogState();
}

class _AddMedicationDialogState extends State<_AddMedicationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _doctorController = TextEditingController();
  final _instructionsController = TextEditingController();
  TimeOfDay _time1 = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medication'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Medication Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _dosageController,
                decoration:
                    const InputDecoration(labelText: 'Dosage (e.g. 500mg)'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _doctorController,
                decoration: const InputDecoration(labelText: 'Doctor Name'),
              ),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(labelText: 'Instructions'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Reminder Time: '),
                  TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                          context: context, initialTime: _time1);
                      if (t != null) setState(() => _time1 = t);
                    },
                    child: Text(_time1.format(context)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final med = PatientMedication(
                id: '', // Generated by Firestore
                name: _nameController.text,
                dosage: _dosageController.text,
                frequency: MedicationFrequency.daily,
                reminderTimes: [_time1],
                dosesLeft: 30, // Default for now
                totalDoses: 30,
                doctorName: _doctorController.text,
                instructions: _instructionsController.text,
              );
              widget.onAdd(med);
              Navigator.pop(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}


