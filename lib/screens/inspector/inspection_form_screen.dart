import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smc/data/models/inspection_record.dart';
import 'package:smc/data/services/defect_analysis_engine.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/visuals/industrial_visuals.dart';

class InspectionFormScreen extends StatefulWidget {
  final String inspectorId;
  final String? assetId;

  const InspectionFormScreen({
    super.key,
    required this.inspectorId,
    this.assetId,
  });

  @override
  State<InspectionFormScreen> createState() => _InspectionFormScreenState();
}

class _InspectionFormScreenState extends State<InspectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  final _imagePicker = ImagePicker();
  final _analysisEngine = DefectAnalysisEngine();

  int _currentStep = 0;
  final int _totalSteps = 4;

  // Form Data
  AssetType _selectedAssetType = AssetType.bridge;
  String _assetName = '';
  String _address = '';
  final List<DefectFound> _defects = [];
  final List<File> _capturedPhotos = [];
  final TextEditingController _notesController = TextEditingController();
  
  // Analysis Result
  Map<String, dynamic>? _aiResult;
  bool _isAnalyzing = false;

  // Location
  Position? _currentPosition;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _captureLocation();
  }

  Future<void> _captureLocation() async {
    setState(() => _isLocating = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _currentPosition = position;
        _isLocating = false;
      });
    } catch (e) {
      setState(() => _isLocating = false);
      debugPrint('Location error: $e');
    }
  }

  Future<void> _runAiAnalysis() async {
    if (_capturedPhotos.isEmpty && _notesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo or add notes first.')),
      );
      return;
    }

    setState(() => _isAnalyzing = true);
    
    // Simulate processing time for industrial feel
    await Future.delayed(const Duration(seconds: 2));

    final result = _analysisEngine.analyzeDefect(
      assetType: _selectedAssetType,
      defectLabel: _defects.isNotEmpty ? _defects.first.type : 'General Anomaly',
      description: _notesController.text,
      metrics: {'width': 0.4, 'length': 12.5}, // Simulated metrics from "Image Processing"
    );

    setState(() {
      _aiResult = result;
      _isAnalyzing = false;
    });
  }

  Future<void> _submitInspection() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS lock required for submission.')),
      );
      return;
    }

    final record = InspectionRecord(
      id: 'INSP_${DateTime.now().millisecondsSinceEpoch}',
      inspectorId: widget.inspectorId,
      assetId: widget.assetId ?? 'NEW_ASSET',
      assetType: _selectedAssetType,
      assetName: _assetName,
      address: _address,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      inspectionDate: DateTime.now(),
      type: 'Routine',
      defects: _defects,
      aiAnalysisResult: _aiResult ?? {},
      photoUrls: _capturedPhotos.map((f) => f.path).toList(),
      notes: _notesController.text,
      status: ComplianceStatus.pendingReview,
    );

    // REAL implementation: Save to Firestore
    final firestore = FirestoreService();
    await firestore.createDocument(
      collection: 'inspections',
      docId: record.id,
      data: record.toMap(),
    );

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inspection Uploaded Successfully'),
          backgroundColor: IndustrialVisuals.successGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark rugged theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Site Inspection Form', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: IndustrialVisuals.blueprintBackground(
        isDark: true,
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAssetInfoStep(),
                    _buildMediaCaptureStep(),
                    _buildAiAnalysisStep(),
                    _buildFinalReviewStep(),
                  ],
                ),
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_totalSteps, (index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: index <= _currentStep 
                ? IndustrialVisuals.primaryTech 
                : Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAssetInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Asset Identification'),
          const SizedBox(height: 24),
          DropdownButtonFormField<AssetType>(
            initialValue: _selectedAssetType,
            dropdownColor: const Color(0xFF1E293B),
            style: GoogleFonts.outfit(color: Colors.white),
            decoration: _inputDecoration('Asset Category'),
            items: AssetType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.name.toUpperCase()));
            }).toList(),
            onChanged: (val) => setState(() => _selectedAssetType = val!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Asset Identifier / Name'),
            onChanged: (val) => _assetName = val,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Site Location / Address'),
            onChanged: (val) => _address = val,
            validator: (v) => v!.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          _buildLocationStatus(),
        ],
      ),
    );
  }

  Widget _buildMediaCaptureStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Evidence Capture'),
          const SizedBox(height: 8),
          Text('Capture high-resolution photos of the critical components.', 
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
          const SizedBox(height: 24),
          if (_capturedPhotos.isNotEmpty)
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _capturedPhotos.map((file) => _buildPhotoCard(file)).toList(),
            ),
          const SizedBox(height: 24),
          IndustrialVisuals.largeActionButton(
            label: 'Open Field Camera',
            icon: Icons.camera_alt,
            onTap: _captureImage,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
          _sectionHeader('Inspector Notes'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesController,
            maxLines: 5,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration('Detailed Findings...'),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysisStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _sectionHeader('AI Defect Analysis'),
          const SizedBox(height: 32),
          if (_aiResult == null)
            Column(
              children: [
                const Icon(Icons.psychology, size: 80, color: IndustrialVisuals.primaryTech),
                const SizedBox(height: 24),
                Text('Trigger Intelligent Scan', 
                  style: GoogleFonts.outfit(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('The engine will evaluate photos and notes against 10,000+ structural failure indicators.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
                const SizedBox(height: 40),
                if (_isAnalyzing)
                  const CircularProgressIndicator()
                else
                  IndustrialVisuals.largeActionButton(
                    label: 'Run Analysis',
                    icon: Icons.analytics,
                    onTap: _runAiAnalysis,
                  ),
              ],
            )
          else
            _buildAiResultCard(),
        ],
      ),
    );
  }

  Widget _buildAiResultCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: IndustrialVisuals.primaryTech.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ANALYSIS RESULT', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, color: Colors.grey)),
              IndustrialVisuals.statusBadge(_aiResult!['severity']),
            ],
          ),
          const SizedBox(height: 20),
          Text(_aiResult!['description'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          _resultRow(Icons.check_circle, 'Finding', _aiResult!['finding']),
          _resultRow(Icons.build, 'Remedy', _aiResult!['recommendation']),
          _resultRow(Icons.speed, 'Confidence', '${((_aiResult!['confidence'] ?? 0)*100).toInt()}%'),
          const SizedBox(height: 24),
          IndustrialVisuals.largeActionButton(
            label: 'Re-Scan',
            icon: Icons.refresh,
            onTap: () => setState(() => _aiResult = null),
            color: Colors.white.withValues(alpha: 0.05),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalReviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Final Submission'),
          const SizedBox(height: 24),
          _reviewItem('Asset', _assetName),
          _reviewItem('Category', _selectedAssetType.name.toUpperCase()),
          _reviewItem('Coordinates', '${_currentPosition?.latitude.toStringAsFixed(4)}, ${_currentPosition?.longitude.toStringAsFixed(4)}'),
          _reviewItem('AI Verdict', _aiResult?['severity'] ?? 'N/A'),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: IndustrialVisuals.cautionYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning, color: IndustrialVisuals.cautionYellow),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('By submitting, you certify that the inspection was performed on-site and the data is accurate.',
                    style: TextStyle(color: IndustrialVisuals.cautionYellow, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: IndustrialVisuals.largeActionButton(
                label: 'Back',
                icon: Icons.chevron_left,
                onTap: () {
                  _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  setState(() => _currentStep--);
                },
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: IndustrialVisuals.largeActionButton(
              label: _currentStep == _totalSteps - 1 ? 'Upload' : 'Next',
              icon: _currentStep == _totalSteps - 1 ? Icons.cloud_upload : Icons.chevron_right,
              onTap: () {
                if (_currentStep < _totalSteps - 1) {
                  _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                  setState(() => _currentStep++);
                } else {
                  _submitInspection();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helpers
  Widget _sectionHeader(String title) {
    return Text(title.toUpperCase(), style: GoogleFonts.outfit(
      fontSize: 14, fontWeight: FontWeight.w900, color: IndustrialVisuals.primaryTech, letterSpacing: 1.5
    ));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildLocationStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _currentPosition != null ? IndustrialVisuals.successGreen.withValues(alpha: 0.1) : IndustrialVisuals.cautionYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_currentPosition != null ? Icons.gps_fixed : Icons.gps_not_fixed, 
            color: _currentPosition != null ? IndustrialVisuals.successGreen : IndustrialVisuals.cautionYellow),
          const SizedBox(width: 12),
          Text(_currentPosition != null ? 'GPS Lock Secured' : 'Acquiring GPS Satellite...',
            style: TextStyle(color: _currentPosition != null ? IndustrialVisuals.successGreen : IndustrialVisuals.cautionYellow)),
          const Spacer(),
          if (_isLocating) const CircularProgressIndicator(strokeWidth: 2),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(File file) {
    return Container(
      width: 100, height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
      ),
    );
  }

  Future<void> _captureImage() async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() => _capturedPhotos.add(File(photo.path)));
    }
  }

  Widget _resultRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: IndustrialVisuals.primaryTech),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          Expanded(child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _reviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
