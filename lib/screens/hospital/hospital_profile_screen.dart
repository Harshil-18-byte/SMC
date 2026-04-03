import 'package:flutter/material.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/config/routes.dart';

class HospitalProfileScreen extends StatelessWidget {
  const HospitalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Hospital Staff Profile'),
        actions: const [ThemeSwitcher()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(context),
            const SizedBox(height: 32),
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(Icons.local_hospital_rounded,
              size: 50, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          'Dr. Aditi Kulkarni',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const Text(
          'Head of Triage • Ashwini Hospital',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SETTINGS',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildSettingTile(context, Icons.person, 'Account Information'),
              _buildSettingTile(
                  context, Icons.notifications, 'Notification Preferences'),
              _buildSettingTile(context, Icons.logout, 'Logout',
                  isDestructive: true, onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (route) => false);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile(BuildContext context, IconData icon, String title,
      {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? Colors.red
              : Theme.of(context).textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap ?? () {},
    );
  }
}


