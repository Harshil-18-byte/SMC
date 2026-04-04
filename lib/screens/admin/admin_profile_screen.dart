import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/config/routes.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for Admin
    final adminData = {
      'name': 'Dr. Anjali Deshpande',
      'role': 'Chief Inspection Officer',
      'department': 'Defect Surveillance',
      'email': 'anjali.deshpande@smc.gov.in',
      'phone': '+91 98765 43210',
      'location': 'SMC Command Center, Bharat',
      'lastLogin': 'Today, 09:41 AM',
    };

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Admin Profile'),
        actions: const [ThemeSwitcher()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Card
            _buildProfileCard(context, adminData),
            const SizedBox(height: 24),
            // Quick Stats
            _buildQuickStats(context),
            const SizedBox(height: 24),
            // Settings
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, Map<String, String> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            child: Text(
              data['name']!.substring(0, 1),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data['name']!,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            data['role']!,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(context, Icons.email, data['email']!),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.phone, data['phone']!),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.business, data['department']!),
          const SizedBox(height: 12),
          _buildInfoRow(context, Icons.location_on, data['location']!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      children: [
        _buildStatCard(context, '12', 'Pending\nApprovals', Colors.orange),
        const SizedBox(width: 16),
        _buildStatCard(context, '85%', 'System\nUptime', Colors.green),
        const SizedBox(width: 16),
        _buildStatCard(context, '4', 'Active\nAlerts', Colors.red),
      ],
    );
  }

  Widget _buildStatCard(
      BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: color.withValues(alpha: 0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
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
        _buildSettingTile(context, Icons.settings, 'System Configuration'),
        _buildSettingTile(context, Icons.security, 'Access Control'),
        _buildSettingTile(
            context, Icons.notifications, 'Notification Preferences'),
        _buildSettingTile(context, Icons.logout, 'Logout', isDestructive: true,
            onTap: () {
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.login, (route) => false);
        }),
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title,
      {bool isDestructive = false, VoidCallback? onTap}) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? color.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}


