import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/data/models/task.dart' as smc_task;

class InspectorScheduleScreen extends StatefulWidget {
  const InspectorScheduleScreen({super.key});

  @override
  State<InspectorScheduleScreen> createState() => _InspectorScheduleScreenState();
}

class _InspectorScheduleScreenState extends State<InspectorScheduleScreen> {
  final List<smc_task.Task> _mockTasks = [
    smc_task.Task(
      id: 'TASK-101',
      householdId: 'HH-7728',
      title: 'Emergency Pipeline Check',
      description: 'Report of leak in Sector 4 Main Line. Requires immediate diagnostic.',
      priority: 'PRIORITY',
      imageUrl: '',
      assignedDate: DateTime.now(),
    ),
    smc_task.Task(
      id: 'TASK-102',
      householdId: 'HH-5512',
      title: 'Routine Bridge Audit',
      description: 'Annual structural integrity check for East Overpass.',
      priority: 'ROUTINE',
      imageUrl: '',
      assignedDate: DateTime.now().add(const Duration(hours: 4)),
    ),
    smc_task.Task(
      id: 'TASK-103',
      householdId: 'HH-8819',
      title: 'Pavement Quality Survey',
      description: 'Collect road surface data for Highway 12 expansion project.',
      priority: 'SURVEY',
      imageUrl: '',
      assignedDate: DateTime.now().add(const Duration(days: 1)),
    ),
    smc_task.Task(
      id: 'TASK-104',
      householdId: 'HH-2201',
      title: 'Electrical Transformer V2',
      description: 'Inspect cooling system and update terminal firmware.',
      priority: 'ROUTINE',
      imageUrl: '',
      assignedDate: DateTime.now().add(const Duration(hours: 6)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final amber = const Color(0xFFF59E0B);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Operational Schedule',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_month_rounded)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockTasks.length,
        itemBuilder: (context, index) {
          final task = _mockTasks[index];
          return _buildTaskCard(task, isDark, amber);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: amber,
        child: const Icon(Icons.add_task_rounded, color: Colors.black87),
      ),
    );
  }

  Widget _buildTaskCard(smc_task.Task task, bool isDark, Color amber) {
    final priorityStyle = task.getPriorityStyle();
    final bgColor = isDark ? priorityStyle.darkBgColor : priorityStyle.bgColor;
    final txtColor = isDark ? priorityStyle.darkTextColor : priorityStyle.textColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  task.priority,
                  style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: txtColor, letterSpacing: 1),
                ),
              ),
              Text(
                '${task.assignedDate.hour}:${task.assignedDate.minute.toString().padLeft(2, '0')}',
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(task.title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 8),
          Text(task.description, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey, height: 1.4)),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 14, color: amber),
              const SizedBox(width: 4),
              Text(task.householdId, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: amber)),
              const Spacer(),
              RawMaterialButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.newInspection,
                    arguments: {'inspectorId': 'INS-402', 'assetId': task.id, 'assetName': task.title},
                  );
                },
                fillColor: amber,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('BEGIN ACTION', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.black87)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
