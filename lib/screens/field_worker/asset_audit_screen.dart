import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smc/data/services/realtime_sync_service.dart';
import 'package:smc/core/widgets/sync_status_indicator.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

/// Asset Audit Form Screen
/// Professional field tool for capturing asset integrity data, evidence photos, and real-time synchronization.
class AssetAuditScreen extends StatefulWidget {
  final String inspectorId;
  final String assetId;
  final String assetName;

  const AssetAuditScreen({
    super.key,
    required this.inspectorId,
    required this.assetId,
    required this.assetName,
  });

  @override
  State<AssetAuditScreen> createState() => _AssetAuditScreenState();
}

class _AssetAuditScreenState extends State<AssetAuditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  final List<File> _evidencePhotos = [];
  bool _isSubmitting = false;

  final _observationsController = TextEditingController();
  final _rootCauseController = TextEditingController();
  final _remediationController = TextEditingController();
  final _technicalNotesController = TextEditingController();

  String _auditType = 'routine';
  String _integrityStatus = 'stable';

  final Set<String> _detectedDefects = {};
  final Map<String, List<String>> _defectKeywords = {
    'Structural Crack': ['crack', 'fissure', 'fracture', 'splitting'],
    'Corrosion / Rust': ['rust', 'corrosion', 'oxidation', 'exposed rebar'],
    'Fluid Leakage': ['leak', 'seepage', 'water', 'moisture', 'drip'],
    'Settlement': ['tilt', 'sinking', 'subsidence', 'foundation'],
    'Mechanical Wear': ['friction', 'noise', 'grinding', 'loose bolt'],
    'Electrical Hazard': ['exposed wire', 'spark', 'short circuit', 'voltage'],
  };

  @override
  void initState() {
    super.initState();
    _observationsController.addListener(_detectDefects);
  }

  void _detectDefects() {
    final text = _observationsController.text.toLowerCase();
    final Set<String> newDetected = {};
    _defectKeywords.forEach((defect, keywords) {
      for (final keyword in keywords) {
        if (text.contains(keyword)) {
          newDetected.add(defect);
          break;
        }
      }
    });
    if (!_setEquals(newDetected, _detectedDefects)) {
      setState(() {
        _detectedDefects.clear();
        _detectedDefects.addAll(newDetected);
      });
    }
  }

  bool _setEquals(Set<String> a, Set<String> b) {
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  @override
  void dispose() {
    _observationsController.removeListener(_detectDefects);
    _observationsController.dispose();
    _rootCauseController.dispose();
    _remediationController.dispose();
    _technicalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('AUDIT: ${widget.assetName}', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: const [
          SyncStatusIndicator(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('AUDIT CLASSIFICATION'),
                const SizedBox(height: 12),
                _buildAuditTypeSelector(),
                const SizedBox(height: 24),

                _buildSectionHeader('STRUCTURAL INTEGRITY'),
                const SizedBox(height: 12),
                _buildStatusSelector(),
                const SizedBox(height: 24),

                _buildSectionHeader('FIELD OBSERVATIONS'),
                _buildTextField(_observationsController, 'Describe discovered anomalies...', 3, required: true),
                if (_detectedDefects.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _detectedDefects.map((defect) => Chip(
                      label: Text(defect, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(color: Colors.redAccent),
                      side: const BorderSide(color: Colors.redAccent),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 24),

                _buildSectionHeader('ROOT CAUSE ANALYSIS'),
                _buildTextField(_rootCauseController, 'Potential origin of defect...', 2),
                const SizedBox(height: 24),

                _buildSectionHeader('REMEDIATION PLAN'),
                _buildTextField(_remediationController, 'Required engineering action...', 2),
                const SizedBox(height: 24),

                _buildSectionHeader('EVIDENCE CAPTURE (${_evidencePhotos.length})'),
                _buildPhotosSection(),
                const SizedBox(height: 40),

                IndustrialVisuals.largeActionButton(
                  label: 'SUBMIT AUDIT LOG',
                  icon: Icons.assignment_turned_in_rounded,
                  onTap: _isSubmitting ? () {} : _submitAudit,
                  color: Colors.blue,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuditTypeSelector() {
    return Wrap(
      spacing: 8,
      children: ['routine', 'followup', 'emergency'].map((type) => ChoiceChip(
        label: Text(type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        selected: _auditType == type,
        onSelected: (val) => setState(() => _auditType = type),
        selectedColor: Colors.blue.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: _auditType == type ? Colors.blue : Colors.grey),
      )).toList(),
    );
  }

  Widget _buildStatusSelector() {
    return Wrap(
      spacing: 8,
      children: ['stable', 'degrading', 'critical'].map((status) => ChoiceChip(
        label: Text(status.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
        selected: _integrityStatus == status,
        onSelected: (val) => setState(() => _integrityStatus = status),
        selectedColor: status == 'critical' ? Colors.red.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
        labelStyle: TextStyle(color: _integrityStatus == status ? (status == 'critical' ? Colors.red : Colors.blue) : Colors.grey),
      )).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, int lines, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        maxLines: lines,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: required ? (v) => v?.isEmpty ?? true ? 'Required field' : null : null,
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      children: [
        if (_evidencePhotos.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _evidencePhotos.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_evidencePhotos[i], width: 100, height: 100, fit: BoxFit.cover),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _addPhoto,
          icon: const Icon(Icons.camera_alt_rounded),
          label: const Text('CAPTURE EVIDENCE'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _addPhoto() async {
    final XFile? img = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (img != null) setState(() => _evidencePhotos.add(File(img.path)));
  }

  Future<void> _submitAudit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final sync = Provider.of<RealtimeSyncService>(context, listen: false);
      final data = {
        'auditType': _auditType,
        'integrityStatus': _integrityStatus,
        'observations': _observationsController.text.trim(),
        'detectedDefects': _detectedDefects.toList(),
        'rootCause': _rootCauseController.text.trim(),
        'remediation': _remediationController.text.trim(),
        'auditDate': DateTime.now().toIso8601String(),
      };
      await sync.uploadVisitData(
        workerId: widget.inspectorId,
        householdId: widget.assetId,
        formData: data,
        photos: _evidencePhotos.isNotEmpty ? _evidencePhotos : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ AUDIT SUBMITTED')));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload Error: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.blue, letterSpacing: 1.5));
  }
}
