import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/theme/universal_theme.dart';
import 'package:smc/core/theme/theme_service.dart';
import 'package:smc/core/localization/locale_service.dart';
import 'package:smc/core/providers/notification_provider.dart';
import 'package:smc/core/providers/auth_provider.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/config/routes.dart';

class UniversalSettingsScreen extends StatelessWidget {
  const UniversalSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: AdaptiveLayout(
        compactBody: _CompactSettingsView(),
        mediumBody:
            _CompactSettingsView(), // Reusing compact for now, can be expanded later
        expandedBody: _CompactSettingsView(),
      ),
    );
  }
}

class _CompactSettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding:
          EdgeInsets.all(UniversalTheme.getSpacing(context, SpacingSize.md)),
      children: [
        _SettingsSection(
          title: 'Account',
          icon: Icons.person,
          items: [
            _SettingsTile(
              title: 'Profile',
              subtitle: 'View and edit your profile',
              icon: Icons.account_circle,
              trailing: Icons.arrow_forward_ios,
              onTap: () {
                // Navigate based on role or to a generic profile
              },
            ),
            _SettingsTile(
              title: 'Security',
              subtitle: 'Password and authentication',
              icon: Icons.security,
              trailing: Icons.arrow_forward_ios,
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.md)),
        _SettingsSection(
          title: 'Preferences',
          icon: Icons.tune,
          items: [
            const _ThemeSelector(),
            const _LanguageSelector(),
            const _NotificationToggle(),
          ],
        ),
        SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.md)),
        _SettingsSection(
          title: 'Data & Privacy',
          icon: Icons.privacy_tip,
          items: [
            _SettingsTile(
              title: 'Data Usage',
              subtitle: '42 MB this month',
              icon: Icons.data_usage,
              trailing: Icons.arrow_forward_ios,
              onTap: () {},
            ),
            _SettingsTile(
              title: 'Privacy',
              subtitle: 'Manage your privacy settings',
              icon: Icons.lock,
              trailing: Icons.arrow_forward_ios,
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.lg)),
        _SettingsSection(
          title: 'Support',
          icon: Icons.help,
          items: [
            _SettingsTile(
              title: 'Help Center',
              icon: Icons.help_outline,
              trailing: Icons.arrow_forward_ios,
              onTap: () {},
            ),
            _SettingsTile(
              title: 'About',
              subtitle: 'Version 1.0.0',
              icon: Icons.info_outline,
              trailing: Icons.arrow_forward_ios,
              onTap: () {},
            ),
          ],
        ),
        SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.lg)),
        const _LogoutButton(),
        SizedBox(height: UniversalTheme.getSpacing(context, SpacingSize.xl)),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> items;

  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: UniversalTheme.getSpacing(context, SpacingSize.sm),
            bottom: UniversalTheme.getSpacing(context, SpacingSize.sm),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(
                  width: UniversalTheme.getSpacing(context, SpacingSize.sm)),
              Text(
                title,
                style: TextStyle(
                  fontSize:
                      UniversalTheme.getFontSize(context, FontSize.subtitle),
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
          ),
          margin: EdgeInsets.zero,
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final IconData? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    this.subtitle,
    required this.icon,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: UniversalTheme.getFontSize(context, FontSize.body),
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: UniversalTheme.getFontSize(context, FontSize.caption),
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            )
          : null,
      trailing: trailing != null
          ? Icon(trailing, size: 14, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              themeService.themeMode == ThemeMode.dark
                  ? Icons.dark_mode
                  : Icons.light_mode,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            'Theme',
            style: TextStyle(
              fontSize: UniversalTheme.getFontSize(context, FontSize.body),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode, size: 16),
                  label: Text('Light', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode, size: 16),
                  label: Text('Dark', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto, size: 16),
                  label: Text('Auto', style: TextStyle(fontSize: 12)),
                ),
              ],
              selected: {themeService.themeMode},
              onSelectionChanged: (Set<ThemeMode> newSelection) {
                themeService.setTheme(newSelection.first);
              },
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector();

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleService>(
      builder: (context, localeService, child) {
        return ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.language,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            'Language',
            style: TextStyle(
              fontSize: UniversalTheme.getFontSize(context, FontSize.body),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('English'),
                  selected: localeService.locale.languageCode == 'en',
                  onSelected: (selected) {
                    if (selected) localeService.setLocale(const Locale('en'));
                  },
                ),
                ChoiceChip(
                  label: const Text('मराठी'),
                  selected: localeService.locale.languageCode == 'mr',
                  onSelected: (selected) {
                    if (selected) localeService.setLocale(const Locale('mr'));
                  },
                ),
                ChoiceChip(
                  label: const Text('हिन्दी'),
                  selected: localeService.locale.languageCode == 'hi',
                  onSelected: (selected) {
                    if (selected) localeService.setLocale(const Locale('hi'));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle();

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        return SwitchListTile(
          secondary: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications,
              size: 22,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            'Notifications',
            style: TextStyle(
              fontSize: UniversalTheme.getFontSize(context, FontSize.body),
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            provider.notificationsEnabled
                ? 'You will receive alerts and updates'
                : 'Notifications are turned off',
            style: TextStyle(
              fontSize: UniversalTheme.getFontSize(context, FontSize.caption),
            ),
          ),
          value: provider.notificationsEnabled,
          onChanged: (bool value) {
            provider.setEnabled(value);
          },
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: UniversalTheme.getSpacing(context, SpacingSize.md),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Colors.white,
          minimumSize: Size(
            double.infinity,
            UniversalTheme.getComponentSize(context, ComponentSize.medium),
          ),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) async {
    // Clear all auth state
    context.read<AuthProvider>().logout();
    context.read<UserProvider>().logout();

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.login,
        (route) => false,
      );
    }
  }
}


