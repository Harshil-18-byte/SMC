import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:smc/core/localization/app_localizations.dart';

class EnvironmentStatusWidget extends StatelessWidget {
  const EnvironmentStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeInDown(
      child: GestureDetector(
        onTap: () => _showEnvironmentDetails(context, isDark),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C242D) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade100,
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco_rounded,
                            color: Colors.green, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context)
                            .translate('env_city_health_index'),
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color:
                              isDark ? Colors.white : const Color(0xFF111418),
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildItem(
                        context,
                        Icons.air_rounded,
                        AppLocalizations.of(context).translate('env_aqi'),
                        "42",
                        Colors.green,
                        AppLocalizations.of(context).translate('env_good')),
                  ),
                  _buildDivider(isDark),
                  Expanded(
                    child: _buildItem(
                        context,
                        Icons.wb_sunny_rounded,
                        AppLocalizations.of(context).translate('env_temp'),
                        "31°C",
                        Colors.orange,
                        AppLocalizations.of(context).translate('env_warm')),
                  ),
                  _buildDivider(isDark),
                  Expanded(
                    child: _buildItem(
                        context,
                        Icons.water_drop_rounded,
                        AppLocalizations.of(context).translate('env_uv'),
                        "Low",
                        Colors.blue,
                        AppLocalizations.of(context).translate('env_safe')),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label,
      String value, Color color, String status) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              status,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 60,
      width: 1,
      color: isDark ? Colors.white10 : Colors.grey.shade100,
    );
  }

  void _showEnvironmentDetails(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EnvironmentDetailsSheet(isDark: isDark),
    );
  }
}

class _EnvironmentDetailsSheet extends StatelessWidget {
  final bool isDark;
  const _EnvironmentDetailsSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101922) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppLocalizations.of(context).translate('env_ward_aqi'),
            style:
                GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                _buildWardItem("Ward 1 (Shivaji Colony)", 32, Colors.green),
                _buildWardItem("Ward 2 (Bhavani Peth)", 45, Colors.green),
                _buildWardItem("Ward 3 (Murarji Peth)", 88, Colors.orange),
                _buildWardItem(
                    "Ward 4 (Railway Station Area)", 112, Colors.orange),
                _buildWardItem("Ward 5 (MIDC Area)", 156, Colors.red),
                const SizedBox(height: 24),
                _buildHealthAdvice(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWardItem(String name, int aqi, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              Text(
                aqi.toString(),
                style: TextStyle(
                    color: color, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(width: 8),
              Icon(Icons.circle, color: color, size: 12),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthAdvice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.blue),
              const SizedBox(width: 12),
              Text(
                AppLocalizations.of(context).translate('env_health_advice'),
                style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Air quality is generally good today. However, people in MIDC area should limit prolonged outdoor exertion due to localized PM2.5 spikes.",
            style: TextStyle(fontSize: 14, height: 1.5, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}


