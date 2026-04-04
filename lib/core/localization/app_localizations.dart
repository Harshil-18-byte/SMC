import 'package:flutter/material.dart';
import 'package:smc/core/localization/languages/en.dart';
import 'package:smc/core/localization/languages/hi.dart';
import 'package:smc/core/localization/languages/mr.dart';

/// App Localizations - Manages translations for the app
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'hi': hi,
    'mr': mr,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Chatbot
  String get chatHello => translate('chat_hello');
  String get chatThankYou => translate('chat_thank_you');
  String get chatBye => translate('chat_bye');
  String get chatWhoAreYou => translate('chat_who_are_you');

  // Fallbacks
  String get fallback1 => translate('fallback_1');
  String get fallback2 => translate('fallback_2');
  String get fallback3 => translate('fallback_3');
  String get fallback4 => translate('fallback_4');

  // Medical Responses
  String get heartAttack => translate('heart_attack');
  String get stroke => translate('stroke');
  String get suicide => translate('suicide');
  String get accident => translate('accident');
  String get choking => translate('choking');
  String get burn => translate('burn');
  String get poison => translate('poison');
  String get headache => translate('headache');
  String get fever => translate('fever');
  String get cough => translate('cough');
  String get cold => translate('cold');
  String get stomach => translate('stomach');
  String get dehydration => translate('dehydration');
  String get dengue => translate('dengue');
  String get malaria => translate('malaria');
  String get covid => translate('covid');
  String get tuberculosis => translate('tuberculosis');
  String get chickenpox => translate('chickenpox');
  String get hepatitis => translate('hepatitis');
  String get hiv => translate('hiv');
  String get typhoid => translate('typhoid');
  String get diabetes => translate('diabetes');
  String get bloodPressure => translate('blood_pressure');
  String get asthma => translate('asthma');
  String get cancer => translate('cancer');
  String get thyroid => translate('thyroid');
  String get pregnancy => translate('pregnancy');
  String get period => translate('period');
  String get pcos => translate('pcos');
  String get vaccine => translate('vaccine');
  String get childNutrition => translate('child_nutrition');
  String get anxiety => translate('anxiety');
  String get depression => translate('depression');
  String get acne => translate('acne');
  String get hairLoss => translate('hair_loss');
  String get diet => translate('diet');
  String get sleep => translate('sleep');
  String get exercise => translate('exercise');
  String get appointment => translate('appointment');
  String get botSiteInfo => translate('bot_site_info');
  String get schemes => translate('schemes');

  // Common translations
  String get appName => translate('app_name');
  String get welcome => translate('welcome');
  String get login => translate('login');
  String get logout => translate('logout');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get search => translate('search');
  String get filter => translate('filter');
  String get back => translate('back');
  String get next => translate('next');
  String get submit => translate('submit');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get warning => translate('warning');
  String get info => translate('info');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get close => translate('close');
  String get refresh => translate('refresh');
  String get retry => translate('retry');
  String get language => translate('language');
  String get theme => translate('theme');
  String get darkMode => translate('dark_mode');
  String get lightMode => translate('light_mode');

  // Auth
  String get phoneNumber => translate('phone_number');
  String get enterPhoneNumber => translate('enter_phone_number');
  String get verifyOTP => translate('verify_otp');
  String get enterOTP => translate('enter_otp');
  String get resendOTP => translate('resend_otp');
  String get selectRole => translate('select_role');

  // Roles
  String get admin => translate('admin');
  String get site => translate('site');
  String get fieldWorker => translate('field_worker');
  String get citizen => translate('citizen');

  // Dashboard
  String get dashboard => translate('dashboard');
  String get overview => translate('overview');
  String get statistics => translate('statistics');
  String get reports => translate('reports');
  String get analytics => translate('analytics');

  // Citizen
  String get inspectionID => translate('inspection_id');
  String get inspectionRecords => translate('inspection_records');
  String get appointments => translate('appointments');
  String get vaccination => translate('vaccination');
  String get emergencySOS => translate('emergency_sos');
  String get siteFinder => translate('site_finder');

  // Field Worker
  String get visits => translate('visits');
  String get newVisit => translate('new_visit');
  String get schedule => translate('schedule');
  String get symptomChecker => translate('symptom_checker');

  // Admin
  String get surveillance => translate('surveillance');
  String get siteStatus => translate('site_status');
  String get medicineInventory => translate('medicine_inventory');
  String get emergencyAlerts => translate('emergency_alerts');
  String get userManagement => translate('user_management');
  String get auditLogs => translate('audit_logs');
  String get systemInspection => translate('system_inspection');

  // Site
  String get assets => translate('assets');
  String get beds => translate('beds');
  String get bedAvailability => translate('bed_availability');

  // Messages
  String get noDataAvailable => translate('no_data_available');
  String get somethingWentWrong => translate('something_went_wrong');
  String get tryAgainLater => translate('try_again_later');
  String get dataLoadedSuccessfully => translate('data_loaded_successfully');

  // Citizen Home
  String get welcomeBack => translate('welcome_back');
  String get quickActions => translate('quick_actions');
  String get inspectionAlerts => translate('inspection_alerts');
  String get sos => translate('sos');

  // Drawer / Navigation
  String get menuMainMenu => translate('menu_main_menu');
  String get menuDashboard => translate('menu_dashboard');
  String get menuProfile => translate('menu_profile');
  String get menuMagic => translate('menu_magic');
  String get menuImpact => translate('menu_impact');
  String get menuSettings => translate('menu_settings');

  // Admin Dashboard
  String get switchDomain => translate('switch_domain');
  String get seedData => translate('seed_data');
  String get geospatialViz => translate('geospatial_viz');
  String get density => translate('density');
  String get low => translate('low');
  String get high => translate('high');
  String get dispatchResponse => translate('dispatch_response');
  String get cases => translate('cases');
  String get recovered => translate('recovered');
  String get filterOptionsSoon => translate('filter_options_soon');
  String get updatedJustNow => translate('updated_just_now');

  // Site Dashboard
  String get siteStaff => translate('site_staff');
  String get commandCenter => translate('command_center'); // reusing existing
  String get liveSiteStatus => translate('live_site_status');
  String get viewStaffSchedule => translate('view_staff_schedule');
  String get bedManagement => translate('bed_management');
  String get viewAll => translate('view_all');
  String get icuBeds => translate('icu_beds');
  String get generalBeds => translate('general_beds');
  String get assetQueue => translate('asset_queue');
  String get manage => translate('manage');
  String get waitingForAssessment => translate('waiting_for_assessment');

  // Field Worker Dashboard
  String get unknownLocation => translate('unknown_location');
  String get lastSync => translate('last_sync');
  String get never => translate('never');
  String get tasks => translate('tasks');
  String get history => translate('history');
  String get viewDetails => translate('view_details');
  String get startVisit => translate('start_visit');
  String get currentLocation => translate('current_location');
  String get home => translate('home');
  String get alerts => translate('alerts');
  String get selectDetails => translate('select_details');
  String get exitAppTitle => translate('exit_app_title');
  String get exitAppMessage => translate('exit_app_message');
  String get exit => translate('exit');
  String get weekendMessage => translate('weekend_message');
  String get morningWaitMessage => translate('morning_wait_message');
  String get afternoonCaughtUpMessage =>
      translate('afternoon_caught_up_message');
  String get eveningGoodWorkMessage => translate('evening_good_work_message');
  String get routeOptimized => translate('route_optimized'); // Added

  // Domain Selection
  String get selectDomain => translate('select_domain');
  String get directAccessMessage => translate('direct_access_message');
  String get adminDomainSubtitle => translate('admin_domain_subtitle');
  String get fwDomainSubtitle => translate('fw_domain_subtitle');
  String get sitePortal => translate('site_portal');
  String get siteDomainSubtitle => translate('site_domain_subtitle');
  String get citizenPortal => translate('citizen_portal');
  String get citizenDomainSubtitle => translate('citizen_domain_subtitle');
  String get devModeLabel => translate('dev_mode_label');

  // Citizen Features
  String get familyWard => translate('family_ward');
  String get aiDoctor => translate('ai_doctor');
  String get medsReminders => translate('meds_reminders');

  // Sync Messages
  String get offlineModeMsg => translate('offline_mode_msg');
  String get syncSuccessMsg => translate('sync_success_msg');
  String get syncingMsg => translate('syncing_msg');
  String get connectingMsg => translate('connecting_msg');
  String get fetchingTasksMsg => translate('fetching_tasks_msg');
  String get syncingRecordsMsg => translate('syncing_records_msg');
  String get gettingReadyMsg => translate('getting_ready_msg');

  // Generic
  String get taskDetails => translate('task_details');
  String get assigned => translate('assigned');
  String get noTasksMsg => translate('no_tasks_msg');
  String get optimizeRoute => translate('optimize_route');

  // Seeding
  String get seedingCsvMsg => translate('seeding_csv_msg');
  String get csvSeededMsg => translate('csv_seeded_msg');
  String get testDataSeededMsg => translate('test_data_seeded_msg');
  String get errorSeedingMsg => translate('error_seeding_msg');
  String get dispatchAlertMsg => translate('dispatch_alert_msg');

  // Immersive Dashboard
  String get magicDeck => translate('magic_deck');
  String get cityInspectionIndex => translate('city_inspection_index');
  String get aiInsights => translate('ai_insights');
  String get cityVitalsHeatmap => translate('city_vitals_heatmap');
  String get launch3dAnalytics => translate('launch_3d_analytics');
  String get tapToExplore => translate('tap_to_explore');
  String get exceptional => translate('exceptional');
  String get stableStatus => translate('stable');
  String get monitoring => translate('monitoring');
  String get vitality => translate('vitality');
  String get air => translate('air');
  String get unknownUser => translate('unknown_user');
  String get standardUser => translate('standard_user');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'mr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}


