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

// Admin Screens
import 'package:smc/screens/admin/admin_dashboard_screen.dart';
import 'package:smc/screens/admin/admin_command_center_screen.dart';
import 'package:smc/screens/admin/disease_surveillance_screen.dart';
import 'package:smc/screens/admin/hospital_status_screen.dart';
import 'package:smc/screens/admin/medicine_inventory_screen.dart';
import 'package:smc/screens/admin/emergency_alert_control_screen.dart';
import 'package:smc/screens/admin/user_management_screen.dart';
import 'package:smc/screens/admin/system_audit_logs_screen.dart';
import 'package:smc/screens/admin/system_health_screen.dart';
import 'package:smc/screens/admin/solapur_heatmap_screen.dart';
import 'package:smc/screens/admin/hospital_resource_tracker_screen.dart';
import 'package:smc/features/heatmap/immersive_heatmap_screen.dart';

// Hospital Screens
import 'package:smc/screens/hospital/hospital_dashboard_screen.dart';
import 'package:smc/screens/hospital/hospital_patients_screen.dart';
import 'package:smc/screens/hospital/hospital_beds_screen.dart';
import 'package:smc/screens/hospital/hospital_schedule_screen.dart';
import 'package:smc/screens/hospital/hospital_infra_screen.dart';
import 'package:smc/screens/hospital/infra_report_screen.dart';

// Field Worker Screens
import 'package:smc/screens/field_worker/field_worker_home_screen.dart';
import 'package:smc/screens/field_worker/field_worker_visits_screen.dart';
import 'package:smc/screens/field_worker/new_visit_form_screen.dart';
import 'package:smc/screens/field_worker/symptom_checker_screen.dart';
import 'package:smc/screens/field_worker/field_worker_schedule_screen.dart';
import 'package:smc/screens/field_worker/household_visit_form_screen.dart';
import 'package:smc/screens/field_worker/field_worker_achievements_screen.dart';
import 'package:smc/screens/field_worker/visit_summary_screen.dart';

// Common Feature Screens
import 'package:smc/screens/common/patient_summary_screen.dart';

// Citizen Screens
import 'package:smc/screens/citizen/citizen_home_screen.dart';
import 'package:smc/screens/citizen/hospital_finder_screen.dart';
import 'package:smc/screens/citizen/health_id_screen.dart';
import 'package:smc/screens/citizen/appointments_screen.dart';
import 'package:smc/screens/citizen/health_records_screen.dart';
import 'package:smc/screens/citizen/vaccination_portal_screen.dart';
import 'package:smc/screens/citizen/emergency_sos_screen.dart';
import 'package:smc/screens/citizen/vaccination_card_screen.dart';
import 'package:smc/screens/citizen/family_ward_screen.dart';
import 'package:smc/screens/citizen/doctor_bot_screen.dart';
import 'package:smc/screens/citizen/medication_reminders_screen.dart'; // Added Meds
import 'package:smc/screens/citizen/blood_donation_screen.dart';
import 'package:smc/screens/citizen/hygiene_report_screen.dart';
import 'package:smc/screens/citizen/vitals_analytics_screen.dart';
import 'package:smc/screens/citizen/volunteer_network_screen.dart';
import 'package:smc/screens/citizen/medicine_inventory_screen.dart';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/screens/iot/iot_dashboard_screen.dart';
import 'package:smc/screens/iot/iot_device_detail_screen.dart';

/// App Routes Configuration
class AppRoutes {
  // Auth Routes
  static const String login = '/';
  static const String otpVerification = '/otp-verification';
  static const String roleSelection = '/role-selection';
  static const String immersiveDashboard = '/immersive';
  static const String notifications = '/notifications';

  // Admin Routes
  static const String adminDashboard = '/admin-dashboard';
  static const String adminSurveillance = '/admin-surveillance';
  static const String adminHospitalStatus = '/admin-hospital-status';
  static const String adminMedicineInventory = '/admin-medicine-inventory';
  static const String adminEmergencyAlert = '/admin-emergency-alert';
  static const String adminUserManagement = '/admin-user-management';
  static const String adminAuditLogs = '/admin-audit-logs';
  static const String adminCommandCenter = '/admin-command-center';
  static const String systemHealth = '/system-health';
  static const String adminHeatmap = '/admin-heatmap';
  static const String immersiveHeatmap = '/immersive-heatmap';

  static const String adminProfile = '/admin-profile';

  // Hospital Routes
  static const String hospitalDashboard = '/hospital-dashboard';
  static const String hospitalPatients = '/hospital-patients';
  static const String hospitalBeds = '/hospital-beds';
  static const String hospitalSchedule = '/hospital-schedule';
  static const String hospitalProfile = '/hospital-profile';
  static const String hospitalInfra = '/hospital-infra';
  static const String infraReport = '/infra-report';

  // Field Worker Routes
  static const String fieldWorkerHome = '/field-worker-home';
  static const String fieldWorkerVisits = '/field-worker-visits';
  static const String fieldWorkerNewVisit = '/field-worker-new-visit';
  static const String fieldWorkerHouseholdVisit =
      '/field-worker-household-visit';
  static const String fieldWorkerAchievements = '/field-worker-achievements';
  static const String fieldWorkerAssessment = '/field-worker-assessment';
  static const String fieldWorkerProfile = '/field-worker-profile';
  static const String fieldWorkerSchedule = '/field-worker-schedule';
  static const String householdVisitForm = '/household-visit-form';

  // Citizen Routes
  static const String citizenHome = '/citizen-home';
  static const String citizenSOS = '/citizen-sos';
  static const String citizenFacilitySearch = '/citizen-facility-search';
  static const String citizenHealthID = '/citizen-health-id';
  static const String citizenHealthRecords = '/citizen-health-records';
  static const String citizenAppointments = '/citizen-appointments';
  static const String citizenVaccination = '/citizen-vaccination';
  static const String citizenVaccinationCard = '/citizen-vaccination-card';
  static const String citizenProfile = '/citizen-profile';
  static const String familyWard = '/family-ward'; // Added Family Ward Route
  static const String doctorBot = '/doctor-bot'; // Added DoctorBot Route
  static const String medications = '/medications'; // Added Meds Route
  static const String settings = '/settings';
  static const String profile = '/profile';

  // Enhanced Features
  static const String bloodDonation = '/blood-donation';
  static const String hygieneReport = '/hygiene-report';
  static const String resourceTracker = '/resource-tracker';
  static const String vitalsAnalytics = '/vitals-analytics';
  static const String volunteerNetwork = '/volunteer-network';
  static const String citizenMedicineInventory = '/citizen-medicine-inventory';

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

      case AppRoutes.fieldWorkerHouseholdVisit:
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
        return _errorRoute('Missing arguments for Household Visit Form');
      case AppRoutes.fieldWorkerAchievements:
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

      // --- Admin Routes ---
      case AppRoutes.adminDashboard:
        return _buildRoute(const AdminDashboardScreen(), settings);

      case AppRoutes.adminSurveillance:
        return _buildRoute(const DiseaseSurveillanceScreen(), settings);

      case AppRoutes.adminHospitalStatus:
        return _buildRoute(const HospitalStatusScreen(), settings);

      case AppRoutes.adminMedicineInventory:
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

      case AppRoutes.adminHeatmap:
        return _buildRoute(const SolapurHeatmapScreen(), settings);

      case AppRoutes.immersiveHeatmap:
        return _buildRoute(const ImmersiveHeatmapScreen(), settings);

      case AppRoutes.adminProfile:
        return _buildRoute(
          const UniversalProfileScreen(),
          settings,
        );

      // --- Hospital Routes ---
      case AppRoutes.hospitalDashboard:
        return _buildRoute(const HospitalDashboardScreen(), settings);

      case AppRoutes.hospitalPatients:
        return _buildRoute(const HospitalPatientsScreen(), settings);

      case AppRoutes.hospitalBeds:
        return _buildRoute(const HospitalBedsScreen(), settings);

      case AppRoutes.hospitalSchedule:
        return _buildRoute(const HospitalScheduleScreen(), settings);

      case AppRoutes.hospitalProfile:
        return _buildRoute(const UniversalProfileScreen(), settings);

      case AppRoutes.hospitalInfra:
        return _buildRoute(const HospitalInfraScreen(), settings);

      case AppRoutes.infraReport:
        return _buildRoute(const InfraReportScreen(), settings);

      // --- Field Worker Routes ---
      case AppRoutes.fieldWorkerHome:
        return _buildRoute(const FieldWorkerHomeScreen(), settings);

      case AppRoutes.fieldWorkerVisits:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            FieldWorkerVisitsScreen(
              fieldWorkerId: args['fieldWorkerId'] as String,
            ),
            settings,
          );
        }
        return _errorRoute('Missing fieldWorkerId for Visits');

      case AppRoutes.fieldWorkerNewVisit:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            NewVisitFormScreen(
              fieldWorkerId: (args['fieldWorkerId'] as String?) ?? '',
              householdId: args['householdId'] as String?,
            ),
            settings,
          );
        }
        return _errorRoute('Missing fieldWorkerId for New Visit');

      case AppRoutes.fieldWorkerAssessment:
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
        return _errorRoute('Missing arguments for Assessment');

      case AppRoutes.householdVisitForm:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return _buildRoute(
            HouseholdVisitFormScreen(
              workerId: args['workerId'] as String,
              householdId: args['householdId'] as String,
              householdName:
                  args['householdName'] as String? ?? 'Unknown Household',
            ),
            settings,
          );
        }
        return _errorRoute('Missing arguments for Household Visit Form');

      case AppRoutes.fieldWorkerProfile:
        return _buildRoute(const UniversalProfileScreen(), settings);

      case AppRoutes.fieldWorkerSchedule:
        return _buildRoute(const FieldWorkerScheduleScreen(), settings);

      // --- Citizen Routes ---
      case AppRoutes.citizenHome:
        return _buildRoute(const CitizenHomeScreen(), settings);

      case AppRoutes.citizenSOS:
        return _buildRoute(
          const CitizenSOSScreen(),
          settings,
        );

      case AppRoutes.citizenFacilitySearch:
        return _buildRoute(const HospitalFinderScreen(), settings);

      case AppRoutes.citizenHealthID:
        return _buildRoute(const HealthIDScreen(), settings);

      case AppRoutes.citizenHealthRecords:
        return _buildRoute(const HealthRecordsScreen(), settings);

      case AppRoutes.citizenAppointments:
        return _buildRoute(const AppointmentsScreen(), settings);

      case AppRoutes.citizenVaccination:
        return _buildRoute(const VaccinationPortalScreen(), settings);

      case AppRoutes.citizenVaccinationCard:
        return _buildRoute(const VaccinationCardScreen(), settings);

      case AppRoutes.citizenProfile:
        return _buildRoute(
          const UniversalProfileScreen(),
          settings,
        );

      case AppRoutes.familyWard:
        return _buildRoute(const FamilyWardScreen(), settings);

      case AppRoutes.doctorBot: // Added DoctorBot Handler
        return _buildRoute(const DoctorBotScreen(), settings);

      case AppRoutes.medications: // Added Meds Handler
        return _buildRoute(const MedicationRemindersScreen(), settings);

      case AppRoutes.bloodDonation:
        return _buildRoute(const BloodDonationScreen(), settings);

      case AppRoutes.hygieneReport:
        return _buildRoute(const HygieneReportScreen(), settings);

      case AppRoutes.resourceTracker:
        return _buildRoute(const HospitalResourceTrackerScreen(), settings);

      case AppRoutes.vitalsAnalytics:
        return _buildRoute(const VitalsAnalyticsScreen(), settings);

      case AppRoutes.volunteerNetwork:
        return _buildRoute(const VolunteerNetworkScreen(), settings);

      case AppRoutes.citizenMedicineInventory:
        return _buildRoute(const CitizenMedicineInventoryScreen(), settings);

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
