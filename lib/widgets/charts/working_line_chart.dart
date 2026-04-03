import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:smc/widgets/smc_map.dart'; // For ThemeExtension

class ChartDataPoint {
  final String label;
  final double value;

  ChartDataPoint({required this.label, required this.value});
}

class WorkingLineChart extends StatefulWidget {
  final String title;
  final Future<List<ChartDataPoint>> dataFuture;

  const WorkingLineChart({
    super.key,
    required this.title,
    required this.dataFuture,
  });

  @override
  State<WorkingLineChart> createState() => _WorkingLineChartState();
}

class _WorkingLineChartState extends State<WorkingLineChart> {
  List<ChartDataPoint>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await widget.dataFuture;
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: context.textStyles.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChartContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(height: 8),
            const Text('Failed to load chart data'),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadData();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_data == null || _data!.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: context.colors.onSurface.withValues(alpha: 0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < _data!.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _data![index].label,
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: context.colors.onSurface.withValues(alpha: 0.6),
                  ),
                );
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: _data!.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.value);
            }).toList(),
            isCurved: true,
            color: context.colors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: context.colors.primary,
                  strokeWidth: 2,
                  strokeColor: context.colors.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: context.colors.primary.withValues(alpha: 0.1),
            ),
          ),
        ],
        minY: 0,
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => context.colors.surface,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toInt()}',
                  TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}


