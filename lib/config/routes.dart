import 'package:flutter/material.dart';

// Auth Screens
import 'package:smc/screens/auth/secure_login_screen.dart';
import 'package:smc/screens/auth/otp_verification_screen.dart';

// Common Screens
import 'package:smc/screens/auth/role_selection_screen.dart';
import 'package:smc/screens/settings/universal_settings_screen.dart';
import 'package:smc/screens/profile/universal_profile_screen.dart';
import 'package:smc/screens/common/notifications_screen.dart';
import 'package:smc/screens/dashboard/immersive_dashboard.dart';

// Admin/National/State/City Screens
// import 'package:smc/screens/admin/admin_dashboard_screen.dart';
import 'package:smc/screens/admin/national_dashboard_screen.dart';
import 'package:smc/screens/admin/state_dashboard_screen.dart';
import 'package:smc/screens/admin/city_dashboard_screen.dart';
import 'package:smc/screens/inspector/inspector_dashboard_screen.dart';
import 'package:smc/screens/citizen/citizen_dashboard_screen.dart';
import 'package:smc/screens/admin/admin_command_center_screen.dart';
import 'package:smc/screens/admin/disease_surveillance_screen.dart';
import 'package:smc/screens/admin/hospital_status_screen.dart';
import 'package:smc/screens/admin/medicine_inventory_screen.dart';
import 'package:smc/screens/admin/emergency_alert_control_screen.dart';
import 'package:smc/screens/admin/user_management_screen.dart';
import 'package:smc/screens/admin/system_audit_logs_screen.dart';
import 'package:smc/screens/admin/system_health_screen.dart';
import 'package:smc/screens/admin/infra_risk_heatmap_screen.dart';
// import 'package:smc/screens/admin/hospital_resource_tracker_screen.dart'; // Removed unused
import 'package:smc/features/heatmap/immersive_heatmap_screen.dart';

// Hospital Screens
// import 'package:smc/screens/hospital/hospital_dashboard_screen.dart';
import 'package:smc/screens/hospital/hospital_patients_screen.dart';
import 'package:smc/screens/hospital/hospital_schedule_screen.dart';
import 'package:smc/screens/hospital/hospital_infra_screen.dart';
import 'package:smc/screens/hospital/infra_report_screen.dart';

// Field Worker Screens
// import 'package:smc/screens/field_worker/field_worker_home_screen.dart';
import 'package:smc/screens/field_worker/field_worker_visits_screen.dart';
// import 'package:smc/screens/field_worker/new_visit_form_screen.dart'; // Removed unused
import 'package:smc/screens/field_worker/symptom_checker_screen.dart';
import 'package:smc/screens/field_worker/field_worker_schedule_screen.dart';
import 'package:smc/screens/field_worker/household_visit_form_screen.dart';
import 'package:smc/screens/field_worker/field_worker_achievements_screen.dart';
import 'package:smc/screens/field_worker/visit_summary_screen.dart';

// Common Feature Screens
import 'package:smc/screens/common/patient_summary_screen.dart';

// Citizen Screens
import 'package:smc/screens/citizen/health_id_screen.dart';
import 'package:smc/screens/citizen/emergency_sos_screen.dart';
// import 'package:smc/screens/citizen/hygiene_report_screen.dart'; // Removed unused
// import 'package:smc/screens/citizen/vitals_analytics_screen.dart'; // Removed unused
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/screens/iot/iot_dashboard_screen.dart';
import 'package:smc/screens/iot/iot_device_detail_screen.dart';
// import 'package:smc/core/layout/adaptive_layout.dart';
// import 'package:smc/core/widgets/universal_drawer.dart';

/// App Routes Configuration
class AppRoutes {
  // Auth Routes
  static const String login = '/';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection = '/role-selection';
  static const String immersiveDashboard = '/immersive';
  static const String notifications = '/notifications';

  // Admin/Governance Routes
  static const String nationalDashboard = '/national-dashboard';
  static const String stateDashboard = '/state-dashboard';
  static const String cityDashboard = '/city-dashboard';
  static const String adminSurveillance = '/admin-surveillance';
  static const String adminInfrastructureStatus = '/admin-infra-status';
  static const String adminAssetInventory = '/admin-asset-inventory';
  static const String adminEmergencyAlert = '/admin-emergency-alert';
  static const String adminUserManagement = '/admin-user-management';
  static const String adminAuditLogs = '/admin-audit-logs';
  static const String adminCommandCenter = '/admin-command-center';
  static const String systemHealth = '/system-health';
  static const String riskHeatmap = '/infra-risk-heatmap';
  static const String immersiveHeatmap = '/immersive-heatmap';

  static const String adminProfile = '/admin-profile';

  // Field Inspector Routes
  static const String inspectorHome = '/inspector-home';
  static const String inspectorTasks = '/inspector-tasks';
  static const String newInspection = '/new-inspection';
  static const String inspectionCamera = '/inspection-camera';
  static const String inspectorAchievements = '/inspector-achievements';
  static const String inspectorProfile = '/inspector-profile';
  static const String inspectorSchedule = '/inspector-schedule';
  static const String inspectionSummary = '/inspection-summary';

  // Compliance Viewer / Public Routes
  static const String viewerHome = '/viewer-home';
  static const String assetSearch = '/asset-search';
  static const String assetDetail = '/asset-detail';
  static const String complianceReports = '/compliance-reports';
  static const String regionalAnalytics = '/regional-analytics';
  static const String transparencyPortal = '/transparency-portal';
  static const String publicSOS = '/public-sos';
  static const String viewerProfile = '/viewer-profile';
  static const String settings = '/settings';
  static const String profile = '/profile';

  // IoT Routes
  static const String iotDashboard = '/iot-dashboard';
  static const String iotDeviceDetail = '/iot-device-detail';

  // Common Feature Routes
  static const String patientSummary = '/patient-summary';
  static const String visitSummary = '/visit-summary';
}

/// Route Generator with Guard Logic
class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Navigating to: ${settings.name}');

    switch (settings.name) {
      // --- Auth Routes ---
      case AppRoutes.login:
        return MaterialPageRoute(
            builder: (_) => const SecureLoginScreen(), settings: settings);

      case AppRoutes.notifications:
        return _buildRoute(const NotificationsScreen(), settings);

      case AppRoutes.settings:
        return _buildRoute(const UniversalSettingsScreen(), settings);

      case AppRoutes.profile:
        return _buildRoute(const UniversalProfileScreen(), settings);

      case AppRoutes.newInspection:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => HouseholdVisitFormScreen(
              workerId: args['workerId'] ?? '',
              householdId: args['householdId'] ?? '',
              householdName: args['householdName'] ?? '',
            ),
          );
        }
        return _buildRoute(const HouseholdVisitFormScreen(workerId: '', householdId: '', householdName: ''), settings);
      case AppRoutes.inspectorAchievements:
        return MaterialPageRoute(
            builder: (_) => const FieldWorkerAchievementsScreen());
      case AppRoutes.roleSelection:
        return MaterialPageRoute(builder: (_) => const RoleSelectionScreen());
      case AppRoutes.immersiveDashboard:
        return MaterialPageRoute(builder: (_) => const ImmersiveDashboard());

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

      // --- Infrastructure/Government Routes ---
      case AppRoutes.nationalDashboard:
        return _buildRoute(const NationalDashboardScreen(), settings);

      case AppRoutes.adminSurveillance:
        return _buildRoute(const DiseaseSurveillanceScreen(), settings);

      case AppRoutes.adminInfrastructureStatus:
        return _buildRoute(const HospitalStatusScreen(), settings);

      case AppRoutes.adminAssetInventory:
        return _buildRoute(const MedicineInventoryScreen(), settings);

      case AppRoutes.adminEmergencyAlert:
        return _buildRoute(const EmergencyAlertControlScreen(), settings);

      case AppRoutes.adminUserManagement:
        return _buildRoute(const UserManagementScreen(), settings);

      case AppRoutes.adminAuditLogs:
        return _buildRoute(const SystemAuditLogsScreen(), settings);

      case AppRoutes.adminCommandCenter:
        return _buildRoute(const AdminCommandCenterScreen(), settings);

      case AppRoutes.systemHealth:
        return _buildRoute(const SystemHealthScreen(), settings);

      case AppRoutes.riskHeatmap:
        return _buildRoute(const InfraRiskHeatmapScreen(), settings);

      case AppRoutes.immersiveHeatmap:
        return _buildRoute(const ImmersiveHeatmapScreen(), settings);

      case AppRoutes.adminProfile:
        return _buildRoute(
          const UniversalProfileScreen(),
          settings,
        );

      // --- State/City Authority Routes ---
      case AppRoutes.stateDashboard:
        return _buildRoute(const StateDashboardScreen(), settings);

      case AppRoutes.cityDashboard:
        return _buildRoute(const CityDashboardScreen(), settings);

      case AppRoutes.assetSearch:
        return _buildRoute(const HospitalPatientsScreen(), settings);

      case AppRoutes.complianceReports:
        return _buildRoute(const InfraReportScreen(), settings);

      case AppRoutes.regionalAnalytics:
        return _buildRoute(const HospitalScheduleScreen(), settings);

      case AppRoutes.transparencyPortal:
        return _buildRoute(const HospitalInfraScreen(), settings);

      // --- Field Inspector Routes ---
      case AppRoutes.inspectorHome:
        return _buildRoute(const InspectorDashboardScreen(), settings);

      case AppRoutes.inspectorTasks:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            FieldWorkerVisitsScreen(
              fieldWorkerId: args['fieldWorkerId'] as String,
            ),
            settings,
          );
        }
        return _buildRoute(const FieldWorkerVisitsScreen(fieldWorkerId: ''), settings);


      case AppRoutes.inspectionCamera:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            SymptomCheckerScreen(
              householdMemberId: args['householdMemberId'] ?? 'unknown',
              memberName: args['memberName'] ?? 'Unknown Member',
            ),
            settings,
          );
        }
        return _buildRoute(const SymptomCheckerScreen(householdMemberId: '', memberName: ''), settings);


      case AppRoutes.inspectorProfile:
        return _buildRoute(const UniversalProfileScreen(), settings);

      case AppRoutes.inspectorSchedule:
        return _buildRoute(const FieldWorkerScheduleScreen(), settings);

      // --- Viewer / Public Routes ---
      case AppRoutes.viewerHome:
        return _buildRoute(const CitizenDashboardScreen(), settings);

      case AppRoutes.publicSOS:
        return _buildRoute(
          const CitizenSOSScreen(),
          settings,
        );

      case AppRoutes.assetDetail:
        return _buildRoute(const HealthIDScreen(), settings);

      case AppRoutes.viewerProfile:
        return _buildRoute(
          const UniversalProfileScreen(),
          settings,
        );


      // --- Common Feature Routes ---
      case AppRoutes.patientSummary:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            PatientSummaryScreen(
              patientId: args['patientId'] as String?,
              patientName: args['patientName'] as String?,
            ),
            settings,
          );
        }
        return _buildRoute(const PatientSummaryScreen(), settings);

      case AppRoutes.visitSummary:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            VisitSummaryScreen(
              visitId: args['visitId'] as String?,
              visitData: args['visitData'] as Map<String, dynamic>?,
            ),
            settings,
          );
        }
        return _buildRoute(const VisitSummaryScreen(), settings);

      // --- IoT Routes ---
      case AppRoutes.iotDashboard:
        return _buildRoute(const IoTDashboardScreen(), settings);

      case AppRoutes.iotDeviceDetail:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            IoTDeviceDetailScreen(
              deviceId: args['deviceId'] as String? ?? 'unknown',
              deviceName: args['deviceName'] as String? ?? 'Device',
              deviceType: args['deviceType'] as String? ?? 'Sensor',
            ),
            settings,
          );
        }
        return _errorRoute('Missing arguments for IoT Device Detail');

      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  static MaterialPageRoute _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
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
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                },
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              '$title Coming Soon',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
