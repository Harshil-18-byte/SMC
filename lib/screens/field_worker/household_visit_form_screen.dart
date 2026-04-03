import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smc/data/services/realtime_sync_service.dart';
import 'package:smc/core/widgets/sync_status_indicator.dart';
import 'dart:io';

/// Household Visit Form Screen
/// Allows field workers to submit visit data with photos and real-time sync
class HouseholdVisitFormScreen extends StatefulWidget {
  final String workerId;
  final String householdId;
  final String householdName;

  const HouseholdVisitFormScreen({
    super.key,
    required this.workerId,
    required this.householdId,
    required this.householdName,
  });

  @override
  State<HouseholdVisitFormScreen> createState() =>
      _HouseholdVisitFormScreenState();
}

class _HouseholdVisitFormScreenState extends State<HouseholdVisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final List<File> _photos = [];
  bool _isSubmitting = false;

  // Form fields
  final _symptomsController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();

  String _visitType = 'routine';
  String _healthStatus = 'stable';

  // Symptom Tracking
  final Set<String> _detectedSymptoms = {};
  final Map<String, List<String>> _symptomKeywords = {
    'Fever': ['fever', 'high temp', 'temperature', 'hot', 'febrile'],
    'Cough': ['cough', 'coughing', 'dry cough'],
    'Breathing Difficulty': ['breath', 'breathing', 'shortness', 'dyspnea'],
    'Headache': ['headache', 'head pain', 'migraine'],
    'Body Ache': ['body ache', 'pain', 'muscle pain', 'joint pain'],
    'Fatigue': ['tired', 'fatigue', 'weakness', 'exhausted'],
    'Sore Throat': ['sore throat', 'throat pain', 'swallowing'],
    'Runny Nose': ['runny nose', 'cold', 'sneeze', 'sneezing'],
    'Nausea': ['nausea', 'vomit', 'vomiting', 'puke'],
    'Diarrhea': ['diarrhea', 'loose motion', 'stomach upset'],
  };

  @override
  void initState() {
    super.initState();
    _symptomsController.addListener(_detectSymptoms);
  }

  void _detectSymptoms() {
    final text = _symptomsController.text.toLowerCase();
    final Set<String> newDetected = {};

    _symptomKeywords.forEach((symptom, keywords) {
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          newDetected.add(symptom);
          break; // Found one keyword for this symptom, move to next
        }
      }
    });

    if (!_setEquals(newDetected, _detectedSymptoms)) {
      setState(() {
        _detectedSymptoms.clear();
        _detectedSymptoms.addAll(newDetected);
      });
    }
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  @override
  void dispose() {
    _symptomsController.removeListener(_detectSymptoms);
    _symptomsController.dispose();
    _diagnosisController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text('Visit: ${widget.householdName}'),
        actions: const [
          SyncStatusIndicator(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sync Status Card
              const SyncStatusIndicator(showDetails: true),
              const SizedBox(height: 24),

              // Visit Type
              _buildSectionTitle('Visit Type'),
              const SizedBox(height: 8),
              _buildVisitTypeSelector(isDark),
              const SizedBox(height: 24),

              // Health Status
              _buildSectionTitle('Health Status'),
              const SizedBox(height: 8),
              _buildHealthStatusSelector(isDark),
              const SizedBox(height: 24),

              // Symptoms
              _buildSectionTitle('Symptoms'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _symptomsController,
                hint: 'Describe symptoms observed...',
                maxLines: 3,
                isDark: isDark,
                required: true,
              ),
              if (_detectedSymptoms.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _detectedSymptoms.map((symptom) {
                    return Chip(
                      label: Text(
                        symptom,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor:
                          const Color(0xFF137fec).withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: Color(0xFF137fec),
                        fontWeight: FontWeight.bold,
                      ),
                      padding: const EdgeInsets.all(4),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              // Diagnosis
              _buildSectionTitle('Diagnosis'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _diagnosisController,
                hint: 'Preliminary diagnosis...',
                maxLines: 2,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Treatment
              _buildSectionTitle('Treatment Recommended'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _treatmentController,
                hint: 'Recommended treatment plan...',
                maxLines: 2,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Additional Notes
              _buildSectionTitle('Additional Notes'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _notesController,
                hint: 'Any additional observations...',
                maxLines: 3,
                isDark: isDark,
              ),
              const SizedBox(height: 24),

              // Photos Section
              _buildSectionTitle('Photos (${_photos.length})'),
              const SizedBox(height: 8),
              _buildPhotosSection(isDark),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVisit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF137fec),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Submit Visit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildVisitTypeSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      children: [
        _buildChip('Routine', 'routine', isDark),
        _buildChip('Follow-up', 'followup', isDark),
        _buildChip('Emergency', 'emergency', isDark),
      ],
    );
  }

  Widget _buildHealthStatusSelector(bool isDark) {
    return Wrap(
      spacing: 8,
      children: [
        _buildChip('Stable', 'stable', isDark, isHealthStatus: true),
        _buildChip('Improving', 'improving', isDark, isHealthStatus: true),
        _buildChip('Critical', 'critical', isDark, isHealthStatus: true),
      ],
    );
  }

  Widget _buildChip(String label, String value, bool isDark,
      {bool isHealthStatus = false}) {
    final isSelected =
        isHealthStatus ? _healthStatus == value : _visitType == value;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (isHealthStatus) {
            _healthStatus = value;
          } else {
            _visitType = value;
          }
        });
      },
      selectedColor: const Color(0xFF137fec).withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF137fec) : null,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
    required bool isDark,
    bool required = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark ? const Color(0xFF1C242D) : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      validator: required
          ? (value) => value?.isEmpty ?? true ? 'This field is required' : null
          : null,
    );
  }

  Widget _buildPhotosSection(bool isDark) {
    return Column(
      children: [
        if (_photos.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _photos.asMap().entries.map((entry) {
              return _buildPhotoThumbnail(entry.value, entry.key, isDark);
            }).toList(),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _addPhoto,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add Photo'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoThumbnail(File photo, int index, bool isDark) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            photo,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _addPhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _photos.add(File(image.path));
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing photo: $e')),
      );
    }
  }

  Future<void> _submitVisit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final syncService =
          Provider.of<RealtimeSyncService>(context, listen: false);

      // Prepare form data
      final formData = {
        'visitType': _visitType,
        'healthStatus': _healthStatus,
        'symptoms': _symptomsController.text.trim(),
        'detectedSymptoms': _detectedSymptoms.toList(),
        'diagnosis': _diagnosisController.text.trim(),
        'treatment': _treatmentController.text.trim(),
        'notes': _notesController.text.trim(),
        'visitDate': DateTime.now().toIso8601String(),
      };

      // Upload visit with photos
      final visitId = await syncService.uploadVisitData(
        workerId: widget.workerId,
        householdId: widget.householdId,
        formData: formData,
        photos: _photos.isNotEmpty ? _photos : null,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    'Visit submitted successfully!\nID: ${visitId?.substring(0, 8)}...'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back
      Navigator.pop(context, true);
    } on ConflictException catch (e) {
      if (!mounted) return;
      _showConflictDialog(e);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: ${e.toString()}'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _submitVisit,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showConflictDialog(ConflictException conflict) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('Data Conflict'),
          ],
        ),
        content: Text(
          'This household was updated by another worker.\n\n'
          'Your version: ${conflict.clientVersion}\n'
          'Server version: ${conflict.serverVersion}\n\n'
          'Please refresh and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}


