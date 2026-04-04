import 'package:flutter/material.dart';

// Auth Screens
import 'package:smc/screens/auth/secure_login_screen.dart';
import 'package:smc/screens/auth/otp_verification_screen.dart';
import 'package:smc/screens/auth/role_selection_screen.dart';

// Common Screens
import 'package:smc/screens/settings/universal_settings_screen.dart';
import 'package:smc/screens/profile/universal_profile_screen.dart';
import 'package:smc/screens/common/notifications_screen.dart';

// Admin / Management Screens
import 'package:smc/screens/admin/national_dashboard_screen.dart';
import 'package:smc/screens/admin/state_dashboard_screen.dart';
import 'package:smc/screens/admin/city_dashboard_screen.dart';
import 'package:smc/screens/admin/admin_command_center_screen.dart';
import 'package:smc/screens/admin/defect_surveillance_screen.dart';
import 'package:smc/screens/admin/site_status_screen.dart';
import 'package:smc/screens/admin/infra_risk_heatmap_screen.dart';

// Inspector / Field Ops Screens
import 'package:smc/screens/inspector/inspector_dashboard_screen.dart';
import 'package:smc/screens/inspector/inspection_form_screen.dart';
import 'package:smc/screens/field_worker/defect_diagnostic_engine_screen.dart';
import 'package:smc/screens/field_worker/asset_audit_screen.dart';
import 'package:smc/screens/field_worker/field_worker_visits_screen.dart';

// Compliance / Public / Citizen Screens
import 'package:smc/screens/citizen/appointments_screen.dart'; // now InspectionsScreen
import 'package:smc/screens/citizen/medication_reminders_screen.dart'; // now MaintenanceRemindersScreen
import 'package:smc/screens/citizen/health_records_screen.dart'; // now AuditHistoryScreen
import 'package:smc/screens/citizen/health_id_screen.dart'; // now TacticalIDScreen
import 'package:smc/screens/citizen/asset_finder_screen.dart';
import 'package:smc/screens/citizen/emergency_sos_screen.dart';

// IoT Domain
import 'package:smc/screens/iot/iot_dashboard_screen.dart';

// Models
import 'package:smc/data/models/auth_models.dart';

/// App Routes Configuration
class AppRoutes {
  // Auth Routes
  static const String login = '/auth/login';
  static const String otpVerification = '/auth/otp-verification';
  static const String roleSelection = '/auth/role-selection';
  
  // High-level Domain Dashboards
  static const String immersiveDashboard = '/common/immersive';
  static const String notifications = '/common/notifications';
  static const String settings = '/common/settings';
  static const String profile = '/common/profile';

  // National/Super Admin Domain
  static const String nationalDashboard = '/admin/national-dashboard';
  static const String stateDashboard = '/admin/state-dashboard';
  static const String cityDashboard = '/admin/city-dashboard';
  static const String adminSurveillance = '/admin/surveillance';
  static const String adminInfrastructureStatus = '/admin/infra-status';
  static const String adminAssetInventory = '/admin/asset-inventory';
  static const String adminEmergencyAlert = '/admin/emergency-alert';
  static const String adminUserManagement = '/admin/user-management';
  static const String adminAuditLogs = '/admin/audit-logs';
  static const String adminCommandCenter = '/admin/command-center';
  static const String systemInspection = '/admin/system-inspection';
  static const String riskHeatmap = '/admin/risk-heatmap';
  static const String immersiveHeatmap = '/admin/immersive-heatmap';
  static const String adminProfile = '/admin/profile';

  // Field Inspector Domain
  static const String inspectorHome = '/inspector/dashboard';
  static const String inspectorTasks = '/inspector/tasks';
  static const String newInspection = '/inspector/new-inspection';
  static const String inspectorAchievements = '/inspector/achievements';
  static const String inspectorProfile = '/inspector/profile';
  static const String inspectorSchedule = '/inspector/schedule';
  static const String inspectionSummary = '/inspector/summary';

  // Compliance Viewer / Public Domain
  static const String viewerHome = '/public/dashboard';
  static const String assetSearch = '/public/asset-search';
  static const String assetDetail = '/public/asset-detail';
  static const String complianceReports = '/public/reports';
  static const String regionalAnalytics = '/public/analytics';
  static const String transparencyPortal = '/public/transparency';
  static const String publicSOS = '/public/sos';
  static const String viewerProfile = '/public/profile';
  
  // New Infrastructure Routes
  static const String inspections = '/public/inspections';
  static const String maintenanceReminders = '/public/reminders';
  static const String auditHistory = '/public/audit-history';
  static const String tacticalId = '/public/tactical-id';

  // IoT Domain
  static const String iotDashboard = '/iot/dashboard';
}

/// Route Generator with Guard Logic
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Navigating to: ${settings.name}');

    // Handle initial route alias
    final String routeName = settings.name == '/' ? AppRoutes.login : (settings.name ?? AppRoutes.login);

    switch (routeName) {
      // --- Auth Routes ---
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const SecureLoginScreen(), settings: settings);

      case AppRoutes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen(), settings: settings);

      case AppRoutes.otpVerification:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(
              identifier: args['identifier'] as String,
              role: args['role'] as UserRole,
            ),
          );
        }
        return _errorRoute('Missing arguments for OTP Verification');

      // --- Admin Domain ---
      case AppRoutes.nationalDashboard:
        return _buildRoute(const NationalDashboardScreen(), settings);
      case AppRoutes.stateDashboard:
        return _buildRoute(const StateDashboardScreen(), settings);
      case AppRoutes.cityDashboard:
        return _buildRoute(const CityDashboardScreen(), settings);
      case AppRoutes.adminCommandCenter:
        return _buildRoute(const AdminCommandCenterScreen(), settings);
      case AppRoutes.adminSurveillance:
        return _buildRoute(const DefectSurveillanceScreen(), settings);
      case AppRoutes.adminInfrastructureStatus:
        return _buildRoute(const SiteStatusScreen(), settings);
      case AppRoutes.riskHeatmap:
        return _buildRoute(const InfraRiskHeatmapScreen(), settings);

      // --- Inspector Domain ---
      case AppRoutes.inspectorHome:
        return _buildRoute(const InspectorDashboardScreen(), settings);
      case AppRoutes.newInspection:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => InspectionFormScreen(
              inspectorId: args['inspectorId'] ?? 'INS-402',
              assetId: args['assetId'],
            ),
          );
        }
        return _buildRoute(const InspectionFormScreen(inspectorId: 'INS-402'), settings);
      case '/inspector/diagnostics':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            DefectDiagnosticEngineScreen(
              assetComponentId: args['assetComponentId'] as String,
              componentName: args['componentName'] as String,
            ),
            settings,
          );
        }
        return _errorRoute('Missing arguments for Diagnostics');

      case '/inspector/audit':
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            AssetAuditScreen(
              inspectorId: args['inspectorId'] as String,
              assetId: args['assetId'] as String,
              assetName: args['assetName'] as String,
            ),
            settings,
          );
        }
        return _errorRoute('Missing arguments for Asset Audit');

      case AppRoutes.inspectorTasks:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(FieldWorkerVisitsScreen(fieldWorkerId: args['fieldWorkerId'] as String), settings);
        }
        return _buildRoute(const FieldWorkerVisitsScreen(fieldWorkerId: ''), settings);

      // --- Compliance / Public Domain ---
      case AppRoutes.inspections:
        return _buildRoute(const InspectionsScreen(), settings);
      case AppRoutes.maintenanceReminders:
        return _buildRoute(const MaintenanceRemindersScreen(), settings);
      case AppRoutes.auditHistory:
        return _buildRoute(const AuditHistoryScreen(), settings);
      case AppRoutes.tacticalId:
        return _buildRoute(const TacticalIDScreen(), settings);
      case AppRoutes.assetDetail:
        return _buildRoute(const AuditHistoryScreen(), settings);
      case AppRoutes.assetSearch:
        return _buildRoute(const AssetFinderScreen(), settings);
      case AppRoutes.publicSOS:
        return _buildRoute(const CitizenSOSScreen(), settings);

      // --- Common Routes ---
      case AppRoutes.notifications:
        return _buildRoute(const NotificationsScreen(), settings);
      case AppRoutes.settings:
        return _buildRoute(const UniversalSettingsScreen(), settings);
      case AppRoutes.profile:
      case AppRoutes.adminProfile:
      case AppRoutes.inspectorProfile:
      case AppRoutes.viewerProfile:
        return _buildRoute(const UniversalProfileScreen(), settings);
      
      case AppRoutes.iotDashboard:
        return _buildRoute(const IoTDashboardScreen(), settings);

      default:
        return _errorRoute('Domain route not found: ${settings.name}');
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Navigation Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(message, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                child: const Text('Return to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
