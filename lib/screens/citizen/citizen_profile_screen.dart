import 'package:flutter/material.dart';
import 'package:smc/data/models/citizen_model.dart';
import 'package:smc/data/services/auth_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/theme/theme_switcher.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:intl/intl.dart';

class CitizenProfileScreen extends StatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  bool _isLoading = true;
  Citizen? _citizen;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      final uid = user?.uid ?? 'citizen_123'; // Proper citizen fallback

      final data = await _firestoreService.readDocument(
        collection: 'citizens',
        docId: uid,
      );

      if (data != null) {
        _citizen = Citizen.fromMap(data, uid);
      } else {
        // Use user provider if possible or fallback to citizen mock
        _citizen = Citizen(
          id: uid,
          name: user?.displayName ?? 'Suresh Patil',
          inspectionId: 'SOL-4522-8901',
          dateOfBirth: DateTime(1985, 8, 20),
          bloodGroup: 'O+',
          phone: user?.phoneNumber ?? '+91 91234 56789',
          email: user?.email ?? 'suresh.patil@gmail.com',
          address: 'Shivaji Colony, Bharat',
        );
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).profile),
        actions: const [ThemeSwitcher()],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 32),
                  _buildInfoSection(),
                  const SizedBox(height: 32),
                  _buildSettingsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 3,
            ),
          ),
          child: Icon(
            Icons.person,
            size: 50,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _citizen?.name ?? 'Unknown',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Inspection ID: ${_citizen?.inspectionId ?? 'N/A'}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ??
            Theme.of(context).colorScheme.surface,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)
                .translate('key_metrics'), // Reusing for block header style
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
              Icons.cake,
              'Date of Birth',
              _citizen?.dateOfBirth != null
                  ? DateFormat('MMM d, yyyy').format(_citizen!.dateOfBirth)
                  : 'Not set'),
          const Divider(height: 32),
          _buildInfoRow(Icons.bloodtype, 'Blood Group',
              _citizen?.bloodGroup ?? 'Not set'),
          const Divider(height: 32),
          _buildInfoRow(Icons.phone, 'Phone', _citizen?.phone ?? 'Not set'),
          const Divider(height: 32),
          _buildInfoRow(Icons.email, 'Email', _citizen?.email ?? 'Not set'),
          const Divider(height: 32),
          _buildInfoRow(
              Icons.location_on, 'Address', _citizen?.address ?? 'Not set'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon,
              size: 20, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        _buildSettingsTile(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.lock_outline,
          title: 'Privacy & Security',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.help_outline,
          title: 'Help & Support',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        const SizedBox(height: 12),
        _buildSettingsTile(
          icon: Icons.logout,
          title: AppLocalizations.of(context).logout,
          color: Theme.of(context).colorScheme.error,
          onTap: () {
            _authService.signOut();
            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          },
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      tileColor: Theme.of(context).cardTheme.color ??
          Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading:
          Icon(icon, color: color ?? Theme.of(context).colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}


