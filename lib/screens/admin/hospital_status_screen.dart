import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/data/models/command_center_models.dart';

/// Hospital Status & Capacity Screen
/// Detailed view with bed availability, oxygen, triage wait times
/// Includes "Lock Intake" and "Route Referrals" actions
class HospitalStatusScreen extends StatefulWidget {
  const HospitalStatusScreen({super.key});

  @override
  State<HospitalStatusScreen> createState() => _HospitalStatusScreenState();
}

class _HospitalStatusScreenState extends State<HospitalStatusScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  List<HospitalIntakeStatus> _hospitals = [];

  @override
  void initState() {
    super.initState();
    _loadHospitals();
  }

  Future<void> _loadHospitals() async {
    setState(() => _isLoading = true);

    try {
      final hospitalsData = await _firestoreService.getCollection(
        collection: 'hospital_intake_status',
        orderBy: 'name',
      );
      _hospitals = hospitalsData
          .map((data) => HospitalIntakeStatus.fromMap(data, data['id']))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading hospitals: $e')));
      }
    }
  }

  void _showLockIntakeDialog(HospitalIntakeStatus hospital) {
    showDialog(
      context: context,
      builder: (context) => IntakeLockJustificationDialog(
        hospital: hospital,
        onConfirm: (reason, note) async {
          await _lockIntake(hospital, reason, note);
        },
      ),
    );
  }

  Future<void> _lockIntake(
    HospitalIntakeStatus hospital,
    String reason,
    String note,
  ) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'hospital_intake_status',
        docId: hospital.id,
        data: {'intakeLocked': true, 'lockReason': '$reason: $note'},
      );

      // Log the action
      await _firestoreService.createDocument(
        collection: 'audit_logs',
        data: {
          'action': 'INTAKE_LOCKED',
          'hospitalId': hospital.id,
          'hospitalName': hospital.name,
          'reason': reason,
          'note': note,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      await _loadHospitals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Intake locked successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(0xFFFF4D4D),
          ),
        );
      }
    }
  }

  Future<void> _unlockIntake(HospitalIntakeStatus hospital) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'hospital_intake_status',
        docId: hospital.id,
        data: {'intakeLocked': false, 'lockReason': null},
      );

      await _loadHospitals();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Intake unlocked'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _routeReferrals(HospitalIntakeStatus hospital) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Routing referrals from ${hospital.name}...'),
        backgroundColor: const Color(0xFF137fec),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        title: Text(
          AppLocalizations.of(context).hospitalStatus,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHospitals,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadHospitals,
              child: _hospitals.isEmpty
                  ? Center(
                      child: Text(
                        'No hospitals found',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _hospitals.length,
                      itemBuilder: (context, index) {
                        return _buildHospitalCard(_hospitals[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildHospitalCard(HospitalIntakeStatus hospital) {
    final canLock =
        hospital.bedOccupancyPercentage > 75 || hospital.oxygenLevel < 30;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2733),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hospital.intakeLocked
              ? const Color(0xFFFF4D4D)
              : const Color(0xFF2D3748),
          width: hospital.intakeLocked ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Facility ID: ${hospital.id}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hospital.statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hospital.statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: hospital.statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Bed Availability',
                  '${hospital.bedAvailable}/${hospital.bedTotal}',
                  '${hospital.bedOccupancyPercentage.toStringAsFixed(0)}% occupied',
                  Icons.bed,
                  hospital.bedOccupancyPercentage > 90
                      ? const Color(0xFFFF4D4D)
                      : hospital.bedOccupancyPercentage > 75
                          ? const Color(0xFFFFAB00)
                          : const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Oxygen Level',
                  '${hospital.oxygenLevel}%',
                  hospital.oxygenLevel < 30 ? 'Critical' : 'Normal',
                  Icons.air,
                  hospital.oxygenLevel < 30
                      ? const Color(0xFFFF4D4D)
                      : hospital.oxygenLevel < 50
                          ? const Color(0xFFFFAB00)
                          : const Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMetricCard(
            'Triage Wait Time',
            '${hospital.triageWaitMinutes} minutes',
            hospital.triageWaitMinutes > 45 ? 'High wait' : 'Acceptable',
            Icons.timer,
            hospital.triageWaitMinutes > 45
                ? const Color(0xFFFFAB00)
                : const Color(0xFF10B981),
          ),

          // Lock Warning
          if (hospital.intakeLocked) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D4D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFF4D4D)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock, color: Color(0xFFFF4D4D), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'INTAKE LOCKED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF4D4D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          hospital.lockReason ?? 'No reason provided',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action Buttons
          const SizedBox(height: 16),
          Row(
            children: [
              if (!hospital.intakeLocked && canLock)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showLockIntakeDialog(hospital),
                    icon: const Icon(Icons.lock, size: 18),
                    label: const Text('Lock Intake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D4D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (hospital.intakeLocked)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _unlockIntake(hospital),
                    icon: const Icon(Icons.lock_open, size: 18),
                    label: const Text('Unlock Intake'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              if (canLock) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _routeReferrals(hospital),
                    icon: const Icon(Icons.route, size: 18),
                    label: const Text('Route Referrals'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF137fec),
                      side: const BorderSide(color: Color(0xFF137fec)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF101922),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2D3748)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

/// Intake Lock Justification Dialog
class IntakeLockJustificationDialog extends StatefulWidget {
  final HospitalIntakeStatus hospital;
  final Function(String reason, String note) onConfirm;

  const IntakeLockJustificationDialog({
    super.key,
    required this.hospital,
    required this.onConfirm,
  });

  @override
  State<IntakeLockJustificationDialog> createState() =>
      _IntakeLockJustificationDialogState();
}

class _IntakeLockJustificationDialogState
    extends State<IntakeLockJustificationDialog> {
  String _selectedReason = 'Staff Shortage';
  final _noteController = TextEditingController();

  final List<String> _reasons = [
    'Staff Shortage',
    'Equipment Failure',
    'Oxygen Shortage',
    'Bed Capacity Full',
    'Emergency Situation',
    'Other',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1B2733),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Color(0xFFFF4D4D), size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Lock Intake Justification',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.hospital.name,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFAB00).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFAB00)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Color(0xFFFFAB00), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This action will be logged and audited',
                      style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Reason for Lock',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (value) => setState(() => _selectedReason = value!),
              child: Column(
                children: _reasons
                    .map(
                      (reason) => RadioListTile<String>(
                        value: reason,
                        title: Text(
                          reason,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                        ),
                        activeColor: const Color(0xFF137fec),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Admin Note (Required)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter detailed justification...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF101922),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D3748)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF2D3748)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF137fec)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[400],
                      side: BorderSide(color: Colors.grey[700]!),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_noteController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Admin note is required'),
                            backgroundColor: Color(0xFFFF4D4D),
                          ),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      widget.onConfirm(_selectedReason, _noteController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4D4D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Confirm Lock'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


