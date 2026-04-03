import 'package:flutter/material.dart';
import 'package:smc/core/widgets/smc_back_button.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/visit_record_model.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/utils/solapur_location_utils.dart';
import 'package:smc/core/ui/hand_drawn_illustration.dart';
import 'package:smc/core/ui/milestone_tracker.dart';

/// Field Worker Visits Screen
/// Displays a history of visits performed by the field worker
class FieldWorkerVisitsScreen extends StatefulWidget {
  final String fieldWorkerId;

  const FieldWorkerVisitsScreen({super.key, required this.fieldWorkerId});

  @override
  State<FieldWorkerVisitsScreen> createState() =>
      _FieldWorkerVisitsScreenState();
}

class _FieldWorkerVisitsScreenState extends State<FieldWorkerVisitsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = true;
  List<VisitRecord> _visits = [];

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    setState(() => _isLoading = true);

    try {
      final data = await _firestoreService.queryCollection(
        collection: 'visit_records',
        field: 'fieldWorkerId',
        value: widget.fieldWorkerId,
      );

      if (mounted) {
        setState(() {
          _visits = data
              .map((d) => VisitRecord.fromMap(d, (d['id'] ?? '') as String))
              .toList();
          // Sort manually by date descending
          _visits.sort((a, b) => b.visitDate.compareTo(a.visitDate));
          _isLoading = false;
        });

        // Celebrate milestones
        // Using a slight delay to ensure UI is ready and it feels like a reaction to loading
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _visits.isNotEmpty) {
            // Only celebrate specific counts to avoid annoyance on every load
            // For demo purposes, we might trigger it more often or check shared prefs
            // Here we just pass the count, the tracker handles specific numbers
            MilestoneTracker.checkAndCelebrate(context, _visits.length);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading visits: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: const Text('My Visits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadVisits,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _visits.isEmpty
              ? _buildEmptyState()
              : _buildVisitsList(isDark),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.fieldWorkerNewVisit,
            arguments: {'fieldWorkerId': widget.fieldWorkerId},
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
        backgroundColor: const Color(0xFF137fec),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomIllustration(type: 'no_visits', size: 200),
          const SizedBox(height: 16),
          Text(
            'No visits recorded yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitsList(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _visits.length,
      itemBuilder: (context, index) {
        final visit = _visits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
            ),
          ),
          color: isDark ? const Color(0xFF1C242D) : Colors.white,
          child: ExpansionTile(
            leading: _buildVisitTypeIcon(visit.visitType),
            title: Text(
              visit.householdId,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${visit.visitDate.toString().split(' ')[0]} • ${visit.status.toUpperCase()}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        Icons.location_on_outlined,
                        'Address',
                        visit.latitude != 0.0
                            ? SolapurLocationUtils.getHumanReadableLocation(
                                    visit.latitude, visit.longitude)
                                .replaceAll('\n', ', ')
                            : visit.address),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.people_outline, 'Members',
                        '${visit.membersScreened.length} screened'),
                    const SizedBox(height: 8),
                    _buildDetailRow(Icons.notes_outlined, 'Notes',
                        visit.notes.isEmpty ? 'No notes' : visit.notes),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _deleteVisit(visit),
                        icon: const Icon(Icons.delete_outline,
                            size: 20, color: Colors.red),
                        label: const Text('Delete Record',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteVisit(VisitRecord visit) {
    final index = _visits.indexOf(visit);
    setState(() {
      _visits.remove(visit);
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            content: Text('Visit for ${visit.householdId} removed'),
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _visits.insert(index, visit);
                });
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        // Actually delete from server if not undone
        _firestoreService.deleteDocument(
          collection: 'visit_records',
          docId: visit.id,
        );
      }
    });
  }

  Widget _buildVisitTypeIcon(String type) {
    // ... (rest of the code remains the same)
    IconData icon;
    Color color;

    switch (type) {
      case 'emergency':
        icon = Icons.error_outline;
        color = Colors.red;
        break;
      case 'follow_up':
        icon = Icons.update;
        color = Colors.orange;
        break;
      default:
        icon = Icons.check_circle_outline;
        color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              children: [
                TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                    text: value,
                    style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white70
                            : Colors.black87)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
