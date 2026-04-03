import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smc/data/seeders/comprehensive_data_seeder.dart';
import 'package:provider/provider.dart';
import 'package:smc/config/firebase_options.dart';
import 'package:smc/config/routes.dart';
import 'package:smc/core/theme/theme_service.dart';
import 'package:smc/core/providers/auth_provider.dart';
import 'package:smc/core/providers/notification_provider.dart';
import 'package:smc/core/providers/sync_provider.dart';
import 'package:smc/data/services/realtime_sync_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/core/theme/app_themes.dart';
import 'package:smc/core/localization/locale_service.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/services/device_info_service.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Device Capabilities
  final deviceCapabilities = await DeviceInfoService.getCapabilities();

  // Set Outfit as the default global font for the app
  GoogleFonts.config.allowRuntimeFetching = true;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase Initialized');

    // Run seeder if empty (Demo Mode)
    // Run seeder if empty (Demo Mode)
    try {
      final seeder = ComprehensiveDataSeeder();
      final citizensSnap = await FirebaseFirestore.instance
          .collection('citizens')
          .limit(1)
          .get();
      final requestsSnap = await FirebaseFirestore.instance
          .collection('blood_requests')
          .limit(1)
          .get();

      if (citizensSnap.docs.isEmpty || requestsSnap.docs.isEmpty) {
        debugPrint('Essential data missing, seeding demo data...');
        await seeder.seedAllData();
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        debugPrint('FIRESTORE RULES ERROR: "Permission Denied".');
      } else {
        debugPrint('Firestore Error: ${e.code} - ${e.message}');
      }
    }
  } catch (e) {
    debugPrint('Firebase Initialization/Seeding Error: $e');
  }

  runApp(SMCApp(deviceCapabilities: deviceCapabilities));
}

class SMCApp extends StatelessWidget {
  final DeviceCapabilities deviceCapabilities;

  const SMCApp({super.key, required this.deviceCapabilities});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<DeviceCapabilities>.value(value: deviceCapabilities),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => LocaleService()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // Use ChangeNotifierProxyProvider to sync UserProvider with AuthProvider
        ChangeNotifierProxyProvider<AuthProvider, UserProvider>(
          create: (_) => UserProvider(),
          update: (_, auth, userProvider) {
            if (auth.currentUser != null) {
              userProvider?.setUser(auth.currentUser!);
            }
            return userProvider!;
          },
        ),

        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => RealtimeSyncService()),
      ],
      child: Consumer2<ThemeService, LocaleService>(
        builder: (context, themeService, localeService, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'SMC - Smart Management Center',

            // Theme Configuration
            theme: AppThemes.lightTheme.copyWith(
              textTheme:
                  GoogleFonts.outfitTextTheme(AppThemes.lightTheme.textTheme),
            ),
            darkTheme: AppThemes.darkTheme.copyWith(
              textTheme:
                  GoogleFonts.outfitTextTheme(AppThemes.darkTheme.textTheme),
            ),
            themeMode: themeService.themeMode,

            // Localization configuration
            locale: localeService.locale,
            supportedLocales: LocaleService.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],

            initialRoute: AppRoutes.login,
            onGenerateRoute: RouteGenerator.generateRoute,

            // Global Builder for unified wrapping
            builder: (context, child) {
              return _GlobalWrapper(child: child!);
            },
          );
        },
      ),
    );
  }
}

class _GlobalWrapper extends StatelessWidget {
  final Widget child;
  const _GlobalWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: MediaQuery.of(context)
            .textScaler
            .clamp(minScaleFactor: 0.8, maxScaleFactor: 1.2),
      ),
      child: child,
    );
  }
}


