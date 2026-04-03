import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:smc/core/services/user_service.dart';
import 'package:smc/data/models/auth_models.dart';
import 'package:smc/core/localization/app_localizations.dart';
import 'package:smc/core/widgets/universal_drawer.dart';
import 'package:smc/core/widgets/dashboard_back_handler.dart';
import 'package:smc/config/routes.dart';

/// IoT Dashboard Screen
/// Role-based IoT monitoring hub for Admin and Citizen views
class IoTDashboardScreen extends StatefulWidget {
  const IoTDashboardScreen({super.key});

  @override
  State<IoTDashboardScreen> createState() => _IoTDashboardScreenState();
}

class _IoTDashboardScreenState extends State<IoTDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final role = userProvider.currentUser?.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F7F8),
      drawer: const UniversalDrawer(),
      body: DashboardBackHandler(
        dashboardName: 'IoT Dashboard',
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(isDark, l10n),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildConnectionStatus(isDark),
                    const SizedBox(height: 16),
                    _buildOverviewCards(isDark, l10n, role),
                    const SizedBox(height: 24),
                    if (role == UserRole.superAdmin || role == UserRole.stateAdmin) ...[
                      _buildAdminSection(isDark, l10n),
                    ] else ...[
                      _buildCitizenSection(isDark, l10n),
                    ],
                    const SizedBox(height: 24),
                    _buildLiveSensorFeed(isDark, l10n),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark, AppLocalizations l10n) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F7F8),
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.menu_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sensors_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.translate('iot_dashboard'),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_outlined,
              color: isDark ? Colors.white70 : Colors.black54),
          onPressed: () =>
              Navigator.pushNamed(context, AppRoutes.notifications),
        ),
      ],
    );
  }

  Widget _buildConnectionStatus(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      const Color(0xFF064E3B).withValues(alpha: 0.6),
                      const Color(0xFF065F46).withValues(alpha: 0.3),
                    ]
                  : [
                      const Color(0xFFD1FAE5),
                      const Color(0xFFECFDF5),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF10B981)
                  .withValues(alpha: _pulseAnimation.value * 0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981)
                          .withValues(alpha: _pulseAnimation.value * 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).translate('iot_connected'),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981),
                ),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context).translate('iot_last_ping'),
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCards(
      bool isDark, AppLocalizations l10n, UserRole? role) {
    final isAdmin = role == UserRole.superAdmin || role == UserRole.stateAdmin;
    final cards = isAdmin
        ? [
            _OverviewData(
                Icons.device_hub_rounded,
                l10n.translate('iot_total_devices'),
                '1,247',
                const Color(0xFF3B82F6),
                '+12'),
            _OverviewData(
                Icons.wifi_tethering_rounded,
                l10n.translate('iot_online'),
                '1,198',
                const Color(0xFF10B981),
                '96%'),
            _OverviewData(
                Icons.warning_amber_rounded,
                l10n.translate('iot_alerts_active'),
                '23',
                const Color(0xFFF59E0B),
                '-3'),
            _OverviewData(
                Icons.battery_alert_rounded,
                l10n.translate('iot_low_battery'),
                '49',
                const Color(0xFFEF4444),
                '+7'),
          ]
        : [
            _OverviewData(Icons.watch_rounded, l10n.translate('iot_my_devices'),
                '5', const Color(0xFF3B82F6), ''),
            _OverviewData(
                Icons.favorite_rounded,
                l10n.translate('iot_heart_rate'),
                '72',
                const Color(0xFFEF4444),
                'bpm'),
            _OverviewData(
                Icons.thermostat_rounded,
                l10n.translate('iot_room_temp'),
                '24°C',
                const Color(0xFFF59E0B),
                ''),
            _OverviewData(Icons.air_rounded, l10n.translate('iot_air_quality'),
                'Good', const Color(0xFF10B981), 'AQI 42'),
          ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: cards.map((data) => _buildOverviewCard(data, isDark)).toList(),
    );
  }

  Widget _buildOverviewCard(_OverviewData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? data.color.withValues(alpha: 0.2)
              : data.color.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: data.color.withValues(alpha: isDark ? 0.1 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(data.icon, color: data.color, size: 22),
              if (data.badge.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: data.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    data.badge,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: data.color,
                    ),
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                data.label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Admin Section ──────────────────────────────────────────
  Widget _buildAdminSection(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.translate('iot_city_infrastructure'), isDark),
        const SizedBox(height: 12),
        _buildDeviceCategory(
          isDark,
          Icons.water_drop_rounded,
          l10n.translate('iot_water_sensors'),
          '342 devices',
          const Color(0xFF06B6D4),
          [
            _SensorReading('pH Level', '7.2', 'Normal'),
            _SensorReading('Turbidity', '0.5 NTU', 'Clean'),
            _SensorReading('Flow Rate', '2.4 L/s', 'Optimal'),
          ],
        ),
        const SizedBox(height: 12),
        _buildDeviceCategory(
          isDark,
          Icons.traffic_rounded,
          l10n.translate('iot_traffic_sensors'),
          '456 units',
          const Color(0xFFF59E0B),
          [
            _SensorReading('Avg Speed', '32 km/h', 'Moderate'),
            _SensorReading('Congestion', '23%', 'Low'),
            _SensorReading('Incidents', '2', 'Active'),
          ],
        ),
        const SizedBox(height: 12),
        _buildDeviceCategory(
          isDark,
          Icons.lightbulb_rounded,
          l10n.translate('iot_smart_lights'),
          '891 posts',
          const Color(0xFF8B5CF6),
          [
            _SensorReading('Active', '742', 'On'),
            _SensorReading('Energy Saved', '34%', 'Good'),
            _SensorReading('Faults', '8', 'Minor'),
          ],
        ),
        const SizedBox(height: 12),
        _buildDeviceCategory(
          isDark,
          Icons.delete_outline_rounded,
          l10n.translate('iot_waste_bins'),
          '220 bins',
          const Color(0xFF10B981),
          [
            _SensorReading('Full', '18', 'Alert'),
            _SensorReading('Half', '94', 'Normal'),
            _SensorReading('Empty', '108', 'OK'),
          ],
        ),
      ],
    );
  }

  // ─── Citizen Section ──────────────────────────────────────────
  Widget _buildCitizenSection(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.translate('iot_my_health_devices'), isDark),
        const SizedBox(height: 12),
        _buildHealthDevice(isDark, Icons.watch_rounded,
            l10n.translate('iot_smartwatch'), 'Connected', true, [
          _SensorReading('Steps', '8,432', 'Today'),
          _SensorReading('SpO2', '98%', 'Normal'),
          _SensorReading('Sleep', '7.2 hrs', 'Good'),
        ]),
        const SizedBox(height: 12),
        _buildHealthDevice(isDark, Icons.monitor_heart_rounded,
            l10n.translate('iot_bp_monitor'), 'Synced 10m ago', true, [
          _SensorReading('Systolic', '120', 'Normal'),
          _SensorReading('Diastolic', '80', 'Normal'),
          _SensorReading('Pulse', '72', 'bpm'),
        ]),
        const SizedBox(height: 12),
        _buildHealthDevice(isDark, Icons.scale_rounded,
            l10n.translate('iot_smart_scale'), 'Synced 2h ago', true, [
          _SensorReading('Weight', '68.5 kg', ''),
          _SensorReading('BMI', '22.1', 'Normal'),
          _SensorReading('Body Fat', '18.3%', 'Healthy'),
        ]),
        const SizedBox(height: 24),
        _buildSectionTitle(l10n.translate('iot_home_environment'), isDark),
        const SizedBox(height: 12),
        _buildHomeEnvironment(isDark, l10n),
      ],
    );
  }

  Widget _buildDeviceCategory(bool isDark, IconData icon, String title,
      String count, Color color, List<_SensorReading> readings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.15)
              : color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        )),
                    Text(count,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black45,
                        )),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: isDark ? Colors.white24 : Colors.black12),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: readings
                .map((r) => Expanded(child: _buildSensorChip(r, isDark)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDevice(bool isDark, IconData icon, String title,
      String status, bool connected, List<_SensorReading> readings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        )),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: connected
                                ? const Color(0xFF10B981)
                                : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(status,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.bluetooth_connected_rounded,
                  color: const Color(0xFF3B82F6), size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: readings
                .map((r) => Expanded(child: _buildSensorChip(r, isDark)))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeEnvironment(bool isDark, AppLocalizations l10n) {
    final envData = [
      _EnvData(Icons.thermostat_rounded, l10n.translate('iot_temperature'),
          '24°C', const Color(0xFFF59E0B)),
      _EnvData(Icons.water_drop_rounded, l10n.translate('iot_humidity'), '45%',
          const Color(0xFF06B6D4)),
      _EnvData(Icons.air_rounded, l10n.translate('iot_air_quality_label'),
          'AQI 42', const Color(0xFF10B981)),
      _EnvData(Icons.volume_up_rounded, l10n.translate('iot_noise_level'),
          '38 dB', const Color(0xFF8B5CF6)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: envData.map((data) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF161B22) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: data.color.withValues(alpha: 0.15),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(data.icon, color: data.color, size: 22),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.value,
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      )),
                  Text(data.label,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black45,
                      )),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSensorChip(_SensorReading reading, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(reading.value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 2),
          Text(reading.label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.black38,
              )),
          if (reading.status.isNotEmpty)
            Text(reading.status,
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black26,
                )),
        ],
      ),
    );
  }

  Widget _buildLiveSensorFeed(bool isDark, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(l10n.translate('iot_live_feed'), isDark),
        const SizedBox(height: 12),
        ...List.generate(5, (i) {
          final feeds = [
            _FeedItem(
                Icons.water_drop,
                'Water Sensor #${342 - i}',
                'pH: ${7.0 + i * 0.1}',
                '${i + 1}m ago',
                const Color(0xFF06B6D4)),
            _FeedItem(Icons.thermostat, 'Temp Sensor #${100 + i}',
                '${24 + i}°C', '${i * 2 + 1}m ago', const Color(0xFFF59E0B)),
            _FeedItem(Icons.air, 'AQI Station #${i + 1}', 'AQI: ${40 + i * 3}',
                '${i + 2}m ago', const Color(0xFF10B981)),
            _FeedItem(Icons.traffic, 'Traffic Cam #${200 + i}', 'Flow: Normal',
                '${i * 3 + 1}m ago', const Color(0xFF8B5CF6)),
            _FeedItem(
                Icons.delete_outline,
                'Bin #${i + 50}',
                'Capacity: ${30 + i * 12}%',
                '${i + 5}m ago',
                const Color(0xFFEF4444)),
          ];
          final feed = feeds[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161B22) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.04),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: feed.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(feed.icon, color: feed.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(feed.title,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color:
                                isDark ? Colors.white : const Color(0xFF0F172A),
                          )),
                      Text(feed.reading,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: isDark ? Colors.white54 : Colors.black45,
                          )),
                    ],
                  ),
                ),
                Text(feed.time,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.3)
                          : Colors.black26,
                    )),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF0F172A),
      ),
    );
  }
}

class _OverviewData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final String badge;
  _OverviewData(this.icon, this.label, this.value, this.color, this.badge);
}

class _SensorReading {
  final String label;
  final String value;
  final String status;
  _SensorReading(this.label, this.value, this.status);
}

class _EnvData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  _EnvData(this.icon, this.label, this.value, this.color);
}

class _FeedItem {
  final IconData icon;
  final String title;
  final String reading;
  final String time;
  final Color color;
  _FeedItem(this.icon, this.title, this.reading, this.time, this.color);
}


