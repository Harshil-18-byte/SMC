import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/data/services/realtime_sync_service.dart';
import 'package:smc/core/widgets/sync_status_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// Example: Field Worker Visit Form with Real-Time Sync
/// This shows how to integrate the sync service into your existing screens
class FieldWorkerVisitFormExample extends StatefulWidget {
  final String workerId;
  final String householdId;

  const FieldWorkerVisitFormExample({
    super.key,
    required this.workerId,
    required this.householdId,
  });

  @override
  State<FieldWorkerVisitFormExample> createState() =>
      _FieldWorkerVisitFormExampleState();
}

class _FieldWorkerVisitFormExampleState
    extends State<FieldWorkerVisitFormExample> {
  final _formKey = GlobalKey<FormState>();
  final List<File> _capturedPhotos = [];
  bool _isSubmitting = false;

  // Form fields
  String _symptoms = '';
  String _diagnosis = '';
  String _repairAction = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Visit'),
        actions: const [
          // Show sync status in AppBar
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
              // Sync status card
              const SyncStatusIndicator(showDetails: true),
              const SizedBox(height: 24),

              // Form fields
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Symptoms',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _symptoms = value ?? '',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Diagnosis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (value) => _diagnosis = value ?? '',
              ),
              const SizedBox(height: 16),

              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Repair Action Recommended',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onSaved: (value) => _repairAction = value ?? '',
              ),
              const SizedBox(height: 24),

              // Photo section
              Text(
                'Photos (${_capturedPhotos.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._capturedPhotos
                      .map((photo) => _buildPhotoThumbnail(photo)),
                  _buildAddPhotoButton(),
                ],
              ),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitVisit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Visit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoThumbnail(File photo) {
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
            onTap: () {
              setState(() => _capturedPhotos.remove(photo));
            },
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

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, color: Colors.grey),
            SizedBox(height: 4),
            Text('Add Photo', style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _addPhoto() async {
    final picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedPhotos.add(File(image.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _submitVisit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => _isSubmitting = true);

    try {
      // Get sync service
      final syncService =
          Provider.of<RealtimeSyncService>(context, listen: false);

      // Prepare form data
      final formData = {
        'symptoms': _symptoms,
        'diagnosis': _diagnosis,
        'repair_action': _repairAction,
        'visitDate': DateTime.now().toIso8601String(),
      };

      // Upload visit with photos
      final visitId = await syncService.uploadVisitData(
        workerId: widget.workerId,
        householdId: widget.householdId,
        formData: formData,
        photos: _capturedPhotos.isNotEmpty ? _capturedPhotos : null,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Visit uploaded successfully! ID: $visitId'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } on ConflictException catch (e) {
      // Handle conflict
      if (!mounted) return;
      _showConflictDialog(e);
    } catch (e) {
      // Handle other errors
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
        title: const Text('Data Conflict'),
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
              // In a real app, you would fetch the latest document version here
              // to update your local version tracker.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Data refreshed. You can now retry.')),
              );
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

/// Example: Real-Time Household Data Viewer
/// Shows how to listen to real-time updates
class HouseholdDataViewer extends StatelessWidget {
  final String householdId;

  const HouseholdDataViewer({super.key, required this.householdId});

  @override
  Widget build(BuildContext context) {
    final syncService = Provider.of<RealtimeSyncService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Household Data'),
        actions: const [
          SyncStatusIndicator(compact: true),
          SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder(
        stream: syncService.watchHousehold(householdId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text('Household not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Household ID: $householdId',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Last Visit: ${data['lastVisitDate'] ?? 'Never'}'),
                      Text('Visit Count: ${data['visitCount'] ?? 0}'),
                      Text('Last Visit By: ${data['lastVisitBy'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Recent Visits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              _buildRecentVisits(context, householdId),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentVisits(BuildContext context, String householdId) {
    final syncService = Provider.of<RealtimeSyncService>(context);

    return StreamBuilder(
      stream: syncService.watchWorkerVisits('current_worker_id'),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final visits = snapshot.data!.docs;

        if (visits.isEmpty) {
          return const Text('No visits yet');
        }

        return Column(
          children: visits.map((visit) {
            final data = visit.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text(data['symptoms'] ?? 'No symptoms'),
                subtitle: Text(data['visitDate'] ?? ''),
                trailing: Text('v${data['version'] ?? 1}'),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}


