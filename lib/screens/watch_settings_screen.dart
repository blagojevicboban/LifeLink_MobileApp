import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/sensor_provider.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';

class WatchSettingsScreen extends StatefulWidget {
  const WatchSettingsScreen({super.key});

  @override
  State<WatchSettingsScreen> createState() => _WatchSettingsScreenState();
}

class _WatchSettingsScreenState extends State<WatchSettingsScreen> {
  late SensorProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<SensorProvider>(context, listen: false);
    // Read settings from watch when the screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.readWatchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.get('watch_hardware_settings'), style: GoogleFonts.rajdhani(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surface,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.accent),
            tooltip: AppLocalizations.of(context)!.get('read_settings'),
            onPressed: () {
              _provider.readWatchSettings();
            },
          ),
        ],
      ),
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          if (!provider.isConnected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bluetooth_disabled, color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.get('watch_not_connected'), style: GoogleFonts.rajdhani(color: Colors.white54, fontSize: 18)),
                ],
              ),
            );
          }

          if (provider.isSyncingWatchSettings) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppTheme.accent),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.get('syncing_with_watch'), style: GoogleFonts.rajdhani(color: Colors.white70, fontSize: 16)),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCardHeader(AppLocalizations.of(context)!.get('screen_power')),
                _buildSettingSlider(
                  title: AppLocalizations.of(context)!.get('screen_timeout'),
                  value: provider.watchScreenTimeoutMs / 1000.0,
                  min: 5,
                  max: 60,
                  divisions: 55,
                  suffix: "s",
                  onChanged: (val) {
                    provider.writeWatchSettings(screenTimeoutMs: (val * 1000).toInt());
                  },
                ),
                
                const SizedBox(height: 24),
                _buildCardHeader(AppLocalizations.of(context)!.get('fall_detection_algorithms')),
                _buildSettingSlider(
                  title: AppLocalizations.of(context)!.get('free_fall_threshold'),
                  value: provider.watchFallLow,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  suffix: "G",
                  onChanged: (val) {
                    provider.writeWatchSettings(fallLow: val);
                  },
                ),
                _buildSettingSlider(
                  title: AppLocalizations.of(context)!.get('impact_threshold'),
                  value: provider.watchFallHigh,
                  min: 2.0,
                  max: 8.0,
                  divisions: 60,
                  suffix: "G",
                  onChanged: (val) {
                    provider.writeWatchSettings(fallHigh: val);
                  },
                ),
                _buildSettingSlider(
                  title: AppLocalizations.of(context)!.get('stillness_tolerance'),
                  value: provider.watchStillTol,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  suffix: "G",
                  onChanged: (val) {
                    provider.writeWatchSettings(stillTol: val);
                  },
                ),
                _buildSettingSlider(
                  title: AppLocalizations.of(context)!.get('stillness_duration'),
                  value: provider.watchStillDur / 1000.0,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  suffix: "s",
                  onChanged: (val) {
                    provider.writeWatchSettings(stillDur: (val * 1000).toInt());
                  },
                ),
                _buildSettingSlider(
                  title: AppLocalizations.of(context)!.get('angle_change_threshold'),
                  value: provider.watchAngleThr,
                  min: 10,
                  max: 90,
                  divisions: 80,
                  suffix: "°",
                  onChanged: (val) {
                    provider.writeWatchSettings(angleThr: val);
                  },
                ),
                
                const SizedBox(height: 24),
                _buildCardHeader(AppLocalizations.of(context)!.get('action_origin')),
                DropdownButtonFormField<int>(
                  value: provider.watchActionOrigin,
                  dropdownColor: AppTheme.surface,
                  style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white10),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 0, child: Text(AppLocalizations.of(context)!.get('watch_only'), style: GoogleFonts.rajdhani())),
                    DropdownMenuItem(value: 1, child: Text(AppLocalizations.of(context)!.get('app_and_watch'), style: GoogleFonts.rajdhani())),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      provider.writeWatchSettings(actionOrigin: val);
                    }
                  },
                ),

                const SizedBox(height: 24),
                _buildCardHeader(AppLocalizations.of(context)!.get('watch_wifi_credentials')),
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.get('enable_watch_wifi'), style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16)),
                  value: provider.watchWifiEnabled,
                  activeColor: AppTheme.accent,
                  onChanged: (val) => provider.writeWatchSettings(wifiEnabled: val),
                  contentPadding: EdgeInsets.zero,
                ),
                if (provider.watchWifiEnabled) ...[
                  TextField(
                    style: GoogleFonts.rajdhani(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.get('wifi_ssid'),
                      labelStyle: GoogleFonts.rajdhani(color: Colors.white54),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    controller: TextEditingController(text: provider.watchWifiSsid)..selection = TextSelection.collapsed(offset: provider.watchWifiSsid.length),
                    onChanged: (val) => provider.writeWatchSettings(wifiSsid: val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    style: GoogleFonts.rajdhani(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.get('wifi_password'),
                      labelStyle: GoogleFonts.rajdhani(color: Colors.white54),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    obscureText: true,
                    controller: TextEditingController(text: provider.watchWifiPass)..selection = TextSelection.collapsed(offset: provider.watchWifiPass.length),
                    onChanged: (val) => provider.writeWatchSettings(wifiPass: val),
                  ),
                ],

                const SizedBox(height: 24),
                _buildCardHeader(AppLocalizations.of(context)!.get('watch_emergency_actions')),
                
                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.get('enable_watch_sms'), style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16)),
                  value: provider.watchEnableSms,
                  activeColor: AppTheme.accent,
                  onChanged: (val) => provider.writeWatchSettings(enableSms: val),
                  contentPadding: EdgeInsets.zero,
                ),
                if (provider.watchEnableSms)
                  TextField(
                    style: GoogleFonts.rajdhani(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.get('sms_numbers'),
                      labelStyle: GoogleFonts.rajdhani(color: Colors.white54),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    controller: TextEditingController(text: provider.watchSmsNumbers)..selection = TextSelection.collapsed(offset: provider.watchSmsNumbers.length),
                    onChanged: (val) => provider.writeWatchSettings(smsNumbers: val),
                  ),

                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.get('enable_watch_call'), style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16)),
                  value: provider.watchEnableCall,
                  activeColor: AppTheme.accent,
                  onChanged: (val) => provider.writeWatchSettings(enableCall: val),
                  contentPadding: EdgeInsets.zero,
                ),
                if (provider.watchEnableCall)
                  TextField(
                    style: GoogleFonts.rajdhani(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.get('call_numbers'),
                      labelStyle: GoogleFonts.rajdhani(color: Colors.white54),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    controller: TextEditingController(text: provider.watchCallNumbers)..selection = TextSelection.collapsed(offset: provider.watchCallNumbers.length),
                    onChanged: (val) => provider.writeWatchSettings(callNumbers: val),
                  ),

                SwitchListTile(
                  title: Text(AppLocalizations.of(context)!.get('enable_watch_sos'), style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16)),
                  value: provider.watchEnableSos,
                  activeColor: AppTheme.accent,
                  onChanged: (val) => provider.writeWatchSettings(enableSos: val),
                  contentPadding: EdgeInsets.zero,
                ),
                if (provider.watchEnableSos)
                  TextField(
                    style: GoogleFonts.rajdhani(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.get('sos_number'),
                      labelStyle: GoogleFonts.rajdhani(color: Colors.white54),
                      filled: true,
                      fillColor: AppTheme.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    controller: TextEditingController(text: provider.watchSosNumber)..selection = TextSelection.collapsed(offset: provider.watchSosNumber.length),
                    onChanged: (val) => provider.writeWatchSettings(sosNumber: val),
                  ),

                const SizedBox(height: 24),
                _buildCardHeader(AppLocalizations.of(context)!.get('set_time_on_watch')),
                ElevatedButton.icon(
                  onPressed: () {
                    // Get current time in YYYY-MM-DD HH:MM:SS format
                    final now = DateTime.now();
                    final formattedTime = 
                      "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} "
                      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                    
                    provider.writeWatchSettings(syncTime: formattedTime);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.get('watch_time_synced'), style: GoogleFonts.rajdhani()),
                        backgroundColor: Colors.blueAccent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.access_time, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.get('set_time_on_watch'), style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.blueAccent, width: 1),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () {
                     ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLocalizations.of(context)!.get('settings_saved'), style: GoogleFonts.rajdhani()),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: Text(AppLocalizations.of(context)!.get('done'), style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.rajdhani(
          color: AppTheme.accent,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String suffix,
    required Function(double) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.rajdhani(color: Colors.white, fontSize: 16),
              ),
              Text(
                "${value.toStringAsFixed(1)}$suffix",
                style: GoogleFonts.rajdhani(color: AppTheme.accent, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              activeColor: AppTheme.accent,
              inactiveColor: Colors.white10,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
