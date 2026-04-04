import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/core/ui/milestone_tracker.dart';
import 'package:smc/data/models/inspector_model.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// Book Inspection Sheet
/// Allows citizens or managers to schedule on-site inspections for specific assets.
class BookInspectionSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onBooked;

  const BookInspectionSheet({super.key, required this.onBooked});

  @override
  State<BookInspectionSheet> createState() => _BookInspectionSheetState();
}

class _BookInspectionSheetState extends State<BookInspectionSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  InspectorModel? _selectedInspector;
  String? _selectedAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SCHEDULE INSPECTION', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(labelText: 'Select Target Asset', labelStyle: TextStyle(color: Theme.of(context).primaryColor)),
            items: ['City Bridge-04', 'Sewage Plant A', 'Sector 4 Grid'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
            onChanged: (val) => setState(() => _selectedAsset = val),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<InspectorModel>(
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(labelText: 'Assign Inspector', labelStyle: TextStyle(color: Theme.of(context).primaryColor)),
            items: _getMockInspectors().map((i) => DropdownMenuItem(value: i, child: Text('${i.fullName} (${i.specialization})'))).toList(),
            onChanged: (val) => setState(() => _selectedInspector = val),
          ),
          const SizedBox(height: 24),

          _buildDateTimePickers(context),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: (_selectedInspector != null && _selectedAsset != null) ? _confirmBooking : null,
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, padding: EdgeInsets.symmetric(vertical: 16)),
            child: Text('INITIATE INSPECTION CYCLE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimePickers(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DATE', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _selectedTime);
              if (time != null) setState(() => _selectedTime = time);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TIME', style: TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                Text(_selectedTime.format(context), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<InspectorModel> _getMockInspectors() {
    return [
      InspectorModel(id: 'i1', fullName: 'Arnav Desai', specialization: 'Structural', rank: 'L-1', profileUrl: ''),
      InspectorModel(id: 'i2', fullName: 'Sasha Roy', specialization: 'Electrical', rank: 'S-1', profileUrl: ''),
    ];
  }

  Future<void> _confirmBooking() async {
    final DateTime scheduledTime = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    final payload = {
      'requesterId': userProvider.currentUser?.id ?? 'guest',
      'inspectorId': _selectedInspector!.id,
      'assetName': _selectedAsset,
      'scheduledTime': scheduledTime.toIso8601String(),
      'status': 'scheduled',
      'type': 'On-Site Audit',
    };

    try {
      await FirebaseFirestore.instance.collection('inspections').add(payload);
      if (mounted) {
        MilestoneTracker.showCelebration(context, title: "MISSION SECURED", message: "Inspector ${_selectedInspector!.fullName} assigned to ${_selectedAsset}.", emoji: '🏗️');
        widget.onBooked(payload);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
