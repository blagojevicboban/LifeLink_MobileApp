import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Main / Dashboard Strings
      'app_title': 'LifeLink',
      'dashboard': 'DASHBOARD',
      'settings': 'SETTINGS',
      'help': 'HELP',
      'user_manual': 'User Manual',
      'device_connection': 'DEVICE CONNECTION',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'no_devices_found': 'No devices found. Tap refresh to scan.',
      'scan_for_devices': 'Scan for other devices',
      'default_device': 'Default:',
      'disconnect': 'DISCONNECT',
      'connect': 'CONNECT',
      'set_default': 'DEFAULT',
      'reconnect': 'RECONNECT',
      'info': 'Info',
      'reset_alarm': 'RESET ALARM',
      'fall_detected_exclamation': 'FALL DETECTED!',
      'requesting_help_in': 'Requesting help in',
      'im_ok': 'I\'M OK',
      'sending_to': 'Sending to:',
      'emergency': 'Emergency',
      'impact_g': 'IMPACT (G)',
      'system_nominal': 'SYSTEM NOMINAL',
      'monitoring_active': 'Monitoring Active',
      'movement_detected': 'MOVEMENT DETECTED',
      'analyzing_impact': 'Analyzing Impact Pattern...',
      'critical_alert': 'CRITICAL ALERT',
      'tap_to_reconnect': 'Tap to reconnect',
      'pulse': 'PULSE',
      'spo2': 'SpO2',
      
      // Watch Settings
      'watch_hardware_settings': 'Watch Hardware Settings',
      'read_settings': 'Read Settings',
      'watch_not_connected': 'Watch not connected',
      'syncing_with_watch': 'Syncing with Watch...',
      'screen_power': 'Screen & Power',
      'screen_timeout': 'Screen Timeout',
      'fall_detection_algorithms': 'Fall Detection Algorithms',
      'free_fall_threshold': 'Free Fall Threshold (Low G)',
      'impact_threshold': 'Impact Threshold (High G)',
      'stillness_tolerance': 'Stillness Tolerance',
      'stillness_duration': 'Stillness Duration',
      'angle_change_threshold': 'Angle Change Threshold',
      'done': 'Done',
      'settings_saved': 'Settings saved to Watch memory.',
      'action_origin': 'Action Origin (On Fall Detection)',
      'watch_only': 'Watch Only',
      'app_and_watch': 'App + Watch',
      'watch_wifi_credentials': 'Watch WiFi Credentials',
      'enable_watch_wifi': 'Enable Watch WiFi',
      'wifi_ssid': 'WiFi SSID',
      'wifi_password': 'WiFi Password',
      'watch_emergency_actions': 'Watch Emergency Actions',
      'enable_watch_sms': 'Enable Watch SMS',
      'sms_numbers': 'SMS Numbers (comma separated)',
      'enable_watch_call': 'Enable Watch Call',
      'call_numbers': 'Call Numbers (comma separated)',
      'enable_watch_sos': 'Enable Watch SOS',
      'sos_number': 'SOS Number',
      'set_time_on_watch': 'Set Watch Time',
       'watch_time_synced': 'Watch time synchronized',
       'error_syncing_time': 'Error syncing time',
      
      // App Safety Config
      'system_permissions': 'SYSTEM PERMISSIONS',
      'location_services': 'Location Services',
      'location_required': 'Required for BLE Scanning',
      'bluetooth_settings': 'Bluetooth Settings',
      'bluetooth_manage': 'Manage paired devices',
      'safety_configuration': 'SAFETY CONFIGURATION',
      'sms_notifications': 'SMS NOTIFICATIONS',
      'add_sms_number': 'Add SMS number...',
      'add_phone_number': 'Add Phone Number',
      'sequential_calls': 'SEQUENTIAL CALLS',
      'add_call_number': 'Add call number...',
      'sos_emergency_call': 'SOS EMERGENCY CALL',
      'sos_number_hint': 'SOS Number (e.g. 194)',
      'countdown_timer': 'COUNTDOWN TIMER',
      'sec': 'sec',
    },
    'sr': {
      // Main / Dashboard Strings
      'app_title': 'LifeLink',
      'dashboard': 'KONTROLNA TABLA',
      'settings': 'PODEŠAVANJA',
      'help': 'POMOĆ',
      'user_manual': 'Korisničko uputstvo',
      'device_connection': 'KONEKCIJA UREĐAJA',
      'connected': 'Povezano',
      'disconnected': 'Nije povezano',
      'no_devices_found': 'Nema pronađenih uređaja. Osvježite za skeniranje.',
      'scan_for_devices': 'Skeniraj druge uređaje',
      'default_device': 'Podrazumevano:',
      'disconnect': 'PREKINI VEZU',
      'connect': 'POVEŽI',
      'set_default': 'POSTAVI',
      'reconnect': 'PONOVO POVEŽI',
      'info': 'Informacije',
      'reset_alarm': 'PONIŠTI ALARM',
      'fall_detected_exclamation': 'DETEKTIVAN PAD!',
      'requesting_help_in': 'Zahtev za pomoć za',
      'im_ok': 'DOBRO SAM',
      'sending_to': 'Šalje se:',
      'emergency': 'Hitna Pomoć',
      'impact_g': 'UDARAC (G)',
      'system_nominal': 'SISTEM NOMINALAN',
      'monitoring_active': 'Praćenje aktivno',
      'movement_detected': 'POKRET DETEKTOVAN',
      'analyzing_impact': 'Analiza obrasca udarca...',
      'critical_alert': 'KRITIČNO UPOZORENJE',
      'tap_to_reconnect': 'Dodirni za povezivanje',
      'pulse': 'PULS',
      'spo2': 'SpO2',
      
      // Watch Settings
      'watch_hardware_settings': 'Hardverska Podešavanja Sata',
      'read_settings': 'Učitaj Podešavanja',
      'watch_not_connected': 'Sat nije povezan',
      'syncing_with_watch': 'Sinhronizacija sa satom...',
      'screen_power': 'Ekran i Napajanje',
      'screen_timeout': 'Gašenje Ekrana',
      'fall_detection_algorithms': 'Algoritmi za Detekciju Pada',
      'free_fall_threshold': 'Prag Slobodnog Pada (Nizak G)',
      'impact_threshold': 'Prag Udarca (Visok G)',
      'stillness_tolerance': 'Tolerancija Mirovanja',
      'stillness_duration': 'Trajanje Mirovanja',
      'angle_change_threshold': 'Prag Promene Ugla',
      'done': 'Sačuvaj',
      'settings_saved': 'Podešavanja su sačuvana u memoriju sata.',
      'action_origin': 'Izvor Akcija (Pri Detekciji Pada)',
      'watch_only': 'Samo Sat',
      'app_and_watch': 'Aplikacija + Sat',
      'watch_wifi_credentials': 'WiFi Kredencijali Sata',
      'enable_watch_wifi': 'Uključi WiFi na satu',
      'wifi_ssid': 'WiFi SSID',
      'wifi_password': 'WiFi Lozinka',
      'watch_emergency_actions': 'Hitne Akcije Sata',
      'enable_watch_sms': 'Uključi SMS sa Sata',
      'sms_numbers': 'SMS Brojevi (odvojeni zarezom)',
      'enable_watch_call': 'Uključi Poziv sa Sata',
      'call_numbers': 'Brojevi za Poziv (odvojeni zarezom)',
      'enable_watch_sos': 'Uključi SOS sa Sata',
      'sos_number': 'SOS Broj',
      'set_time_on_watch': 'Podesi Vreme na Satu',
       'watch_time_synced': 'Vreme na satu je sinhronizovano',
       'error_syncing_time': 'Greška pri sinhronizaciji vremena',

      // App Safety Config
      'system_permissions': 'SISTEMSKE DOZVOLE',
      'location_services': 'Lokacija',
      'location_required': 'Potrebno za BLE Skeniranje',
      'bluetooth_settings': 'Bluetooth Podešavanja',
      'bluetooth_manage': 'Upravljaj uparenim uređajima',
      'safety_configuration': 'SIGURNOSNA PODEŠAVANJA',
      'sms_notifications': 'SMS OBAVEŠTENJA',
      'add_sms_number': 'Dodaj SMS broj...',
      'add_phone_number': 'Dodaj Broj Telefona',
      'sequential_calls': 'SEKVENCIJALNI POZIVI',
      'add_call_number': 'Dodaj broj za poziv...',
      'sos_emergency_call': 'SOS HITNI POZIV',
      'sos_number_hint': 'SOS Broj (npr. 194)',
      'countdown_timer': 'ODBROJAVANJE',
      'sec': 'sek',
    }
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']?[key] ?? key;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'sr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
