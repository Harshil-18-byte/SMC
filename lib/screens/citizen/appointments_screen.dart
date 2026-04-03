import 'package:flutter/material.dart';
import 'package:smc/data/services/auth_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:intl/intl.dart';

import 'package:smc/screens/citizen/book_appointment_sheet.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/smc_back_button.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid ?? 'cit_001';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const SMCBackButton(),
        title: Text(AppLocalizations.of(context).translate('appointments')),
        actions: const [ThemeSwitcher(), SizedBox(width: 8)],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: FirestoreService().streamCollection(
          collection: 'appointments',
          orderBy: 'time',
          descending: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text(
                    AppLocalizations.of(context).translate('err_generic')));
          }
          final rawAppointments = snapshot.data ?? [];
          final appointments = rawAppointments.isEmpty
              ? [
                  {
                    'id': 'appt1',
                    'citizenId': uid,
                    'doctorName': 'Dr. Sarah Wilson',
                    'facilityName': 'City Hub Medical Center',
                    'time': DateTime.now()
                        .add(const Duration(days: 2))
                        .toIso8601String(),
                    'status': 'confirmed',
                  },
                  {
                    'id': 'appt2',
                    'citizenId': uid,
                    'doctorName': 'Dr. James Chen',
                    'facilityName': 'SMC Specialist Wing',
                    'time': DateTime.now()
                        .subtract(const Duration(days: 5))
                        .toIso8601String(),
                    'status': 'completed',
                  },
                ]
              : rawAppointments.where((a) => a['citizenId'] == uid).toList();

          if (appointments.isEmpty &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (appointments.isEmpty) {
            return _buildEmptyState(context, isDark);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appt = appointments[index];
              return _buildAppointmentCard(context, appt, isDark);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookAppointmentSheet(context),
        label: Text(AppLocalizations.of(context).translate('book_new')),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 64, color: Colors.grey.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noDataAvailable,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text('Tap the button below to book one'),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, Map<String, dynamic> appt, bool isDark) {
    final time =
        appt['time'] != null ? DateTime.parse(appt['time']) : DateTime.now();
    final status = appt['status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getStatusIcon(status), color: _getStatusColor(status)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appt['doctorName'] ?? 'General Physician',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  appt['facilityName'] ?? 'City General Hospital',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('MMM dd, yyyy - hh:mm a').format(time),
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (status == 'pending')
                TextButton(
                  onPressed: () {},
                  child: Text(AppLocalizations.of(context).cancel,
                      style: const TextStyle(color: Colors.red, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      case 'completed':
        return Icons.task_alt_rounded;
      default:
        return Icons.pending_actions_rounded;
    }
  }

  void _showBookAppointmentSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => BookAppointmentSheet(
        onBooked: (appt) {
          // List updates automatically via StreamBuilder
        },
      ),
    );
  }
}
