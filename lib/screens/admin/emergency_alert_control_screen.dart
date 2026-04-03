import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';

/// Emergency Alert Control Screen
/// Broadcast messages with severity levels and scope
class EmergencyAlertControlScreen extends StatefulWidget {
  const EmergencyAlertControlScreen({super.key});

  @override
  State<EmergencyAlertControlScreen> createState() =>
      _EmergencyAlertControlScreenState();
}

class _EmergencyAlertControlScreenState
    extends State<EmergencyAlertControlScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  final _headingController = TextEditingController();
  final _messageController = TextEditingController();
  final _reasonController = TextEditingController();

  String _severity = 'Warning';
  String _scope = 'All';
  String? _selectedZone;
  bool _isSending = false;

  final List<String> _severityLevels = ['Critical', 'Warning'];
  final List<String> _scopes = ['All', 'Zone-specific'];
  final List<String> _zones = [
    'Zone 1',
    'Zone 2',
    'Zone 3',
    'Zone 4',
    'Zone 5',
  ];

  @override
  void dispose() {
    _headingController.dispose();
    _messageController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _broadcastAlert() async {
    if (!_formKey.currentState!.validate()) return;

    if (_scope == 'Zone-specific' && _selectedZone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a zone'),
          backgroundColor: Color(0xFFFF4D4D),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      // Create alert
      await _firestoreService.createDocument(
        collection: 'emergency_alerts',
        data: {
          'heading': _headingController.text.trim(),
          'message': _messageController.text.trim(),
          'severity': _severity,
          'scope': _scope,
          'zone': _selectedZone,
          'reason': _reasonController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
          'isActive': true,
        },
      );

      // Log the broadcast
      await _firestoreService.createDocument(
        collection: 'audit_logs',
        data: {
          'action': 'EMERGENCY_ALERT_BROADCAST',
          'severity': _severity,
          'scope': _scope,
          'zone': _selectedZone,
          'reason': _reasonController.text.trim(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      setState(() => _isSending = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Alert broadcast successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );

        // Clear form
        _headingController.clear();
        _messageController.clear();
        _reasonController.clear();
        setState(() {
          _severity = 'Warning';
          _scope = 'All';
          _selectedZone = null;
        });
      }
    } catch (e) {
      setState(() => _isSending = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101922),
        elevation: 0,
        title: const Text(
          'Emergency Alert Control',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWarningBanner(),
              const SizedBox(height: 24),
              _buildSeveritySelector(),
              const SizedBox(height: 24),
              _buildScopeSelector(),
              if (_scope == 'Zone-specific') ...[
                const SizedBox(height: 24),
                _buildZoneSelector(),
              ],
              const SizedBox(height: 24),
              _buildHeadingField(),
              const SizedBox(height: 24),
              _buildMessageField(),
              const SizedBox(height: 24),
              _buildReasonField(),
              const SizedBox(height: 32),
              _buildBroadcastButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4D4D).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFF4D4D)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Color(0xFFFF4D4D), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HIGH PRIORITY ACTION',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF4D4D),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All broadcasts are logged and audited. Use responsibly.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SEVERITY LEVEL',
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
            final color = level == 'Critical'
                ? const Color(0xFFFF4D4D)
                : const Color(0xFFFFAB00);

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _severity = level),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.1)
                          : const Color(0xFF1B2733),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFF2D3748),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          level == 'Critical' ? Icons.error : Icons.warning,
                          color: isSelected ? color : Colors.grey[500],
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          level,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? color : Colors.grey[400],
                          ),
                        ),
                      ],
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

  Widget _buildScopeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BROADCAST SCOPE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ..._scopes.map((scope) {
          final isSelected = _scope == scope;
          return GestureDetector(
            onTap: () => setState(() => _scope = scope),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF137fec).withValues(alpha: 0.1)
                    : const Color(0xFF1B2733),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF137fec)
                      : const Color(0xFF2D3748),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF137fec)
                            : Colors.grey[600]!,
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF137fec)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    scope,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? const Color(0xFF137fec) : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildZoneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT ZONE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedZone,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1B2733),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF137fec)),
            ),
          ),
          dropdownColor: const Color(0xFF1B2733),
          style: const TextStyle(color: Colors.white),
          items: _zones.map((zone) {
            return DropdownMenuItem(value: zone, child: Text(zone));
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedZone = value);
          },
        ),
      ],
    );
  }

  Widget _buildHeadingField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALERT HEADING',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _headingController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter alert heading...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF1B2733),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF137fec)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Heading is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALERT MESSAGE',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _messageController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter detailed alert message...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF1B2733),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF137fec)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Message is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'REASON FOR BROADCAST',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey[500],
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '(MANDATORY)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF4D4D),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _reasonController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Explain why this broadcast is necessary...',
            hintStyle: TextStyle(color: Colors.grey[600]),
            filled: true,
            fillColor: const Color(0xFF1B2733),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2D3748)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF137fec)),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Reason is mandatory for audit trail';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBroadcastButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isSending ? null : _broadcastAlert,
        icon: _isSending
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Icon(Icons.campaign, size: 24),
        label: Text(
          _isSending ? 'Broadcasting...' : 'Broadcast Alert',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _severity == 'Critical'
              ? const Color(0xFFFF4D4D)
              : const Color(0xFFFFAB00),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}


