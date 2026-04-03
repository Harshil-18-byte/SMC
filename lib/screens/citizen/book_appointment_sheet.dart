import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/core/ui/milestone_tracker.dart';
import '../../data/models/doctor_model.dart';
import '../../data/services/auth_service.dart';

class BookAppointmentSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onBooked;

  const BookAppointmentSheet({super.key, required this.onBooked});

  @override
  State<BookAppointmentSheet> createState() => _BookAppointmentSheetState();
}

class _BookAppointmentSheetState extends State<BookAppointmentSheet> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  Doctor? _selectedDoctor;
  String? _selectedHospital;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              const Text('Book Appointment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),

          // 1. Select Hospital (Simplified for demo to just string)
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(labelText: 'Select Hospital'),
            items: [
              'City General Hospital',
              'SMC Specialist Wing',
              'Community Health Center'
            ].map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
            onChanged: (val) => setState(() {
              _selectedHospital = val;
              _selectedDoctor = null; // Reset doctor
            }),
          ),
          const SizedBox(height: 16),

          // 2. Select Doctor (Mocked list based on hospital)
          DropdownButtonFormField<Doctor>(
            key: ValueKey(
                _selectedHospital), // Ensure rebuild when hospital changes
            decoration: const InputDecoration(labelText: 'Select Doctor'),
            initialValue: _selectedDoctor,
            items: _selectedHospital == null
                ? []
                : _getMockDoctors(_selectedHospital!)
                    .map((d) => DropdownMenuItem(
                        value: d, child: Text('${d.name} (${d.specialty})')))
                    .toList(),
            onChanged: (val) => setState(() => _selectedDoctor = val),
          ),
          const SizedBox(height: 16),

          // 3. Select Date
          ListTile(
            title: const Text('Date'),
            trailing: Text(
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}"),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),

          // 4. Select Time
          ListTile(
            title: const Text('Time'),
            trailing: Text(_selectedTime.format(context)),
            onTap: () async {
              final time = await showTimePicker(
                  context: context, initialTime: _selectedTime);
              if (time != null) setState(() => _selectedTime = time);
            },
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: (_selectedDoctor != null) ? _confirmBooking : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  // Mock Data Helper
  List<Doctor> _getMockDoctors(String hospital) {
    // Return dummy doctors for the hospital
    return [
      Doctor(
          id: 'd1',
          name: 'Dr. John Smith',
          specialty: 'Cardiology',
          hospitalName: hospital,
          hospitalId: 'h1',
          rating: 4.8,
          experienceYears: 10,
          imageUrl: '',
          consultationFee: 500),
      Doctor(
          id: 'd2',
          name: 'Dr. Emily Blunt',
          specialty: 'Pediatrics',
          hospitalName: hospital,
          hospitalId: 'h1',
          rating: 4.9,
          experienceYears: 8,
          imageUrl: '',
          consultationFee: 450),
      Doctor(
          id: 'd3',
          name: 'Dr. Mark Lee',
          specialty: 'General',
          hospitalName: hospital,
          hospitalId: 'h1',
          rating: 4.5,
          experienceYears: 5,
          imageUrl: '',
          consultationFee: 300),
    ];
  }

  Future<void> _confirmBooking() async {
    final DateTime appointmentTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute);

    final String citizenId = AuthService().currentUser?.uid ?? 'cit_guest';

    // Create Appointment Data
    final appointmentData = {
      'citizenId': citizenId,
      'doctorId': _selectedDoctor!.id,
      'doctorName': _selectedDoctor!.name,
      'facilityName': _selectedHospital,
      'time': appointmentTime.toIso8601String(),
      'status': 'confirmed',
      'type': 'In-Person',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      // Save directly to Firestore for real-time
      await FirebaseFirestore.instance
          .collection('appointments')
          .add(appointmentData);

      if (mounted) {
        MilestoneTracker.showCelebration(
          context,
          title: "All set! 🗓️",
          message:
              "Your appointment with ${appointmentData['doctorName']} is confirmed.\n\nSee you on ${_selectedDate.day}/${_selectedDate.month} at ${_selectedTime.format(context)}.",
          emoji: '🏥',
        );
      }

      widget.onBooked(appointmentData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}


