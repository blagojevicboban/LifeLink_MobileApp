import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/sensor_provider.dart';
import '../core/app_theme.dart';
import '../core/localization.dart';
import 'watch_settings_screen.dart';
import 'help_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SensorProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<SensorProvider>(context, listen: false);

    // Start scanning when entering settings after the first frame is drawn
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.startScan();
    });
  }

  @override
  void dispose() {
    // Stop scanning when leaving settings
    _provider.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020E15),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          AppLocalizations.of(context)!.get('settings'),
          style: GoogleFonts.rajdhani(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(AppLocalizations.of(context)!.get('device_connection')),
                const SizedBox(height: 16),
                _buildDeviceSection(context, provider),

                const SizedBox(height: 32),
                _buildSectionHeader(AppLocalizations.of(context)!.get('system_permissions')),
                const SizedBox(height: 16),
                _buildPermissionsSection(provider),

                const SizedBox(height: 32),
                _buildSectionHeader(AppLocalizations.of(context)!.get('safety_configuration')),
                const SizedBox(height: 16),
                _buildSafetySection(context, provider),

                const SizedBox(height: 32),
                _buildSectionHeader(AppLocalizations.of(context)!.get('help')),
                const SizedBox(height: 16),
                _buildHelpSection(context),

                const SizedBox(height: 32),
                Center(
                  child: Text(
                    "Version 1.0.0",
                    style: GoogleFonts.rajdhani(color: Colors.white30),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.help_outline, color: Colors.white),
        ),
        title: Text(
          AppLocalizations.of(context)!.get('user_manual'),
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HelpScreen()),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.rajdhani(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppTheme.accent,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildDeviceSection(BuildContext context, SensorProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                provider.isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth,
                color: provider.isConnected ? Colors.green : Colors.white70,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.isConnected ? AppLocalizations.of(context)!.get('connected') : AppLocalizations.of(context)!.get('disconnected'),
                      style: GoogleFonts.rajdhani(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    if (provider.defaultDeviceAddress != null)
                      Text(
                        "${AppLocalizations.of(context)!.get('default_device')} ${provider.defaultDeviceAddress}",
                        style: GoogleFonts.rajdhani(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              if (provider.isScanning)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () => provider.startScan(),
                ),
            ],
          ),
          const Divider(color: Colors.white10, height: 32),

          if (provider.isConnected)
            Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    provider.connectedDeviceName,
                    style: GoogleFonts.rajdhani(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Text(
                    provider.connectedDeviceAddress ?? "",
                    style: GoogleFonts.rajdhani(color: Colors.white54),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    onPressed: () => provider.disconnect(),
                    child: Text(AppLocalizations.of(context)!.get('disconnect')),
                  ),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.watch, color: AppTheme.accent),
                  title: Text(
                    AppLocalizations.of(context)!.get('watch_hardware_settings'),
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white54),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WatchSettingsScreen(),
                      ),
                    );
                  },
                ),
                if (!provider.isScanning)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.refresh, color: Colors.white70),
                        label: Text(
                          AppLocalizations.of(context)!.get('scan_for_devices'),
                          style: GoogleFonts.rajdhani(color: Colors.white70),
                        ),
                        onPressed: () => provider.startScan(),
                      ),
                    ),
                  ),
              ],
            )
          else ...[
            if (provider.scanResults.isEmpty && !provider.isScanning)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  AppLocalizations.of(context)!.get('no_devices_found'),
                  style: GoogleFonts.rajdhani(color: Colors.white54),
                ),
              ),

            ...provider.scanResults.map((result) {
              bool isDefault =
                  result.device.remoteId.toString() ==
                  provider.defaultDeviceAddress;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  result.device.platformName.isNotEmpty
                      ? result.device.platformName
                      : "Unknown Device",
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  result.device.remoteId.toString(),
                  style: GoogleFonts.rajdhani(color: Colors.white54),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDefault
                        ? AppTheme.accent
                        : Colors.white10,
                    foregroundColor: isDefault ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () {
                    provider.connect(result.device);
                    provider.saveSettings(
                      deviceAddress: result.device.remoteId.toString(),
                    );
                  },
                  child: Text(isDefault ? AppLocalizations.of(context)!.get('set_default') : AppLocalizations.of(context)!.get('connect')),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionsSection(SensorProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPermissionTile(
            AppLocalizations.of(context)!.get('location_services'),
            AppLocalizations.of(context)!.get('location_required'),
            Icons.location_on,
            () => provider.openLocationSettings(),
          ),
          const Divider(color: Colors.white10),
          _buildPermissionTile(
            AppLocalizations.of(context)!.get('bluetooth_settings'),
            AppLocalizations.of(context)!.get('bluetooth_manage'),
            Icons.settings_bluetooth,
            () => provider.openBluetoothSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white),
      ),
      title: Text(
        title,
        style: GoogleFonts.rajdhani(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.rajdhani(color: Colors.white54),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white30,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSafetySection(BuildContext context, SensorProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. SMS Checkbox & List
          _buildActionHeader(
            AppLocalizations.of(context)!.get('sms_notifications'),
            provider.enableSms,
            (val) => provider.saveSettings(enableSms: val),
          ),
          if (provider.enableSms)
            _buildNumberList(
              provider.smsNumbers,
              (newList) => provider.saveSettings(smsNumbers: newList),
              AppLocalizations.of(context)!.get('add_sms_number'),
            ),

          const SizedBox(height: 24),
          // 2. Sequential CALL Checkbox & List
          _buildActionHeader(
            AppLocalizations.of(context)!.get('sequential_calls'),
            provider.enableCall,
            (val) => provider.saveSettings(enableCall: val),
          ),
          if (provider.enableCall)
            _buildNumberList(
              provider.callNumbers,
              (newList) => provider.saveSettings(callNumbers: newList),
              AppLocalizations.of(context)!.get('add_call_number'),
            ),

          const SizedBox(height: 24),
          // 3. SOS Call Checkbox & Single Number
          _buildActionHeader(
            AppLocalizations.of(context)!.get('sos_emergency_call'),
            provider.enableSos,
            (val) => provider.saveSettings(enableSos: val),
          ),
          if (provider.enableSos)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: TextField(
                style: GoogleFonts.rajdhani(color: Colors.white),
                decoration: _inputDecoration(AppLocalizations.of(context)!.get('sos_number_hint')),
                keyboardType: TextInputType.phone,
                controller: TextEditingController(text: provider.sosNumber)
                  ..selection = TextSelection.collapsed(
                    offset: provider.sosNumber.length,
                  ),
                onChanged: (val) => provider.saveSettings(sosNumber: val),
              ),
            ),

          const SizedBox(height: 32),
          // Countdown Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.get('countdown_timer'),
                style: GoogleFonts.rajdhani(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                "${provider.countdownDuration} ${AppLocalizations.of(context)!.get('sec')}",
                style: GoogleFonts.rajdhani(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: provider.countdownDuration.toDouble().clamp(1.0, 10.0),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: AppTheme.accent,
            inactiveColor: Colors.white10,
            onChanged: (val) => provider.saveSettings(duration: val.toInt()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionHeader(
    String title,
    bool value,
    Function(bool?) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.rajdhani(
            color: value ? AppTheme.accent : Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.accent,
        ),
      ],
    );
  }

  Widget _buildNumberList(
    List<String> numbers,
    Function(List<String>) onUpdate,
    String hint,
  ) {
    return Column(
      children: [
        ...numbers.asMap().entries.map((entry) {
          int idx = entry.key;
          String num = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: GoogleFonts.rajdhani(color: Colors.white),
                    decoration: _inputDecoration(hint),
                    keyboardType: TextInputType.phone,
                    // Use standard controller for inline editing
                    controller: TextEditingController(text: num)
                      ..selection = TextSelection.collapsed(offset: num.length),
                    onChanged: (val) {
                      List<String> newList = List.from(numbers);
                      newList[idx] = val;
                      onUpdate(newList);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    List<String> newList = List.from(numbers);
                    newList.removeAt(idx);
                    onUpdate(newList);
                  },
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          icon: const Icon(Icons.add_circle_outline, color: Colors.greenAccent),
          label: Text(
            AppLocalizations.of(context)!.get('add_phone_number'),
            style: GoogleFonts.rajdhani(color: Colors.greenAccent),
          ),
          onPressed: () {
            List<String> newList = List.from(numbers);
            newList.add("");
            onUpdate(newList);
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.rajdhani(color: Colors.white30),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
