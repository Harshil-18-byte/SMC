import 'package:flutter/material.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/theme/theme_service.dart';
import 'package:smc/core/localization/widgets/language_selector.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/models/user_model.dart';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/core/providers/auth_provider.dart';

class UniversalDrawer extends StatelessWidget {
  final bool isPermanent;

  const UniversalDrawer({
    super.key,
    this.isPermanent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final role = user?.role ?? UserRole.citizen;

    return Drawer(
      elevation: isPermanent ? 0 : 16,
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // Header / Profile Section
          _buildHeader(context, user),

          const Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildSectionHeader(
                    context, AppLocalizations.of(context).menuMainMenu),
                _buildNavItem(
                  context,
                  Icons.dashboard_rounded,
                  AppLocalizations.of(context).menuDashboard,
                  role == UserRole.admin
                      ? AppRoutes.adminDashboard
                      : role == UserRole.fieldWorker
                          ? AppRoutes.fieldWorkerHome
                          : AppRoutes.citizenHome,
                ),
                _buildNavItem(
                  context,
                  Icons.person_outline_rounded,
                  AppLocalizations.of(context).menuProfile,
                  role == UserRole.admin
                      ? AppRoutes.adminProfile
                      : role == UserRole.fieldWorker
                          ? AppRoutes.fieldWorkerProfile
                          : AppRoutes.citizenProfile,
                ),
                if (role == UserRole.admin)
                  _buildNavItem(
                    context,
                    Icons.auto_awesome_rounded,
                    AppLocalizations.of(context).menuMagic,
                    AppRoutes.immersiveDashboard,
                  ),
                if (role == UserRole.fieldWorker)
                  _buildNavItem(
                    context,
                    Icons.emoji_events_rounded,
                    AppLocalizations.of(context).menuImpact,
                    AppRoutes.fieldWorkerAchievements,
                  ),
                _buildNavItem(
                  context,
                  Icons.sensors_rounded,
                  AppLocalizations.of(context).translate('menu_iot'),
                  AppRoutes.iotDashboard,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(),
                ),
                _buildSectionHeader(
                    context, AppLocalizations.of(context).menuSettings),
                _buildThemeToggle(context),
                _buildLanguageItem(context),
              ],
            ),
          ),

          // Footer / Logout
          const Divider(height: 1),
          _buildLogout(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, User? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.name ?? AppLocalizations.of(context).unknownUser,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            user?.role.displayName ?? AppLocalizations.of(context).standardUser,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, IconData icon, String title, String route) {
    final bool isSelected = ModalRoute.of(context)?.settings.name == route;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (!isPermanent) Navigator.pop(context);
        if (!isSelected) Navigator.pushNamed(context, route);
      },
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);
    return ListTile(
      leading: Icon(
        themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(AppLocalizations.of(context).darkMode),
      trailing: Switch.adaptive(
        value: themeService.isDarkMode,
        onChanged: (value) => themeService.toggleTheme(),
      ),
    );
  }

  Widget _buildLanguageItem(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.language,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
      ),
      title: Text(AppLocalizations.of(context).language),
      trailing: const LanguageSwitcherButton(showLabel: true),
      onTap: () => LanguageSelectorDialog.show(context),
    );
  }

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            // Logout from all providers
            context.read<AuthProvider>().logout();
            context.read<UserProvider>().logout();

            Navigator.pushNamedAndRemoveUntil(
                context, AppRoutes.login, (route) => false);
          },
          icon: Icon(Icons.logout_rounded,
              color: Theme.of(context).colorScheme.error, size: 20),
          label: Text(
            AppLocalizations.of(context).logout,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
