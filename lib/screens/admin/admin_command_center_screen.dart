import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/command_center_models.dart';
import 'package:smc/core/constants/app_colors.dart';

/// Enhanced Admin Command Center Dashboard
/// High-density KPIs, real-time alerts, hospital intake status
class AdminCommandCenterScreen extends StatefulWidget {
  const AdminCommandCenterScreen({super.key});

  @override
  State<AdminCommandCenterScreen> createState() =>
      _AdminCommandCenterScreenState();
}

class _AdminCommandCenterScreenState extends State<AdminCommandCenterScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  CommandCenterKPI? _kpi;
  List<SystemAlert> _alerts = [];
  List<HospitalIntakeStatus> _hospitals = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load KPI data
      final kpiData = await _firestoreService.readDocument(
        collection: 'command_center_kpi',
        docId: 'current',
      );
      if (kpiData != null) {
        _kpi = CommandCenterKPI.fromMap(kpiData);
      }

      // Load system alerts
      final alertsData = await _firestoreService.getCollection(
        collection: 'system_alerts',
        orderBy: 'timestamp',
        descending: true,
        limit: 10,
      );
      _alerts = alertsData
          .map((data) => SystemAlert.fromMap(data, data['id']))
          .toList();

      // Load hospital statuses
      final hospitalsData = await _firestoreService.getCollection(
        collection: 'hospital_intake_status',
        orderBy: 'name',
      );
      _hospitals = hospitalsData
          .map((data) => HospitalIntakeStatus.fromMap(data, data['id']))
          .toList();

      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Command Center',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'ADMIN DASHBOARD',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.safetyNavy,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    _buildKPIGrid(),
                    const SizedBox(height: 20),
                    _buildAlertsFeed(),
                    const SizedBox(height: 20),
                    _buildHospitalStatusSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  /// Top: KPI Grid (High Density)
  Widget _buildKPIGrid() {
    if (_kpi == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('TOP KEY PERFORMANCE INDICATORS'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                'Active Cases',
                _kpi!.activeCases.toString(),
                Icons.person_search,
                AppColors.emergencyRed,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKPICard(
                'ICU Capacity',
                '${_kpi!.icuCapacity.toInt()}%',
                Icons.local_hospital,
                AppColors.warningOrange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKPICard(
                'Stress Index',
                _kpi!.hospitalStressIndex.toInt().toString(),
                Icons.speed,
                _getStressColor(_kpi!.hospitalStressIndex),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(fontSize: 9, color: AppColors.textBody),
            ),
          ),
        ],
      ),
    );
  }

  /// Middle: Real-time Alerts Feed
  Widget _buildAlertsFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('SYSTEM ALERTS FEED'),
            const Text(
              'LIVE',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.successGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: _alerts.isEmpty
              ? const Center(
                  child: Text('No active alerts',
                      style: TextStyle(color: AppColors.textBody)))
              : ListView.separated(
                  padding: const EdgeInsets.all(0),
                  itemCount: _alerts.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: AppColors.borderDark, height: 1),
                  itemBuilder: (context, index) {
                    final alert = _alerts[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.circle,
                          size: 8, color: _getSeverityColor(alert.severity)),
                      title: Text(alert.message,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13)),
                      subtitle: Text(alert.getTimeAgo(),
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.textBody)),
                      trailing: const Icon(Icons.chevron_right,
                          size: 14, color: AppColors.textBody),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Bottom: Hospital Intake Status Cards (Grid/Wrap)
  Widget _buildHospitalStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('HOSPITAL INTAKE STATUS'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _hospitals.map((h) => _buildHospitalListItem(h)).toList(),
        ),
      ],
    );
  }

  Widget _buildHospitalListItem(HospitalIntakeStatus h) {
    final width = (MediaQuery.of(context).size.width - 44) / 2;
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: h.intakeLocked ? AppColors.emergencyRed : AppColors.borderDark,
          width: h.intakeLocked ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  h.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (h.intakeLocked)
                const Icon(Icons.lock, size: 12, color: AppColors.emergencyRed),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: _buildSmallMetric('BEDS', '${h.bedAvailable}')),
              Flexible(child: _buildSmallMetric('O₂', '${h.oxygenLevel}%')),
              Flexible(
                  child: _buildSmallMetric('WAIT', '${h.triageWaitMinutes}m')),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (h.bedTotal - h.bedAvailable) / h.bedTotal,
              child: Container(
                decoration: BoxDecoration(
                  color: h.statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(fontSize: 8, color: AppColors.textBody)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.textBody,
        letterSpacing: 1.1,
      ),
    );
  }

  Color _getStressColor(double index) {
    if (index > 80) return AppColors.emergencyRed;
    if (index > 50) return AppColors.warningOrange;
    return AppColors.successGreen;
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.emergencyRed;
      case 'warning':
        return AppColors.warningOrange;
      default:
        return AppColors.successGreen;
    }
  }
}


