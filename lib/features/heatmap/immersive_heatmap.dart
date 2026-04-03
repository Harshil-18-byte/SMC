import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

// Enum for Heatmap Mode
enum HeatmapMode { realTime, timeLapse, prediction }

// Data class for Heatmap Points
class HeatmapDataPoint {
  final double x; // Normalized 0.0 to 1.0 within bounds
  final double y; // Normalized 0.0 to 1.0 within bounds
  final double intensity; // 0.0 to 1.0
  final double radius;

  const HeatmapDataPoint({
    required this.x,
    required this.y,
    required this.intensity,
    required this.radius,
  });
}

class ImmersiveHeatmap extends StatefulWidget {
  const ImmersiveHeatmap({super.key});

  @override
  State<ImmersiveHeatmap> createState() => _ImmersiveHeatmapState();
}

class _ImmersiveHeatmapState extends State<ImmersiveHeatmap>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  // Controller for Time-Lapse slider animation if needed
  double _timeLapseValue = 0.0;

  double _cameraAngle = 0;
  double _cameraHeight = 45;

  HeatmapMode _mode = HeatmapMode.realTime;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 3D Heatmap canvas
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              _cameraAngle += details.delta.dx * 0.01;
              // Clamp camera height to avoid flipping or extreme angles
              _cameraHeight =
                  (_cameraHeight - details.delta.dy * 0.1).clamp(15.0, 75.0);
            });
          },
          child: AnimatedBuilder(
            animation:
                Listenable.merge([_rotationController, _pulseController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: Heatmap3DPainter(
                  cameraAngle: _cameraAngle +
                      (_mode == HeatmapMode.realTime
                          ? _rotationController.value * 2 * math.pi
                          : 0),
                  cameraHeight: _cameraHeight,
                  pulseAnimation: _pulseController.value,
                  mode: _mode,
                  data: _getHeatmapData(),
                ),
                child: Container(color: Colors.transparent), // Expand to fill
              );
            },
          ),
        ),

        // Control panel
        Positioned(
          top: 16,
          right: 16,
          child: _buildControlPanel(),
        ),

        // Legend
        Positioned(
          bottom: 16,
          left: 16,
          child: _buildInteractiveLegend(),
        ),

        // Time travel slider
        if (_mode == HeatmapMode.timeLapse)
          Positioned(
            bottom: 80,
            left: 16,
            right: 16,
            child: _buildTimeTravelSlider(),
          ),
      ],
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildControlButton(
            icon: Icons.play_arrow,
            label: 'Real-Time',
            isActive: _mode == HeatmapMode.realTime,
            onTap: () => setState(() => _mode = HeatmapMode.realTime),
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.history,
            label: 'Time-Lapse',
            isActive: _mode == HeatmapMode.timeLapse,
            onTap: () => setState(() => _mode = HeatmapMode.timeLapse),
          ),
          const SizedBox(height: 8),
          _buildControlButton(
            icon: Icons.analytics,
            label: 'Prediction',
            isActive: _mode == HeatmapMode.prediction,
            onTap: () => setState(() => _mode = HeatmapMode.prediction),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.2)),
          IconButton(
            icon: const Icon(Icons.threed_rotation, color: Colors.white),
            onPressed: () {
              if (_rotationController.isAnimating) {
                _rotationController.stop();
              } else {
                _rotationController.repeat();
              }
            },
            tooltip: 'Toggle Rotation',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white60,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white60,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Incident Density',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Gradient bar with interactive tooltips
          SizedBox(
            height: 40,
            width: 200,
            child: Stack(
              children: [
                // Gradient
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.red,
                        Colors.purple,
                      ],
                    ),
                  ),
                ),

                // Interactive markers
                ...List.generate(5, (index) {
                  return Positioned(
                    left: index * 40.0,
                    child: GestureDetector(
                      onTap: () => _showDensityInfo(index),
                      child: Container(
                        width: 40,
                        height: 40,
                        color: Colors.transparent, // Hit test target
                        child: Column(
                          children: [
                            Container(
                              width: 2,
                              height: 15,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            const Spacer(),
                            Text(
                              ['Low', 'Mod', 'High', 'Crit', 'Sev'][index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Colors.black,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTravelSlider() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Colors.blueAccent,
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                overlayColor: Colors.blueAccent.withValues(alpha: 0.2),
                trackHeight: 4.0,
              ),
              child: Slider(
                value: _timeLapseValue,
                min: 0.0,
                max: 100.0,
                divisions: 100,
                label: 'Week ${_timeLapseValue.toInt()}',
                onChanged: (value) {
                  setState(() {
                    _timeLapseValue = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Week ${_timeLapseValue.toInt()}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showDensityInfo(int index) {
    final levels = ['Low', 'Moderate', 'High', 'Critical', 'Severe'];
    final descriptions = [
      'Normal activity levels. No immediate action required.',
      'Slight increase in reported cases. Monitor closely.',
      'Significant activity. Resource allocation recommended.',
      'Dangerous levels. Immediate intervention required.',
      'Emergency state. Full mobilization of resources needed.'
    ];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black87,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${levels[index]} Density',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(descriptions[index],
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.blueAccent,
          onPressed: () {},
        ),
      ),
    );
  }

  List<HeatmapDataPoint> _getHeatmapData() {
    // Generate some mock data driven by mode and time
    final random =
        math.Random(42); // Seed for consistency unless intended otherwise
    final List<HeatmapDataPoint> points = [];

    int count = 20;
    if (_mode == HeatmapMode.prediction)
      count = 30; // More points for prediction

    for (int i = 0; i < count; i++) {
      double x = random.nextDouble() * 0.8 + 0.1; // Keep strictly within bounds
      double y = random.nextDouble() * 0.8 + 0.1;

      double intensity = random.nextDouble();

      // Modify intensity based on mode
      if (_mode == HeatmapMode.timeLapse) {
        // intensity varies by time
        intensity = (intensity + (_timeLapseValue / 100.0)) % 1.0;
      }

      if (_mode == HeatmapMode.prediction) {
        // Shift positions slightly for prediction
        x += (random.nextDouble() - 0.5) * 0.1;
        y += (random.nextDouble() - 0.5) * 0.1;
      }

      points.add(HeatmapDataPoint(
        x: (x - 0.5) * 300, // Scale to canvas coordinate space roughly
        y: (y - 0.5) * 300,
        intensity: intensity,
        radius: 20.0 + random.nextDouble() * 15.0,
      ));
    }
    return points;
  }
}

// Custom 3D heatmap painter
class Heatmap3DPainter extends CustomPainter {
  final double cameraAngle;
  final double cameraHeight;
  final double pulseAnimation;
  final HeatmapMode mode;
  final List<HeatmapDataPoint> data;

  Heatmap3DPainter({
    required this.cameraAngle,
    required this.cameraHeight,
    required this.pulseAnimation,
    required this.mode,
    required this.data,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Center of the canvas
    final center = Offset(size.width / 2, size.height / 2);

    // Draw a base grid for reference
    _drawGrid(canvas, size, center);

    // Sort points by depth (simple painter's algorithm approx)
    // We projecting 3D to 2D. Depth is primarily 'y' component after rotation.
    // However, a true depth sort requires calculating the projected z of each point.
    // For this visual, we can just iterate. If overlap matters, we should sort.
    // Let's sort by projected Y (painter's algo - back to front).

    // We'll map points to projected points and depth first
    final projectedPoints = data.map((point) {
      final p = _project3DTo2D(
        point.x,
        point.y,
        point.intensity * pulseAnimation,
        size,
      );
      // Simple depth estimate: rotated Y is "forward/backward"
      final depth =
          point.x * math.sin(cameraAngle) + point.y * math.cos(cameraAngle);
      return _ProjectedPoint(point, p, depth);
    }).toList();

    // Sort: furthest back first (lowest depth value, depending on coordinate system)
    projectedPoints.sort((a, b) => a.depth.compareTo(b.depth));

    for (final p in projectedPoints) {
      final point = p.original;
      final projected = p.projected;

      // Draw heat column
      // Gradient for the "top" of the pillar
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          projected,
          point.radius,
          [
            _getHeatColor(point.intensity).withValues(alpha: 0.8),
            _getHeatColor(point.intensity).withValues(alpha: 0.0),
          ],
        );

      // Draw 3D column effect (stem) first to be "behind" the glowing top
      _draw3DColumn(canvas, projected, point.intensity, point.radius);

      // Draw the glowing cap
      canvas.drawCircle(projected, point.radius, paint);
    }
  }

  void _drawGrid(Canvas canvas, Size size, Offset center) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    // Draw a 10x10 grid on the base plane (z=0)
    const gridSize = 400.0;
    const steps = 10;
    const stepSize = gridSize / steps;

    for (int i = 0; i <= steps; i++) {
      double p = -gridSize / 2 + i * stepSize;

      // Horizontal lines (along X axis)
      Offset start = _project3DTo2D(p, -gridSize / 2, 0, size);
      Offset end = _project3DTo2D(p, gridSize / 2, 0, size);
      canvas.drawLine(start, end, paint);

      // Vertical lines (along Y axis)
      start = _project3DTo2D(-gridSize / 2, p, 0, size);
      end = _project3DTo2D(gridSize / 2, p, 0, size);
      canvas.drawLine(start, end, paint);
    }
  }

  Offset _project3DTo2D(double x, double y, double z, Size size) {
    // Simple isometric-like projection
    // Rotate x and y around the center based on cameraAngle
    final rotatedX = x * math.cos(cameraAngle) - y * math.sin(cameraAngle);
    final rotatedY = x * math.sin(cameraAngle) + y * math.cos(cameraAngle);

    // Tilt based on cameraHeight (90 is overhead, 0 is horizontal)
    // We simulate tilt by squashing the Y axis
    final tilt = math.sin(cameraHeight * math.pi / 180); // 0 to 1

    // Z is up. In screen coords, up is negative Y.
    // We add rotatedZ to Y.

    // Refined projection for better "feel"
    return Offset(
      size.width / 2 + rotatedX,
      size.height / 2 + (rotatedY * tilt) - (z * 50), // Scale Z for visibility
    );
  }

  void _draw3DColumn(
      Canvas canvas, Offset base, double intensity, double radius) {
    // Calculate height in pixels based on intensity
    final height = intensity * 100; // Taller columns
    // Draw a cylinder-like rect downwards to create volume (stem)
    final paint = Paint()
      ..color = _getHeatColor(intensity).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final groundOffset = height; // Using height calc from Z

    final path = Path()
      ..moveTo(base.dx - radius / 2, base.dy)
      ..lineTo(base.dx + radius / 2, base.dy)
      ..lineTo(base.dx + radius / 2, base.dy + groundOffset)
      ..lineTo(base.dx - radius / 2, base.dy + groundOffset)
      ..close();

    canvas.drawPath(path, paint);
  }

  Color _getHeatColor(double intensity) {
    if (intensity < 0.2) return Colors.greenAccent;
    if (intensity < 0.4) return Colors.yellowAccent;
    if (intensity < 0.6) return Colors.orangeAccent;
    if (intensity < 0.8) return Colors.redAccent;
    return Colors.purpleAccent;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ProjectedPoint {
  final HeatmapDataPoint original;
  final Offset projected;
  final double depth;

  _ProjectedPoint(this.original, this.projected, this.depth);
}


