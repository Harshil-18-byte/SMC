import 'package:flutter/material.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/field_worker.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/config/routes.dart';
import '../common/notifications_screen.dart';

/// Field Worker Profile Screen
/// Shows worker stats, performance metrics, and settings
class FieldWorkerProfileScreen extends StatefulWidget {
  final String workerId;

  const FieldWorkerProfileScreen({super.key, required this.workerId});

  @override
  State<FieldWorkerProfileScreen> createState() =>
      _FieldWorkerProfileScreenState();
}

class _FieldWorkerProfileScreenState extends State<FieldWorkerProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = true;
  FieldWorker? _worker;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    try {
      // Load worker profile
      final workerData = await _firestoreService.readDocument(
        collection: 'field_workers',
        docId: widget.workerId,
      );

      if (workerData != null) {
        _worker = FieldWorker.fromMap(workerData, widget.workerId);
      }

      // Load stats
      _stats = {
        'visitsToday': 12,
        'visitsThisWeek': 47,
        'visitsThisMonth': 189,
        'householdsScreened': 156,
        'casesReported': 8,
        'averageRating': 4.7,
      };

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        actions: [
          const ThemeSwitcher(),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Edit profile
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildPerformanceSection(),
                    const SizedBox(height: 24),
                    _buildSettingsSection(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    if (_worker == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF137fec).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _worker!.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF137fec),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _worker!.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: ${_worker!.id}',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildInfoChip(Icons.location_on, _worker!.sector),
              _buildInfoChip(
                Icons.circle,
                _worker!.isOnline ? 'Online' : 'Offline',
                color: _worker!.isOnline
                    ? const Color(0xFF10B981)
                    : Colors.grey[600]!,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (color ?? const Color(0xFF137fec)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? const Color(0xFF137fec)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color ?? const Color(0xFF137fec),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE STATS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Visits Today',
              _stats['visitsToday'].toString(),
              Icons.today,
              const Color(0xFF137fec),
            ),
            _buildStatCard(
              'This Week',
              _stats['visitsThisWeek'].toString(),
              Icons.calendar_view_week,
              const Color(0xFF10B981),
            ),
            _buildStatCard(
              'This Month',
              _stats['visitsThisMonth'].toString(),
              Icons.calendar_month,
              const Color(0xFFFFAB00),
            ),
            _buildStatCard(
              'Cases Reported',
              _stats['casesReported'].toString(),
              Icons.report,
              const Color(0xFFFF4D4D),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PERFORMANCE METRICS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildMetricRow(
                'Households Screened',
                _stats['householdsScreened'].toString(),
                Icons.home,
              ),
              const SizedBox(height: 16),
              _buildMetricRow(
                'Average Rating',
                '${_stats['averageRating']}/5.0',
                Icons.star,
                valueColor: const Color(0xFFFFAB00),
              ),
              const SizedBox(height: 16),
              _buildMetricRow(
                'Response Time',
                '< 2 hours',
                Icons.timer,
                valueColor: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SETTINGS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[500],
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                Icons.notifications,
                'Notifications',
                'Manage notification preferences',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
              Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
              _buildSettingsTile(Icons.language, 'Language', 'English', () {}),
              Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
              _buildSettingsTile(
                Icons.help,
                'Help & Support',
                'Get help or report issues',
                () {},
              ),
              Divider(color: Colors.grey.withValues(alpha: 0.2), height: 1),
              _buildSettingsTile(
                Icons.logout,
                'Logout',
                'Sign out of your account',
                () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? const Color(0xFFFF4D4D) : Colors.grey[400],
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDestructive
              ? const Color(0xFFFF4D4D)
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: onTap,
    );
  }
}


