import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';

import '../providers/sensor_provider.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';
import 'settings_screen.dart'; // Import SettingsScreen
import 'help_screen.dart'; // Import HelpScreen

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dark background matching the watch face style
    return Scaffold(
      backgroundColor: const Color(0xFF020E15), // Deep navy/black
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 8.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeader(context, provider),

                                const SizedBox(height: 32),
                                // Main Status Card with rounded/circular aesthetic
                                // Removed Expanded to prevent overflow/collapse in IntrinsicHeight
                                _buildStatusCard(context, provider),

                                const SizedBox(height: 24),
                                // Metrics Grid
                                _buildMetricsGrid(context, provider),

                                const Spacer(),
                                // Logo Section
                                Center(
                                  child: Column(
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!.get('info'),
                                        style: GoogleFonts.rajdhani(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Life",
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Image.asset(
                                            'assets/logo128.png',
                                            height: 80,
                                            width: 80,
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            "Link",
                                            style: GoogleFonts.rajdhani(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                                if (provider.alertState != AlertState.safe)
                                  ElevatedButton(
                                    onPressed: () => provider.resetAlarm(),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppTheme.danger
                                          .withOpacity(0.9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      side: BorderSide(
                                        color: AppTheme.danger,
                                        width: 2,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                      child: Text(AppLocalizations.of(context)!.get('reset_alarm')),
                                    ),

                                // Map Section (Visible on Alarm with valid location)
                                if (provider.alertState == AlertState.alarm &&
                                    provider.fallLocation != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24.0),
                                    child: Container(
                                      height: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: AppTheme.danger,
                                          width: 2,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: FlutterMap(
                                          options: MapOptions(
                                            initialCenter:
                                                provider.fallLocation!,
                                            initialZoom: 15.0,
                                          ),
                                          children: [
                                            TileLayer(
                                              urlTemplate:
                                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                              userAgentPackageName:
                                                  'com.lifelink.app',
                                            ),
                                            MarkerLayer(
                                              markers: [
                                                Marker(
                                                  point: provider.fallLocation!,
                                                  width: 80,
                                                  height: 80,
                                                  child: const Icon(
                                                    Icons.location_on,
                                                    color: Colors.red,
                                                    size: 40,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 16.0),
                                  child: provider.isConnected
                                      ? ElevatedButton(
                                          onPressed: () =>
                                              provider.disconnect(),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.danger
                                                .withOpacity(0.2),
                                            foregroundColor: AppTheme.danger,
                                            side: BorderSide(
                                              color: AppTheme.danger,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                            child: Text(AppLocalizations.of(context)!.get('disconnect')),
                                          )
                                      : ElevatedButton(
                                            onPressed: () {
                                              if (provider.defaultDeviceAddress == null || provider.defaultDeviceAddress!.isEmpty) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                                );
                                              } else {
                                                provider.retryConnection();
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.cyan
                                                .withOpacity(0.2),
                                            foregroundColor: Colors.cyan,
                                            side: const BorderSide(
                                              color: Colors.cyan,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                            ),
                                          ),
                                          child: Text(AppLocalizations.of(context)!.get('reconnect')),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Countdown Overlay
              if (provider.isCountingDown)
                Container(
                  color: Colors.black.withOpacity(
                    0.9,
                  ), // Darken background primarily
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.red,
                        size: 80,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        AppLocalizations.of(context)!.get('fall_detected_exclamation'),
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.get('requesting_help_in'),
                        style: GoogleFonts.rajdhani(
                          color: Colors.white70,
                          fontSize: 18,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.red, width: 4),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          "${provider.currentCountdown}",
                          style: GoogleFonts.rajdhani(
                            color: Colors.red,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: 200,
                        height: 60,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: () => provider.cancelFall(),
                          child: Text(
                            AppLocalizations.of(context)!.get('im_ok'),
                            style: GoogleFonts.rajdhani(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          // Trigger immediately
                          // provider.forceExecuteAction(); // Optional method if we want instant trigger
                          // For now user can just wait.
                        },
                        child: Text(
                          "${AppLocalizations.of(context)!.get('sending_to')} ${provider.emergencyContactName.isNotEmpty ? provider.emergencyContactName : AppLocalizations.of(context)!.get('emergency')}",
                          style: GoogleFonts.rajdhani(
                            color: Colors.white30,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, SensorProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "LIFELINK",
              style: GoogleFonts.rajdhani(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            Text(
              "COMPANION APP",
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppTheme.accent,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 24),
            // Impact Metrics
            Text(
              AppLocalizations.of(context)!.get('impact_g'),
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              provider.gForce.toStringAsFixed(2),
              style: GoogleFonts.rajdhani(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(Icons.language, color: Colors.white70),
                  color: AppTheme.surface,
                  offset: const Offset(0, 45),
                  onSelected: (String code) {
                    provider.setLocale(code == 'system' ? null : code);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'system',
                      child: Text('System Language', style: GoogleFonts.rajdhani(color: Colors.white)),
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem<String>(
                      value: 'en',
                      child: Row(
                        children: [
                          const Text('🇺🇸 ', style: TextStyle(fontSize: 18)),
                          Text('English', style: GoogleFonts.rajdhani(color: Colors.white)),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'sr',
                      child: Row(
                        children: [
                          const Text('🇷🇸 ', style: TextStyle(fontSize: 18)),
                          Text('Srpski', style: GoogleFonts.rajdhani(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white70),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Colors.white70),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: provider.isConnected
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: provider.isConnected ? Colors.green : Colors.red,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    provider.isConnected
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    size: 16,
                    color: provider.isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.isConnected && provider.batteryLevel > 0
                        ? "BAT ${provider.batteryLevel}%"
                        : "BLT",
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: provider.isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusCard(BuildContext context, SensorProvider provider) {
    Color statusColor;
    String statusText;
    String subText;
    IconData statusIcon;

    if (!provider.isConnected) {
      statusColor = Colors.grey[500]!;
      statusText = AppLocalizations.of(context)!.get('disconnected').toUpperCase();
      subText = AppLocalizations.of(context)!.get('tap_to_reconnect');
      statusIcon = Icons.bluetooth_disabled;
    } else {
      switch (provider.alertState) {
        case AlertState.safe:
          statusColor = const Color(0xFF00E5FF); // Cyan
          statusText = AppLocalizations.of(context)!.get('system_nominal');
          subText = AppLocalizations.of(context)!.get('monitoring_active');
          statusIcon = Icons.shield_outlined;
          break;
        case AlertState.warning:
          statusColor = AppTheme.warning;
          statusText = AppLocalizations.of(context)!.get('movement_detected');
          subText = AppLocalizations.of(context)!.get('analyzing_impact');
          statusIcon = Icons.warning_amber_rounded;
          break;
        case AlertState.alarm:
          statusColor = AppTheme.danger;
          statusText = AppLocalizations.of(context)!.get('fall_detected_exclamation').replaceAll("!", "");
          subText = AppLocalizations.of(context)!.get('critical_alert');
          statusIcon = Icons.health_and_safety_outlined;
          break;
      }
    }

    return GestureDetector(
      onTap: !provider.isConnected
          ? () {
              if (provider.defaultDeviceAddress == null ||
                  provider.defaultDeviceAddress!.isEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              } else {
                provider.retryConnection();
              }
            }
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF051923), // Slightly lighter dark for card
          shape: BoxShape.circle, // Circular shape key for design
          border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, size: 48, color: statusColor),
            const SizedBox(height: 12),
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: statusColor,
                shadows: [
                  Shadow(color: statusColor.withOpacity(0.8), blurRadius: 10),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, SensorProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildMetricTile(
          AppLocalizations.of(context)!.get('pulse'),
          "${provider.pulse} BPM",
          Icons.favorite,
          Colors.redAccent,
        ),
        _buildMetricTile(
          AppLocalizations.of(context)!.get('spo2'),
          "${provider.spo2}%",
          Icons.water_drop,
          Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 28, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
