import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/core/providers/auth_provider.dart';
import 'package:smc/data/models/user_model.dart';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/widgets/smc_map.dart'; // For ThemeExtension

class UniversalProfileScreen extends StatelessWidget {
  const UniversalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;
        if (user == null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('User information not found. Please login again.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, AppRoutes.login),
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        // Return ROLE-SPECIFIC profile
        switch (user.role) {
          case UserRole.superAdmin:
          case UserRole.stateAdmin:
          case UserRole.cityAdmin:
            return _AdminProfileView(user: user);
          case UserRole.fieldInspector:
            return _FieldWorkerProfileView(user: user);
          case UserRole.viewer:
            return _CitizenProfileView(user: user);
        }
      },
    );
  }
}

// Admin Profile
class _AdminProfileView extends StatelessWidget {
  final User user;
  const _AdminProfileView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(user: user, roleColor: Colors.red),
            const SizedBox(height: 24),
            _buildStatCard(
              context,
              title: 'System Overview',
              stats: [
                _StatItemData(
                    icon: Icons.location_city, label: 'Cities', value: '42'),
                _StatItemData(
                    icon: Icons.assignment_turned_in,
                    label: 'Compliant Assets',
                    value: '8.4k'),
                _StatItemData(
                    icon: Icons.report_problem, label: 'Critical Defects', value: '156'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Administrative Info',
              items: [
                _InfoItemData(
                    icon: Icons.badge,
                    label: 'Officer ID',
                    value: user.employeeId ?? 'N/A'),
                _InfoItemData(
                    icon: Icons.location_on,
                    label: 'Primary Jurisdiction',
                    value: user.cityId ?? user.stateId ?? 'India'),
                _InfoItemData(
                    icon: Icons.verified_user,
                    label: 'Clearance Level',
                    value: user.role == UserRole.superAdmin ? 'National' : 'Regional'),
              ],
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Field Worker Profile
class _FieldWorkerProfileView extends StatelessWidget {
  final User user;
  const _FieldWorkerProfileView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(user: user, roleColor: Colors.orange),
            const SizedBox(height: 24),
            _buildStatCard(
              context,
              title: 'My Performance',
              stats: [
                _StatItemData(
                    icon: Icons.check_circle_outline,
                    label: 'Inspections',
                    value: '${user.todayInspections ?? 0}'),
                _StatItemData(
                    icon: Icons.add_task,
                    label: 'Defects Resolved',
                    value: '${user.resolvedDefects ?? 0}'),
                _StatItemData(
                    icon: Icons.local_fire_department,
                    label: 'Task Streak',
                    value: '${user.streak ?? 0} days'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Work Info',
              items: [
                _InfoItemData(
                    icon: Icons.badge,
                    label: 'Inspector ID',
                    value: user.employeeId ?? 'N/A'),
                _InfoItemData(
                    icon: Icons.location_on,
                    label: 'Assigned Beat',
                    value: user.wardId ?? user.cityId ?? 'N/A'),
                _InfoItemData(
                    icon: Icons.calendar_today,
                    label: 'Last Sync',
                    value: user.lastInspection ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// Citizen Profile
class _CitizenProfileView extends StatelessWidget {
  final User user;
  const _CitizenProfileView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _ProfileHeader(user: user, roleColor: Colors.blue),
            const SizedBox(height: 24),
            _buildStatCard(
              context,
              title: 'Inspection Summary',
              stats: [
                _StatItemData(
                    icon: Icons.security,
                    label: 'Compliance',
                    value: '${user.complianceScore ?? 0}%'),
                _StatItemData(
                    icon: Icons.verified,
                    label: 'Reports Filed',
                    value: '12'),
                _StatItemData(
                    icon: Icons.calendar_today,
                    label: 'Last Activity',
                    value: user.lastInspection ?? 'N/A'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              title: 'Personal Info',
              items: [
                _InfoItemData(
                    icon: Icons.person, label: 'Full Name', value: user.name),
                _InfoItemData(
                    icon: Icons.phone, label: 'Phone', value: user.phone),
                _InfoItemData(
                    icon: Icons.email, label: 'Email', value: user.email),
                _InfoItemData(
                    icon: Icons.location_city,
                    label: 'Current City',
                    value: user.cityId ?? 'National'),
              ],
            ),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


// Shared Components
class _ProfileHeader extends StatelessWidget {
  final User user;
  final Color roleColor;

  const _ProfileHeader({required this.user, required this.roleColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [roleColor, roleColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: user.photoUrl != null
                ? ClipOval(
                    child: Image.network(user.photoUrl!,
                        width: 96, height: 96, fit: BoxFit.cover))
                : Text(user.name[0],
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: roleColor)),
          ),
          const SizedBox(height: 16),
          Text(user.name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16)),
            child: Text(user.role.displayName,
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _StatItemData {
  final IconData icon;
  final String label;
  final String value;
  _StatItemData({required this.icon, required this.label, required this.value});
}

class _InfoItemData {
  final IconData icon;
  final String label;
  final String value;
  _InfoItemData({required this.icon, required this.label, required this.value});
}

Widget _buildStatCard(BuildContext context,
    {required String title, required List<_StatItemData> stats}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: stats
                .map((stat) => Column(
                      children: [
                        Icon(stat.icon, color: context.colors.primary),
                        const SizedBox(height: 8),
                        Text(stat.value,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(stat.label,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    ),
  );
}

Widget _buildInfoCard(BuildContext context,
    {required String title, required List<_InfoItemData> items}) {
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          ...items.map((item) => ListTile(
                leading: Icon(item.icon, color: context.colors.primary),
                title: Text(item.label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(item.value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                dense: true,
              )),
        ],
      ),
    ),
  );
}

Widget _buildLogoutButton(BuildContext context) {
  return SizedBox(
    width: double.infinity,
    child: OutlinedButton.icon(
      onPressed: () {
        _showLogoutDialog(context);
      },
      icon: const Icon(Icons.logout),
      label: const Text('Logout and Clear Session'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        side: const BorderSide(color: Colors.red),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logout'),
      content: const Text('Are you sure you want to end your session?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<AuthProvider>().logout();
            context.read<UserProvider>().logout();
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}


