import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smc/data/services/realtime_sync_service.dart';
import 'package:smc/data/models/visit_record_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smc/core/widgets/sync_status_indicator.dart';
import 'package:smc/core/widgets/permissions_check_step.dart';
import 'package:smc/data/services/offline_service.dart'; // Added Import
import 'dart:async';
import 'dart:io';
import 'dart:math'; // Added Import
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:connectivity_plus/connectivity_plus.dart';

/// New Visit Form Screen
/// Multi-step form for field workers to record households
class NewVisitFormScreen extends StatefulWidget {
  final String fieldWorkerId;
  final String? householdId; // Added

  const NewVisitFormScreen({
    super.key,
    required this.fieldWorkerId,
    this.householdId, // Added
  });

  @override
  State<NewVisitFormScreen> createState() => _NewVisitFormScreenState();
}

class _NewVisitFormScreenState extends State<NewVisitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final _imagePicker = ImagePicker();

  int _currentStep = 0;
  final int _totalSteps = 6;

  // Form data
  String _householdId = '';

  @override
  void initState() {
    super.initState();
    if (widget.householdId != null) {
      _householdId = widget.householdId!;
    }
    _initializeSmartDefaults();
    _getCurrentLocation();
  }

  String _address = '';
  String _visitType = 'routine';
  final List<HouseholdMember> _members = [];
  final TextEditingController _notesController = TextEditingController();
  final List<File> _photos = [];

  // Location data
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;
  String _locationStatus = 'Waiting to capture...';

  bool _isSaving = false;

  final List<String> _visitTypes = ['routine', 'follow_up', 'emergency'];

  void _initializeSmartDefaults() {
    // Smart Default: Pre-fill context based on season
    final month = DateTime.now().month;
    if (month >= 3 && month <= 5) {
      _notesController.text =
          "Heat Season Check:\n- Hydration status: \n- Cooling methods: \n";
    } else if (month >= 6 && month <= 9) {
      _notesController.text =
          "Monsoon Check:\n- Stagnant water: \n- Mosquito breeding: \n";
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationStatus = 'Getting GPS location...';
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _locationStatus = 'Location services disabled';
            _isGettingLocation = false;
          });
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationStatus = 'Location captured';
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _locationStatus = 'Error getting location';
          _isGettingLocation = false;
        });
      }
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveVisit() async {
    if (!_formKey.currentState!.validate()) return;

    // Check internet connection
    var connectivityResult = await (Connectivity().checkConnectivity());
    final isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    setState(() => _isSaving = true);

    try {
      final visitData = VisitRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fieldWorkerId: widget.fieldWorkerId,
        householdId: _householdId,
        address: _address,
        latitude: _latitude ?? 0.0,
        longitude: _longitude ?? 0.0,
        visitDate: DateTime.now(),
        visitType: _visitType,
        membersScreened: _members.map((m) => m.toMap()).toList(),
        findings: {}, // Add findings if needed
        photoUrls: [], // Photos handled separately via upload but model needs it
        notes: _notesController.text,
        status: isOnline ? 'submitted' : 'pending_sync',
      );

      if (isOnline) {
        // ONLINE: Upload directly
        final syncService =
            Provider.of<RealtimeSyncService>(context, listen: false);

        // Convert to map for sync service (or update sync service to accept model)
        // Using existing uploadVisitData which accepts Map
        final visitId = await syncService.uploadVisitData(
          workerId: widget.fieldWorkerId,
          householdId: _householdId,
          formData: visitData.toMap(),
          photos: _photos.isNotEmpty ? _photos : null,
        );

        if (mounted) {
          _showSuccessSnackBar('✅ Visit submitted!', visitId);
        }
      } else {
        // OFFLINE: Queue locally
        final offlineService = OfflineService(); // Should ideally be injected
        await offlineService.init(); // Ensure initialized

        // Handle Photos for Offline
        if (_photos.isNotEmpty) {
          try {
            final appDir = await getApplicationDocumentsDirectory();
            final offlinePhotosDir = Directory('${appDir.path}/offline_photos');
            if (!await offlinePhotosDir.exists()) {
              await offlinePhotosDir.create(recursive: true);
            }

            List<String> localPhotoPaths = [];
            for (var photo in _photos) {
              final fileName =
                  'offline_${DateTime.now().millisecondsSinceEpoch}_${p.basename(photo.path)}';
              final savedImage =
                  await photo.copy('${offlinePhotosDir.path}/$fileName');
              localPhotoPaths.add(savedImage.path);
            }

            // Update visitData with local paths
            // We create a new Map/Object because VisitRecord fields are final
            final offlineVisitData = VisitRecord(
              id: visitData.id,
              fieldWorkerId: visitData.fieldWorkerId,
              householdId: visitData.householdId,
              address: visitData.address,
              latitude: visitData.latitude,
              longitude: visitData.longitude,
              visitDate: visitData.visitDate,
              visitType: visitData.visitType,
              membersScreened: visitData.membersScreened,
              findings: visitData.findings,
              photoUrls: localPhotoPaths, // Store local paths
              notes: visitData.notes,
              status: 'pending_sync',
            );

            await offlineService.queueVisitRecord(offlineVisitData);
          } catch (e) {
            debugPrint("Error saving offline photos: $e");
            // Proceed without photos or handle error
            await offlineService.queueVisitRecord(visitData);
          }
        } else {
          await offlineService.queueVisitRecord(visitData);
        }

        if (mounted) {
          _showSuccessSnackBar(
              '💾 Saved to Offline Queue', 'Will sync when online');
        }
      }

      if (mounted) Navigator.pop(context, true);
    } on ConflictException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Conflict: ${e.message}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving visit: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _saveVisit,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSuccessSnackBar(String message, String? id) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '$message\n${id != null ? "ID: ${id.substring(0, min(8, id.length))}..." : ""}',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('New Household Visit'),
        actions: const [
          SyncStatusIndicator(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: Colors.grey[800],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF137fec)),
          ),
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1HouseholdInfo(),
                  _buildStep2VisitType(),
                  _buildStep3Members(),
                  _buildStep4Photos(),
                  _buildStep5Notes(),
                  _buildStep6PermissionsCheck(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border:
            Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                child: const Text('Previous'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _currentStep < _totalSteps - 1
                  ? _nextStep
                  : (_isSaving ? null : () => _saveVisit()),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_currentStep < _totalSteps - 1 ? 'Next' : 'Submit'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1HouseholdInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HOUSEHOLD IDENTIFICATION',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey)),
          const SizedBox(height: 24),
          TextFormField(
            initialValue: _householdId,
            onChanged: (v) => _householdId = v,
            decoration: const InputDecoration(
                labelText: 'Household ID', hintText: 'HH-XXXXX'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          TextFormField(
            initialValue: _address,
            onChanged: (v) => _address = v,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Full Address'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 32),
          _buildLocationPreview(),
        ],
      ),
    );
  }

  Widget _buildLocationPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF137fec).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF137fec).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF137fec)),
          const SizedBox(width: 12),
          Expanded(
              child:
                  Text(_locationStatus, style: const TextStyle(fontSize: 12))),
          if (_isGettingLocation)
            const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: _getCurrentLocation),
        ],
      ),
    );
  }

  Widget _buildStep2VisitType() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('VISIT CLASSIFICATION',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 24),
        RadioGroup<String>(
          groupValue: _visitType,
          onChanged: (v) => setState(() => _visitType = v!),
          child: Column(
            children: _visitTypes
                .map((type) => RadioListTile<String>(
                      title: Text(type.toUpperCase()),
                      subtitle: Text(_getVisitTypeDescription(type)),
                      value: type,
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  String _getVisitTypeDescription(String type) {
    switch (type) {
      case 'routine':
        return 'Scheduled quarterly screening';
      case 'follow_up':
        return 'Monitoring previously identified risks';
      case 'emergency':
        return 'Response to symptomatic report';
      default:
        return '';
    }
  }

  Widget _buildStep3Members() {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SCREENED MEMBERS',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.grey)),
                TextButton.icon(
                    onPressed: _addMember,
                    icon: const Icon(Icons.add),
                    label: const Text('Add')),
              ],
            ),
          ),
          Expanded(
            child: _members.isEmpty
                ? const Center(
                    child: Text('No members added yet',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _members.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: CircleAvatar(child: Text(_members[i].name[0])),
                      title: Text(_members[i].name),
                      subtitle:
                          Text('${_members[i].age}y • ${_members[i].gender}'),
                      trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () =>
                              setState(() => _members.removeAt(i))),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _addMember() {
    // Basic dialog for adding member
    showDialog(
      context: context,
      builder: (context) {
        String name = '';
        int age = 0;
        return AlertDialog(
          title: const Text('Add Household Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  onChanged: (v) => name = v,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  onChanged: (v) => age = int.tryParse(v) ?? 0,
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() => _members.add(HouseholdMember(
                    id: DateTime.now().toString(),
                    name: name,
                    age: age,
                    gender: 'Other',
                    relation: 'Member')));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep4Photos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('PHOTO DOCUMENTATION',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            'Capture photos of living conditions, health concerns, or documentation',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          if (_photos.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _photos.asMap().entries.map((entry) {
                return _buildPhotoThumbnail(entry.value, entry.key);
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(
            onPressed: _capturePhoto,
            icon: const Icon(Icons.add_a_photo),
            label: Text(
                _photos.isEmpty ? 'Add Photos (Optional)' : 'Add More Photos'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_photos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_photos.length} photo(s) will be compressed and uploaded',
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
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

  Widget _buildPhotoThumbnail(File photo, int index) {
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

  Future<void> _capturePhoto() async {
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

  Widget _buildStep5Notes() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('FINAL OBSERVATIONS',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.grey)),
          const SizedBox(height: 24),
          TextFormField(
            controller: _notesController,
            maxLines: 10,
            decoration: const InputDecoration(
              hintText:
                  'Describe general living conditions, observed symptoms, or critical needs...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6PermissionsCheck() {
    return PermissionsCheckStep(
      onAllGranted: () {
        // Auto-proceed when all permissions granted
        // User can still manually submit
      },
    );
  }
}


