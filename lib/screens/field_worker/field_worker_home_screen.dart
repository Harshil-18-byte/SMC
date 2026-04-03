import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // Added Import
import 'package:smc/data/services/realtime_sync_service.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/services/firestore_service.dart';
import 'package:smc/data/models/field_worker.dart';
import 'package:smc/data/models/task.dart';
import 'package:smc/data/services/offline_service.dart';
import 'package:smc/data/services/route_optimizer_service.dart';
import 'package:smc/config/routes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:smc/core/i18n/localized_text.dart';
import 'package:smc/core/i18n/cultural_context.dart';
import 'package:smc/core/utils/solapur_location_utils.dart';
import 'package:smc/core/ui/hand_drawn_illustration.dart';
import 'package:smc/core/ui/friendly_error_handler.dart';
import 'package:smc/core/ui/imperfect_shapes.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';

import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/sync_status_indicator.dart';
import 'package:smc/core/services/permissions_service.dart';
import 'package:smc/core/layout/adaptive_layout.dart';
import 'package:smc/core/theme/universal_theme.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/visuals/medical_textures.dart';
import 'package:smc/core/visuals/medical_buttons.dart';
import 'package:smc/core/visuals/medical_loaders.dart';
import 'package:smc/core/visuals/medical_modals.dart';
import 'package:google_fonts/google_fonts.dart';

/// Field Worker Home Screen
/// Task management interface for healthcare field workers
class FieldWorkerHomeScreen extends StatefulWidget {
  const FieldWorkerHomeScreen({super.key});

  @override
  State<FieldWorkerHomeScreen> createState() => _FieldWorkerHomeScreenState();
}

class _FieldWorkerHomeScreenState extends State<FieldWorkerHomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final OfflineService _offlineService = OfflineService();
  final RouteOptimizerService _routeOptimizer = RouteOptimizerService();

  // State variables
  bool _isLoading = true;
  Object? _error;
  FieldWorker? _worker;
  List<Task> _tasks = [];
  int _pendingSyncCount = 0;
  bool _isSyncing = false; // Sync UI State
  int _totalSyncItems = 0; // Sync UI State

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    try {
      await _offlineService.init();
    } catch (e) {
      debugPrint('⚠️ Offline service init failed (non-fatal): $e');
    }
    _loadData();
  }

  /// Load field worker data and tasks
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Request permissions (non-fatal if denied)
      try {
        await PermissionsService.requestAllPermissions();
      } catch (e) {
        debugPrint('⚠️ Permission request failed (non-fatal): $e');
      }

      // Basic connectivity check
      bool isOnline = false;
      try {
        var connectivityResult = await (Connectivity().checkConnectivity());
        isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.wifi);
      } catch (e) {
        debugPrint('⚠️ Connectivity check failed, assuming online: $e');
        isOnline = true; // Assume online and let Firestore fail gracefully
      }

      // Load field worker profile
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final workerId = userProvider.currentUser?.id ?? 'worker_1';

      if (isOnline) {
        // Trigger background sync of offline data (fire and forget)
        _syncPendingData();

        // ONLINE MODE: Fetch worker from Firestore (non-fatal)
        try {
          final workerData = await _firestoreService.readDocument(
            collection: 'field_workers',
            docId: workerId,
          );

          if (workerData != null) {
            _worker = FieldWorker.fromMap(workerData, workerId);
            await _offlineService.cacheWorkerProfile(_worker!);
          }
        } catch (e) {
          debugPrint('⚠️ Failed to load worker profile from Firestore: $e');
        }

        // Fallback: try offline cache, then demo data
        _worker ??= _offlineService.getCachedWorkerProfile();
        _worker ??= FieldWorker(
          id: workerId,
          name: 'Field Worker',
          avatarUrl: '',
          currentLocation: 'Solapur, Maharashtra',
          lastSync: DateTime.now(),
          sector: 'Sector 4',
        );

        // Fetch tasks from Firestore (non-fatal)
        try {
          final tasksData = await _firestoreService.getCollection(
            collection: 'tasks',
            orderBy: 'assignedDate',
            descending: true,
          );

          _tasks = tasksData
              .map((data) => Task.fromMap(data, data['id'] ?? ''))
              .toList();

          // Cache for offline use
          await _offlineService.cacheTasks(_tasks);
        } catch (e) {
          debugPrint('⚠️ Failed to load tasks from Firestore: $e');
          // Try loading from cache
          try {
            _tasks = _offlineService.getCachedTasks();
          } catch (_) {
            _tasks = [];
          }
        }
      } else {
        // OFFLINE MODE: Load from Cache
        try {
          _tasks = _offlineService.getCachedTasks();
          _worker = _offlineService.getCachedWorkerProfile();
        } catch (e) {
          debugPrint('⚠️ Failed to load cached data: $e');
          _tasks = [];
        }

        // Fallback dummy if not cached
        _worker ??= FieldWorker(
          id: workerId,
          name: 'Field Worker',
          avatarUrl: '',
          currentLocation: 'Solapur, Maharashtra',
          lastSync: DateTime.now(),
          sector: 'Sector 4',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).offlineModeMsg),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Update Sync Count (non-fatal)
      try {
        _pendingSyncCount = _offlineService.getPendingSyncCount();
      } catch (_) {
        _pendingSyncCount = 0;
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('❌ Critical error in _loadData: $e');
      // Even on critical error, try to show SOMETHING instead of error screen
      if (mounted) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final workerId = userProvider.currentUser?.id ?? 'worker_1';
        _worker ??= FieldWorker(
          id: workerId,
          name: 'Field Worker',
          avatarUrl: '',
          currentLocation: 'Solapur, Maharashtra',
          lastSync: DateTime.now(),
          sector: 'Sector 4',
        );
        _tasks = [];
        setState(() {
          _isLoading = false;
          _error = null; // Don't show error screen, show empty dashboard
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not load data. Pull down to retry.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Sync pending offline data with UI updates
  Future<void> _syncPendingData() async {
    final pendingItems = await _offlineService.getSyncQueue();
    if (pendingItems.isEmpty) return;

    setState(() {
      _isSyncing = true;
      _totalSyncItems = pendingItems.length;
      _pendingSyncCount = pendingItems.length;
    });

    final syncService =
        Provider.of<RealtimeSyncService>(context, listen: false);

    int successCount = 0;
    // Iterate through items
    List<int> successfulIndices = [];
    for (int i = 0; i < pendingItems.length; i++) {
      final item = pendingItems[i];
      try {
        if (item['type'] == 'visit_record') {
          final data = item['data'] as Map<String, dynamic>;

          // Handle Offline Photos
          List<File> photosToUpload = [];
          if (data['photoUrls'] != null) {
            final urls = List<String>.from(data['photoUrls']);
            for (final url in urls) {
              // Check if it's a local file path (not http)
              if (!url.startsWith('http') && !url.startsWith('https')) {
                final file = File(url);
                if (await file.exists()) {
                  photosToUpload.add(file);
                }
              }
            }
          }

          await syncService.uploadVisitData(
            workerId: data['fieldWorkerId'],
            householdId: data['householdId'],
            formData: data,
            photos: photosToUpload.isNotEmpty ? photosToUpload : null,
          );
          successfulIndices.add(i);
          successCount++;

          if (mounted) {
            setState(() {
              _pendingSyncCount = pendingItems.length - successCount;
            });
          }
        }
      } catch (e) {
        debugPrint('Error syncing item $i: $e');
        // Continue to next item without removing this one
      }
    }

    // Remove successful items from queue in reverse order to maintain indices
    for (final index in successfulIndices.reversed) {
      await _offlineService.deleteQueueItem(index);
    }

    if (mounted) {
      setState(() {
        _isSyncing = false;
        _pendingSyncCount = 0;
      });

      if (successCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${AppLocalizations.of(context).syncSuccessMsg} ($successCount)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleOptimizeRoute() async {
    setState(() => _isLoading = true); // Show loading briefly

    double currentLat = 17.6599; // Default Solapur Center
    double currentLng = 75.9064;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (serviceEnabled) {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          Position position = await Geolocator.getCurrentPosition();
          currentLat = position.latitude;
          currentLng = position.longitude;
        }
      }
    } catch (e) {
      debugPrint('Error getting location for optimization: $e');
      // Fallback to default
    }

    final optimizedTasks = _routeOptimizer.optimizeRoute(
      _tasks,
      currentLat,
      currentLng,
    );

    setState(() {
      _tasks = optimizedTasks;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).routeOptimized),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_error != null) {
      return Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
        body: FriendlyErrorHandler(error: _error!, onRetry: _loadData),
      );
    }

    return AdaptiveLayout(
      compactBody: _buildDashboardBody(context, isDark),
      mediumBody: _buildDashboardBody(context, isDark),
      expandedBody: _buildDashboardBody(context, isDark),
      largeBody: _buildDashboardBody(context, isDark),
    );
  }

  Widget _buildDashboardBody(BuildContext context, bool isDark) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: const UniversalDrawer(),
      body: PaperTextureBackground(
        isDark: isDark,
        child: DashboardBackHandler(
          dashboardName: 'Field Worker Dashboard',
          child: SafeArea(
            bottom: false,
            child: _isLoading
                ? Center(
                    child: ECGLoader(
                      message: AppLocalizations.of(context).connectingMsg,
                    ),
                  )
                : Column(
                    children: [
                      _buildAppBar(isDark),
                      _buildSyncProgressBar(), // Persistent Sync UI
                      if (CulturalContext.getContextualBanner() != null)
                        Container(
                          width: double.infinity,
                          color: Colors.orange.shade100,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            CulturalContext.getContextualBanner()!,
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: _loadData,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(
                              horizontal: UniversalTheme.getSpacing(
                                  context, SpacingSize.md),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 16),
                                _buildLocationCard(isDark),
                                const SizedBox(height: 12),
                                _buildTasksHeader(isDark),
                                const SizedBox(height: 12),
                                _buildTasksList(isDark),
                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      floatingActionButton: RubberStampButton(
        width: 160,
        height: 52,
        onTap: () {
          if (_worker != null) {
            Navigator.pushNamed(
              context,
              AppRoutes.fieldWorkerNewVisit,
              arguments: {'fieldWorkerId': _worker!.id},
            );
          }
        },
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_task_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context).newVisit.toUpperCase(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Persistent Sync Progress Bar
  Widget _buildSyncProgressBar() {
    if (!_isSyncing) return const SizedBox.shrink();

    final progress =
        _totalSyncItems > 0 ? 1.0 - (_pendingSyncCount / _totalSyncItems) : 0.0;

    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        color: const Color(0xFFE3F2FD),
        child: Row(children: [
          const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  AppLocalizations.of(context).syncingMsg,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800]),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.blue[100],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 4,
                ),
              ])),
          const SizedBox(width: 12),
          Text(
            "${_totalSyncItems - _pendingSyncCount}/$_totalSyncItems",
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800]),
          )
        ]));
  }

  /// App Bar with profile
  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.98),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: () {
              if (_worker != null) {
                Navigator.pushNamed(
                  context,
                  AppRoutes.fieldWorkerProfile,
                  arguments: {'workerId': _worker!.id},
                );
              }
            },
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: ShapeDecoration(
                    shape: ImperfectCircleBorder(
                      side: BorderSide(
                        color: const Color(0xFF137fec).withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    image: _worker?.avatarUrl.isNotEmpty == true
                        ? DecorationImage(
                            image: NetworkImage(_worker!.avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: const Color(0xFF137fec).withValues(alpha: 0.2),
                  ),
                  child: _worker?.avatarUrl.isEmpty ?? true
                      ? Center(
                          child: Text(
                            _worker?.name.substring(0, 1).toUpperCase() ?? 'U',
                            style: const TextStyle(
                              color: Color(0xFF137fec),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
                if (_worker?.isOnline ?? false)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: ShapeDecoration(
                        color: const Color(0xFF10B981),
                        shape: ImperfectCircleBorder(
                          side: BorderSide(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Welcome Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    LocalizedText.greeting(TimeOfDay.now()),
                    style: TextStyle(
                      fontSize: 11, // Reduced
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _worker?.name ?? 'Field Worker',
                    style: TextStyle(
                      fontSize: 16, // Reduced from 18
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF111418),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SyncStatusIndicator(compact: true, pendingCount: _pendingSyncCount),
          const SizedBox(width: 4),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
              color: isDark ? Colors.white : const Color(0xFF111418),
              tooltip: 'Menu',
            ),
          ),
        ],
      ),
    );
  }

  /// Location Card
  Widget _buildLocationCard(bool isDark) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F22) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF2D3135) : const Color(0xFFD6CFC7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).currentLocation.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _worker?.currentLocation ??
                              AppLocalizations.of(context).unknownLocation,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : const Color(0xFF2C2825),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLocalizations.of(context).lastSync}: ${_worker?.getLastSyncText() ?? AppLocalizations.of(context).never}',
                          style: GoogleFonts.caveat(
                            fontSize: 16,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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

  Widget _buildTasksHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).tasks,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111418),
                ),
              ),
              IconButton(
                onPressed: _handleOptimizeRoute,
                tooltip: AppLocalizations.of(context).optimizeRoute,
                icon: const Icon(Icons.route_outlined, color: Colors.green),
              ),
            ],
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.fieldWorkerSchedule);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    AppLocalizations.of(context).schedule,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: const Color(0xFF137fec),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.fieldWorkerVisits,
                      arguments: {'fieldWorkerId': _worker?.id ?? ''},
                    );
                  },
                  icon: const Icon(Icons.history, size: 16),
                  label: Text(
                    AppLocalizations.of(context).history,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: const Color(0xFF137fec),
                  ),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.fieldWorkerAchievements,
                    );
                  },
                  icon: const Icon(Icons.emoji_events_rounded, size: 16),
                  label: Text(
                    'Achievements',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tasks List
  Widget _buildTasksList(bool isDark) {
    if (_tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              const CustomIllustration(type: 'no_visits', size: 200),
              const SizedBox(height: 16),
              Text(
                _getContextualEmptyMessage(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _tasks.map((task) => _buildTaskCard(task, isDark)).toList(),
      ),
    );
  }

  /// Task Card
  Widget _buildTaskCard(Task task, bool isDark) {
    final priorityStyle = task.getPriorityStyle();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F22) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF2D3135) : const Color(0xFFD6CFC7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Task Details
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Priority Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? priorityStyle.darkBgColor
                        : priorityStyle.bgColor,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark
                          ? priorityStyle.darkTextColor.withValues(alpha: 0.3)
                          : priorityStyle.textColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    task.priority.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark
                          ? priorityStyle.darkTextColor
                          : priorityStyle.textColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Household ID and Location
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.householdId,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF2C2825),
                      ),
                    ),
                    if (task.latitude != 0.0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          SolapurLocationUtils.getHumanReadableLocation(
                                  task.latitude, task.longitude)
                              .replaceAll('\n', ', '),
                          style: GoogleFonts.caveat(
                            fontSize: 15,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                Text(
                  task.description,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                // View Details Button
                RubberStampButton(
                  height: 40,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: isDark
                      ? const Color(0xFF283039)
                      : const Color(0xFFF6F7F8),
                  onTap: () {
                    _viewTaskDetails(task);
                  },
                  child: Text(
                    AppLocalizations.of(context).viewDetails.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: isDark ? Colors.white : const Color(0xFF2C2825),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Task Image
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: task.imageUrl.isNotEmpty
                ? Image.network(
                    task.imageUrl,
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                : _buildPlaceholderImage(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 100,
      height: 120,
      color: Colors.grey[300],
      child: Icon(Icons.image, size: 40, color: Colors.grey[500]),
    );
  }

  /// View task details
  void _viewTaskDetails(Task task) {
    showMedicalStickyNote(
      context,
      title: AppLocalizations.of(context).taskDetails,
      content:
          '${task.householdId}\n${task.description}\n${AppLocalizations.of(context).assigned}: ${task.assignedDate.toString().split(' ')[0]}',
      primaryActionText: AppLocalizations.of(context).startVisit.toUpperCase(),
      onPrimaryAction: () {
        Navigator.pushNamed(
          context,
          AppRoutes.fieldWorkerNewVisit,
          arguments: {
            'fieldWorkerId': _worker?.id,
            'householdId': task.householdId
          },
        );
      },
    );
  }

  String _getContextualEmptyMessage() {
    return AppLocalizations.of(context).noTasksMsg;
  }
}
