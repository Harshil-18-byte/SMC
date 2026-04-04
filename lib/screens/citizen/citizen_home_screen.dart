import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/models/citizen_model.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/localization/app_localizations.dart';

import 'package:smc/core/widgets/dashboard_back_handler.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/theme/universal_theme.dart';
import 'package:smc/core/widgets/universal_drawer.dart';

import 'package:smc/core/visuals/magic_widgets.dart';
import 'package:smc/core/visuals/medical_textures.dart'; // Added
import 'package:google_fonts/google_fonts.dart';
import '../common/notifications_screen.dart';
import 'package:smc/features/environment/environment_widget.dart'; // Added Environment Widget

/// Citizen Home Screen
/// Dashboard with SOS countdown, alerts, and quick actions
class CitizenHomeScreen extends StatefulWidget {
  final String citizenId;

  const CitizenHomeScreen({super.key, this.citizenId = 'current_user'});

  @override
  State<CitizenHomeScreen> createState() => _CitizenHomeScreenState();
}

class _CitizenHomeScreenState extends State<CitizenHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final String uid = user?.id ?? 'citizen_123';

    return AdaptiveLayout(
      compactBody: _buildDashboardBody(context, uid),
      mediumBody: _buildDashboardBody(context, uid),
      expandedBody: _buildDashboardBody(context, uid),
      largeBody: _buildDashboardBody(context, uid),
    );
  }

  Widget _buildDashboardBody(BuildContext context, String uid) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const UniversalDrawer(),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).translate('command_center'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationsScreen(),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: PaperTextureBackground(
        isDark: Theme.of(context).brightness == Brightness.dark,
        child: DashboardBackHandler(
          dashboardName: 'Viewer Dashboard',
          child: StreamBuilder<Map<String, dynamic>?>(
            stream: _firestoreService.streamDocument(
                collection: 'citizens', docId: uid),
            builder: (context, citizenSnapshot) {
              if (citizenSnapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      AppLocalizations.of(context).translate('err_generic'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final citizenData = citizenSnapshot.data;
              final citizen = citizenData != null
                  ? Citizen.fromMap(citizenData, uid)
                  : Citizen(
                      id: uid,
                      name: 'Suresh Patil',
                      inspectionId: 'SOL-4522-8901',
                      dateOfBirth: DateTime(1985, 8, 20),
                      bloodGroup: 'O+',
                      phone: '+91 91234 56789',
                      email: 'suresh.patil@gmail.com',
                      address: 'Shivaji Colony, Bharat',
                    );

              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.streamCollection(
                  collection: 'inspection_alerts',
                  orderBy: 'timestamp',
                  descending: true,
                  limit: 5,
                ),
                builder: (context, alertsSnapshot) {
                  if (alertsSnapshot.hasError) {
                    return Center(
                      child: Text(AppLocalizations.of(context)
                          .translate('err_generic')),
                    );
                  }
                  final rawAlerts = alertsSnapshot.data ?? [];
                  final alerts = rawAlerts.isEmpty
                      ? [
                          InspectionAlert(
                            id: 'a1',
                            title: 'Air Quality Advisory',
                            message:
                                'PM2.5 levels are higher than usual today.',
                            severity: 'warning',
                            timestamp: DateTime.now(),
                            isRead: false,
                          ),
                          InspectionAlert(
                            id: 'a2',
                            title: 'Vaccination Drive',
                            message:
                                'Nearby center has opened slots for boosters.',
                            severity: 'info',
                            timestamp: DateTime.now()
                                .subtract(const Duration(hours: 3)),
                            isRead: true,
                          ),
                        ]
                      : rawAlerts
                          .map((data) => InspectionAlert.fromMap(
                              data, (data['id'] ?? '') as String))
                          .toList();

                  return RefreshIndicator(
                    onRefresh: () async => setState(() {}),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            UniversalTheme.getSpacing(context, SpacingSize.md),
                        vertical:
                            UniversalTheme.getSpacing(context, SpacingSize.md),
                      ),
                      child: Column(
                        children: [
                          _buildWelcomeCard(citizen),
                          const SizedBox(height: 32), // Increased from 16
                          const EnvironmentStatusWidget(),
                          const SizedBox(height: 40), // Increased from 24
                          _buildQuickActions(),
                          const SizedBox(height: 32), // Increased spacing
                          _buildAlertsSection(alerts),
                          const SizedBox(height: 120), // More space at bottom
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.publicSOS),
        backgroundColor: Colors.red,
        icon: const Icon(Icons.sos, color: Colors.white),
        label: Text(AppLocalizations.of(context).sos,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildWelcomeCard(Citizen citizen) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  offset: const Offset(0, 4),
                  blurRadius: 10,
                )
              ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).welcomeBack,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                citizen.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${AppLocalizations.of(context).inspectionID}: ${citizen.inspectionId}',
                style: GoogleFonts.caveat(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: ClipboardClipDecoration(isDark: isDark),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).quickActions,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio:
              1.5, // Increased to avoid overlapping and text clipping
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          children: [
            _buildActionCard(
              "Asset Map",
              Icons.map_rounded,
              Theme.of(context).primaryColor,
              () =>
                  Navigator.pushNamed(context, AppRoutes.assetSearch),
            ),
            _buildActionCard(
              "Regional Analytics",
              Icons.analytics_rounded,
              Colors.orange,
              () => Navigator.pushNamed(context, AppRoutes.regionalAnalytics),
            ),
            _buildActionCard(
              "Compliance Reports",
              Icons.assignment_rounded,
              Colors.green,
              () =>
                  Navigator.pushNamed(context, AppRoutes.complianceReports),
            ),
            _buildActionCard(
              "Transparency Portal",
              Icons.account_balance_rounded,
              Colors.purple,
              () => Navigator.pushNamed(context, AppRoutes.transparencyPortal),
            ),
            _buildActionCard(
              "Report Defect",
              Icons.report_problem_rounded,
              Colors.redAccent,
              () => Navigator.pushNamed(context, AppRoutes.publicSOS),
            ),
            _buildActionCard(
              "Project Status",
              Icons.construction_rounded,
              Colors.teal,
              () => Navigator.pushNamed(context, AppRoutes.assetSearch),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return MagicCard(
      onTap: onTap,
      color: color,
      padding: const EdgeInsets.symmetric(
          horizontal: 12, vertical: 16), // Custom smaller padding
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(height: 4),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsSection(List<InspectionAlert> alerts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).inspectionAlerts,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        ...alerts.map((alert) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ??
                    Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: alert.severityColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(alert.severityIcon,
                        color: alert.severityColor, size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          alert.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
