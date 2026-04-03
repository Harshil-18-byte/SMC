import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:smc/core/localization/app_localizations.dart';

/// IoT Device Detail Screen
/// Shows detailed sensor data, history graphs, and controls for a specific device
class IoTDeviceDetailScreen extends StatefulWidget {
  final String deviceId;
  final String deviceName;
  final String deviceType;

  const IoTDeviceDetailScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
  });

  @override
  State<IoTDeviceDetailScreen> createState() => _IoTDeviceDetailScreenState();
}

class _IoTDeviceDetailScreenState extends State<IoTDeviceDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _chartController;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: isDark ? Colors.white : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.deviceName,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined,
                color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceStatusCard(isDark, l10n),
            const SizedBox(height: 20),
            _buildSensorChart(isDark, l10n),
            const SizedBox(height: 20),
            _buildRecentReadings(isDark, l10n),
            const SizedBox(height: 20),
            _buildDeviceInfo(isDark, l10n),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatusCard(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color:
                const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.2 : 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.sensors_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.translate('iot_device_status'),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('iot_active'),
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('ID: ${widget.deviceId}',
                      style: GoogleFonts.outfit(
                          fontSize: 11, color: Colors.white54)),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(widget.deviceType,
                        style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                  'Signal', '-42 dBm', Icons.signal_cellular_alt_rounded),
              _buildStatItem('Battery', '87%', Icons.battery_4_bar_rounded),
              _buildStatItem('Uptime', '14d 7h', Icons.timer_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white60, size: 18),
        const SizedBox(height: 6),
        Text(value,
            style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
        Text(label,
            style: GoogleFonts.outfit(fontSize: 11, color: Colors.white54)),
      ],
    );
  }

  Widget _buildSensorChart(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l10n.translate('iot_sensor_history'),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  )),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('24h',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3B82F6),
                    )),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: AnimatedBuilder(
              animation: _chartController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 180),
                  painter: _ChartPainter(
                    isDark: isDark,
                    progress: _chartController.value,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReadings(bool isDark, AppLocalizations l10n) {
    final readings = [
      {'time': '19:30', 'value': '24.2°C', 'status': 'Normal'},
      {'time': '19:00', 'value': '24.0°C', 'status': 'Normal'},
      {'time': '18:30', 'value': '23.8°C', 'status': 'Normal'},
      {'time': '18:00', 'value': '25.1°C', 'status': 'High'},
      {'time': '17:30', 'value': '24.5°C', 'status': 'Normal'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('iot_recent_readings'),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 16),
          ...readings.map((r) {
            final isHigh = r['status'] == 'High';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(r['time']!,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isDark ? Colors.white54 : Colors.black45,
                        fontWeight: FontWeight.w500,
                      )),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(r['value']!,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isHigh
                            ? const Color(0xFFF59E0B)
                            : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      )),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isHigh
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.12)
                          : const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r['status']!,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isHigh
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF10B981),
                        )),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(bool isDark, AppLocalizations l10n) {
    final info = [
      {'label': 'Firmware', 'value': 'v2.4.1'},
      {'label': 'Model', 'value': 'SMC-IoT-PRO-V3'},
      {'label': 'Installed', 'value': '2025-08-15'},
      {'label': 'MAC Address', 'value': 'A4:CF:12:8B:3D:E7'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('iot_device_info'),
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 16),
          ...info.map((i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(i['label']!,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black45,
                        )),
                    Text(i['value']!,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        )),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

/// Custom painter for the sensor history chart
class _ChartPainter extends CustomPainter {
  final bool isDark;
  final double progress;

  _ChartPainter({required this.isDark, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42); // Fixed seed for consistent pattern
    final points = List.generate(24, (i) => 20 + random.nextDouble() * 60);

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.3),
          const Color(0xFF3B82F6).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final gridPaint = Paint()
      ..color = isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    // Draw grid
    for (var i = 0; i < 5; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw line + fill
    final path = Path();
    final fillPath = Path();
    final visiblePoints = (points.length * progress).round();

    for (var i = 0; i < visiblePoints; i++) {
      final x = size.width * i / (points.length - 1);
      final y = size.height - (points[i] / 100 * size.height);
      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    if (visiblePoints > 0) {
      final lastX = size.width * (visiblePoints - 1) / (points.length - 1);
      fillPath.lineTo(lastX, size.height);
      fillPath.close();
      canvas.drawPath(fillPath, fillPaint);
      canvas.drawPath(path, linePaint);

      // Draw dot at last point
      final lastY =
          size.height - (points[visiblePoints - 1] / 100 * size.height);
      canvas.drawCircle(
        Offset(lastX, lastY),
        4,
        Paint()..color = const Color(0xFF3B82F6),
      );
      canvas.drawCircle(
        Offset(lastX, lastY),
        6,
        Paint()
          ..color = const Color(0xFF3B82F6).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) =>
      oldDelegate.progress != progress;
}


