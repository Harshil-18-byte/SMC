import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/hospital_shift_model.dart';

class HospitalScheduleScreen extends StatefulWidget {
  const HospitalScheduleScreen({super.key});

  @override
  State<HospitalScheduleScreen> createState() => _HospitalScheduleScreenState();
}

class _HospitalScheduleScreenState extends State<HospitalScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddShiftDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Date Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('hospital_shifts')
                  .orderBy('startTime') // Basic ordering
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                // Filter locally for simplicity (or update query)
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final start = DateTime.parse(data['startTime']);
                  return start.year == _selectedDate.year &&
                      start.month == _selectedDate.month &&
                      start.day == _selectedDate.day;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                      child: Text('No shifts scheduler for this date'));
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        filteredDocs[index].data() as Map<String, dynamic>;
                    final shift = HospitalStaffShift.fromMap(
                        data, filteredDocs[index].id);
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRoleColor(shift.role),
                        child: Icon(_getRoleIcon(shift.role),
                            color: Colors.white, size: 20),
                      ),
                      title: Text(shift.staffName),
                      subtitle: Text('${shift.role} • ${shift.ward}'),
                      trailing: Text(
                        '${shift.startTime.hour}:${shift.startTime.minute.toString().padLeft(2, '0')} - '
                        '${shift.endTime.hour}:${shift.endTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Doctor':
        return Colors.blue;
      case 'Nurse':
        return Colors.pink;
      case 'Technician':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Doctor':
        return Icons.medical_services;
      case 'Nurse':
        return Icons.local_hospital;
      case 'Technician':
        return Icons.biotech;
      default:
        return Icons.person;
    }
  }

  void _showAddShiftDialog(BuildContext context) {
    final nameController = TextEditingController();
    String role = 'Doctor';
    String ward = 'General';
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Add Shift'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Staff Name'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    items: ['Doctor', 'Nurse', 'Technician']
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (val) => setState(() => role = val!),
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: ward,
                    items: ['General', 'ICU', 'Emergency']
                        .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                        .toList(),
                    onChanged: (val) => setState(() => ward = val!),
                    decoration: const InputDecoration(labelText: 'Ward'),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Start Time'),
                    trailing: Text(startTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: startTime);
                      if (time != null) setState(() => startTime = time);
                    },
                  ),
                  ListTile(
                    title: const Text('End Time'),
                    trailing: Text(endTime.format(context)),
                    onTap: () async {
                      final time = await showTimePicker(
                          context: context, initialTime: endTime);
                      if (time != null) setState(() => endTime = time);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final startDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      startTime.hour,
                      startTime.minute);
                  // Handle overnight shifts simply for now (same day assumption or next if end < start)
                  var endDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      endTime.hour,
                      endTime.minute);
                  if (endDateTime.isBefore(startDateTime)) {
                    endDateTime = endDateTime.add(const Duration(days: 1));
                  }

                  final newShift = HospitalStaffShift(
                    id: '',
                    staffName: nameController.text,
                    role: role,
                    startTime: startDateTime,
                    endTime: endDateTime,
                    ward: ward,
                  );

                  FirebaseFirestore.instance
                      .collection('hospital_shifts')
                      .add(newShift.toMap());
                  Navigator.pop(context);
                },
                child: const Text('Add Shift'),
              ),
            ],
          );
        },
      ),
    );
  }
}


