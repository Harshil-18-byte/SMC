import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/data/models/inspector_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// Professional Inspector Schedule Screen
/// Manages duty cycles, area assignments, and shift logistics for Field Engineers.
class InspectorScheduleScreen extends StatefulWidget {
  const InspectorScheduleScreen({super.key});

  @override
  State<InspectorScheduleScreen> createState() => _InspectorScheduleScreenState();
}

class _InspectorScheduleScreenState extends State<InspectorScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('DUTY ROTA', style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded, color: Colors.blue),
            onPressed: () => _showAddShiftDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          Expanded(child: _buildShiftList()),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: Colors.white70), onPressed: () => setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)))),
          Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.white70), onPressed: () => setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)))),
        ],
      ),
    );
  }

  Widget _buildShiftList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('inspector_shifts').orderBy('startTime').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Data Link Error', style: TextStyle(color: Colors.red)));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final filtered = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final start = DateTime.parse(data['startTime']);
          return start.year == _selectedDate.year && start.month == _selectedDate.month && start.day == _selectedDate.day;
        }).toList();

        if (filtered.isEmpty) return Center(child: Text('No duties assigned for this cycle.', style: TextStyle(color: Colors.grey)));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final data = filtered[index].data() as Map<String, dynamic>;
            final shift = InspectorShift.fromMap(data, filtered[index].id);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.blue.withValues(alpha: 0.1), child: const Icon(Icons.engineering_rounded, color: Colors.blue, size: 20)),
                title: Text(data['inspectorName'] ?? 'Lead Engineer', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: Text("${shift.zone} • ${data['rank'] ?? 'Expert'}", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${shift.startTime.hour}:${shift.startTime.minute.toString().padLeft(2, '0')}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    const Text("SHIFT START", style: TextStyle(color: Colors.grey, fontSize: 8)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddShiftDialog(BuildContext context) {
    // Placeholder for adding shift with industrial UI
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Initializing Rota Management System...")));
  }
}
