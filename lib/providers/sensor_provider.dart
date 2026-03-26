import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vibration/vibration.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';

import 'package:android_intent_plus/android_intent.dart';
import '../services/ble_service.dart';
import '../services/api_service.dart';

enum AlertState { safe, warning, alarm }

// Removed single selection FallAction enum as it's now multi-select via checkboxes

class SensorProvider with ChangeNotifier {
  final BleService _bleService = BleService();

  AlertState _alertState = AlertState.safe;
  String _rawMessage = "Waiting for data...";
  double _gForce = 0.0;
  int _pulse = 0;
  int _spo2 = 0;
  int _batteryLevel = 0;
  bool _isConnected = false;
  String? _locale; // Current locale code (e.g., 'en', 'sr')

  String _debugStatus = "";

  // Multi-Action Safety Settings
  bool _enableSms = false;
  List<String> _smsNumbers = [];

  bool _enableCall = false;
  List<String> _callNumbers = [];

  bool _enableSos = false;
  String _sosNumber = "194"; // Emergency in Serbia
  int _countdownDuration = 5;

  // Countdown State
  bool _isCountingDown = false;
  int _currentCountdown = 0;
  Timer? _countdownTimer;

  // State
  String? _defaultDeviceAddress;
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  // Watch Settings State
  int _watchScreenTimeoutMs = 15000;
  double _watchFallLow = 0.6;
  double _watchFallHigh = 3.5;
  double _watchStillTol = 0.2;
  double _watchAngleThr = 60.0;
  int _watchStillDur = 5000;

  // New Watch-Specific Action/Network Settings
  bool _watchWifiEnabled = false;
  String _watchWifiSsid = "";
  String _watchWifiPass = "";
  bool _watchEnableSms = false;
  String _watchSmsNumbers = "";
  bool _watchEnableCall = false;
  String _watchCallNumbers = "";
  bool _watchEnableSos = false;
  String _watchSosNumber = "";
  int _watchActionOrigin = 0; // 0: Watch Only, 1: App + Watch

  bool _isSyncingWatchSettings = false;
  DateTime? _lastSyncTime;

  AlertState get alertState => _alertState;
  String get rawMessage => _rawMessage;
  double get gForce => _gForce;
  int get pulse => _pulse;
  int get spo2 => _spo2;
  int get batteryLevel => _batteryLevel;
  bool get isConnected => _isConnected;
  LatLng? get fallLocation => _fallLocation;
  String? get locale => _locale;

  // Getters for Settings & UI
  bool get enableSms => _enableSms;
  List<String> get smsNumbers => _smsNumbers;
  bool get enableCall => _enableCall;
  List<String> get callNumbers => _callNumbers;
  bool get enableSos => _enableSos;
  String get sosNumber => _sosNumber;

  // Compatibility getters for Dashboard
  String get emergencyContactName => "Emergency Protocol";
  String get emergencyContactNumber => _sosNumber;

  int get countdownDuration => _countdownDuration.clamp(1, 10);
  bool get isCountingDown => _isCountingDown;
  int get currentCountdown => _currentCountdown;
  List<ScanResult> get scanResults => _scanResults;
  bool get isScanning => _isScanning;
  String? get defaultDeviceAddress => _defaultDeviceAddress;
  String? get connectedDeviceAddress =>
      _bleService.connectedDevice?.remoteId.toString();
  String get connectedDeviceName =>
      _bleService.connectedDevice?.platformName ?? "Unknown Device";

  // Watch Settings Getters
  int get watchScreenTimeoutMs => _watchScreenTimeoutMs;
  double get watchFallLow => _watchFallLow;
  double get watchFallHigh => _watchFallHigh;
  double get watchStillTol => _watchStillTol;
  double get watchAngleThr => _watchAngleThr;
  int get watchStillDur => _watchStillDur;

  bool get watchWifiEnabled => _watchWifiEnabled;
  String get watchWifiSsid => _watchWifiSsid;
  String get watchWifiPass => _watchWifiPass;
  bool get watchEnableSms => _watchEnableSms;
  String get watchSmsNumbers => _watchSmsNumbers;
  bool get watchEnableCall => _watchEnableCall;
  String get watchCallNumbers => _watchCallNumbers;
  bool get watchEnableSos => _watchEnableSos;
  String get watchSosNumber => _watchSosNumber;
  int get watchActionOrigin => _watchActionOrigin;

  bool get isSyncingWatchSettings => _isSyncingWatchSettings;

  LatLng? _fallLocation;

  SensorProvider() {
    _init();
  }

  void _init() async {
    await _loadSettings();
    await _bleService.init(); // Wait for permissions

    // Listen to connection state
    // Listen to connection state
    _bleService.connectionStateStream.listen((state) {
      _isConnected = (state == BluetoothConnectionState.connected);

      if (_isConnected) {
        stopScan();
        // Register/update device on connect
        if (connectedDeviceAddress != null) {
          ApiService.registerDevice(
            deviceId: connectedDeviceAddress!,
            deviceName: connectedDeviceName,
            battery: _batteryLevel,
            isOnline: true,
          );
        }
      } else {
        // Update status on disconnect
        if (_defaultDeviceAddress != null) {
          ApiService.updateDeviceStatus(
            _defaultDeviceAddress!,
            false,
            _batteryLevel,
          );
        }
      }

      notifyListeners();
      if (!_isConnected) {
        _rawMessage = "Disconnected";
      }
    });

    // Listen to data stream
    _bleService.dataStream.listen((data) {
      _parseData(data);
    });

    // Listen to scan results
    _bleService.scanResultsStream.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    // Attempt Auto-Connect
    if (_defaultDeviceAddress != null && _defaultDeviceAddress!.isNotEmpty) {
      _debugStatus = "Init: Waiting 1s...";
      notifyListeners();
      // Small delay to ensure BLE stack is ready
      await Future.delayed(const Duration(seconds: 1));
      startScan(isAutoConnect: true);
    } else {
      _debugStatus = "Init: No default.";
      notifyListeners();
    }
    
    // Start periodic phone location sync (every 5 mins)
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (_defaultDeviceAddress != null) {
        _syncPhoneLocationToApi();
      }
    });
  }

  Future<void> _syncPhoneLocationToApi() async {
    if (_defaultDeviceAddress == null) return;
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );
      await ApiService.updatePhoneLocation(
        deviceId: _defaultDeviceAddress!,
        lat: position.latitude,
        lon: position.longitude,
      );
      print("Synced phone location to MariaDB: ${position.latitude}, ${position.longitude}");
    } catch (e) {
      print("Failed to sync phone location: $e");
    }
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _defaultDeviceAddress = prefs.getString('default_device_address');

    // Multi-action loading
    _enableSms = prefs.getBool('enable_sms') ?? false;
    _smsNumbers = prefs.getStringList('sms_numbers') ?? [];

    _enableCall = prefs.getBool('enable_call') ?? false;
    _callNumbers = prefs.getStringList('call_numbers') ?? [];

    _enableSos = prefs.getBool('enable_sos') ?? false;
    _sosNumber = prefs.getString('sos_number') ?? "194";

    _countdownDuration = (prefs.getInt('countdown_duration') ?? 5).clamp(1, 10);
    _locale = prefs.getString('app_locale');
    notifyListeners();
  }

  Future<void> saveSettings({
    bool? enableSms,
    List<String>? smsNumbers,
    bool? enableCall,
    List<String>? callNumbers,
    bool? enableSos,
    String? sosNumber,
    int? duration,
    String? deviceAddress,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (enableSms != null) {
      _enableSms = enableSms;
      prefs.setBool('enable_sms', enableSms);
    }
    if (smsNumbers != null) {
      _smsNumbers = smsNumbers;
      prefs.setStringList('sms_numbers', smsNumbers);
    }
    if (enableCall != null) {
      _enableCall = enableCall;
      prefs.setBool('enable_call', enableCall);
    }
    if (callNumbers != null) {
      _callNumbers = callNumbers;
      prefs.setStringList('call_numbers', callNumbers);
    }
    if (enableSos != null) {
      _enableSos = enableSos;
      prefs.setBool('enable_sos', enableSos);
    }
    if (sosNumber != null) {
      _sosNumber = sosNumber;
      prefs.setString('sos_number', sosNumber);
    }
    if (duration != null) {
      _countdownDuration = duration;
      prefs.setInt('countdown_duration', duration);
    }
    if (deviceAddress != null) {
      _defaultDeviceAddress = deviceAddress;
      prefs.setString('default_device_address', deviceAddress);
    }
    notifyListeners();
  }

  Future<void> setLocale(String? localeCode) async {
    final prefs = await SharedPreferences.getInstance();
    _locale = localeCode;
    if (localeCode != null) {
      await prefs.setString('app_locale', localeCode);
    } else {
      await prefs.remove('app_locale');
    }
    notifyListeners();
  }

  Future<void> _ensureBluetoothOn() async {
    if (Platform.isAndroid) {
      try {
        final state = await FlutterBluePlus.adapterState.first;
        if (state == BluetoothAdapterState.off) {
          await FlutterBluePlus.turnOn();
          // Wait briefly for the adapter to fully initialize
          await Future.delayed(const Duration(seconds: 1));
        }
      } catch (e) {
        print("Could not turn on Bluetooth automatically: $e");
        await openBluetoothSettings();
      }
    }
  }

  Future<void> startScan({bool isAutoConnect = false}) async {
    await _ensureBluetoothOn();
    _isScanning = true;
    _scanResults = [];
    notifyListeners();
    _bleService.startScan();

    if (isAutoConnect && _defaultDeviceAddress != null) {
      _debugStatus = "Auto: Start $_defaultDeviceAddress";
      notifyListeners();

      try {
        for (var d in FlutterBluePlus.connectedDevices) {
          if (d.remoteId.toString() == _defaultDeviceAddress) {
            _debugStatus = "Auto: System Connected!";
            notifyListeners();
            connect(d);
            return;
          }
        }
      } catch (e) {
        _debugStatus = "Auto: Sys Check Error";
      }

      StreamSubscription? sub;
      sub = _bleService.scanResultsStream.listen((results) {
        for (var r in results) {
          // Case-insensitive check
          if (r.device.remoteId.toString().toLowerCase() ==
              _defaultDeviceAddress?.toLowerCase()) {
            _bleService.log("Auto: Found! Connecting...");
            notifyListeners();
            connect(r.device);
            sub?.cancel();
            break;
          }
        }
      });

      Future.delayed(const Duration(seconds: 10), () {
        sub?.cancel();
        if (!_isConnected && isAutoConnect) {
          _bleService.log("Auto: Timeout. Not found.");
          notifyListeners();
        }
      });
    }
  }

  // --- Watch Settings Sync Methods ---
  Future<void> readWatchSettings() async {
    if (!isConnected) return;

    _isSyncingWatchSettings = true;
    notifyListeners();

    try {
      final data = await _bleService.readCharacteristic();
      if (data != null && data.isNotEmpty) {
        final jsonString = utf8.decode(data);
        final Map<String, dynamic> settings = jsonDecode(jsonString);

        if (settings.containsKey('screen_timeout'))
          _watchScreenTimeoutMs = settings['screen_timeout'];
        if (settings.containsKey('fall_low'))
          _watchFallLow = (settings['fall_low'] as num).toDouble();
        if (settings.containsKey('fall_high'))
          _watchFallHigh = (settings['fall_high'] as num).toDouble();
        if (settings.containsKey('still_tol'))
          _watchStillTol = (settings['still_tol'] as num).toDouble();
        if (settings.containsKey('angle_thr'))
          _watchAngleThr = (settings['angle_thr'] as num).toDouble();
        if (settings.containsKey('still_dur'))
          _watchStillDur = settings['still_dur'];

        if (settings.containsKey('wifi_en'))
          _watchWifiEnabled = settings['wifi_en'] == true;
        if (settings.containsKey('wifi_ssid'))
          _watchWifiSsid = settings['wifi_ssid'] ?? "";
        if (settings.containsKey('wifi_pass'))
          _watchWifiPass = settings['wifi_pass'] ?? "";
        if (settings.containsKey('en_sms'))
          _watchEnableSms = settings['en_sms'] == true;
        if (settings.containsKey('sms_nums'))
          _watchSmsNumbers = settings['sms_nums'] ?? "";
        if (settings.containsKey('en_call'))
          _watchEnableCall = settings['en_call'] == true;
        if (settings.containsKey('call_nums'))
          _watchCallNumbers = settings['call_nums'] ?? "";
        if (settings.containsKey('en_sos'))
          _watchEnableSos = settings['en_sos'] == true;
        if (settings.containsKey('sos_num'))
          _watchSosNumber = settings['sos_num'] ?? "";
        if (settings.containsKey('act_orig'))
          _watchActionOrigin = settings['act_orig'] ?? 0;
      }
    } catch (e) {
      print("Failed to read watch settings: $e");
    } finally {
      _isSyncingWatchSettings = false;
      notifyListeners();
    }
  }

  Future<bool> writeWatchSettings({
    int? screenTimeoutMs,
    double? fallLow,
    double? fallHigh,
    double? stillTol,
    double? angleThr,
    int? stillDur,
    bool? wifiEnabled,
    String? wifiSsid,
    String? wifiPass,
    bool? enableSms,
    String? smsNumbers,
    bool? enableCall,
    String? callNumbers,
    bool? enableSos,
    String? sosNumber,
    int? actionOrigin,
    String? syncTime,
  }) async {
    if (!isConnected) return false;

    _isSyncingWatchSettings = true;
    notifyListeners();

    try {
      final Map<String, dynamic> settings = {};

      if (screenTimeoutMs != null) settings['screen_timeout'] = screenTimeoutMs;
      if (fallLow != null) settings['fall_low'] = fallLow;
      if (fallHigh != null) settings['fall_high'] = fallHigh;
      if (stillTol != null) settings['still_tol'] = stillTol;
      if (angleThr != null) settings['angle_thr'] = angleThr;
      if (stillDur != null) settings['still_dur'] = stillDur;
      if (wifiEnabled != null) settings['wifi_en'] = wifiEnabled;
      if (wifiSsid != null) settings['wifi_ssid'] = wifiSsid;
      if (wifiPass != null) settings['wifi_pass'] = wifiPass;
      if (enableSms != null) settings['en_sms'] = enableSms;
      if (smsNumbers != null) settings['sms_nums'] = smsNumbers;
      if (enableCall != null) settings['en_call'] = enableCall;
      if (callNumbers != null) settings['call_nums'] = callNumbers;
      if (enableSos != null) settings['en_sos'] = enableSos;
      if (sosNumber != null) settings['sos_num'] = sosNumber;
      if (actionOrigin != null) settings['act_orig'] = actionOrigin;
      if (syncTime != null) settings['sync_time'] = syncTime;

      if (settings.isEmpty) {
        _isSyncingWatchSettings = false;
        notifyListeners();
        return true;
      }

      final jsonString = jsonEncode(settings);
      final data = utf8.encode(jsonString);

      bool success = await _bleService.writeCharacteristic(data);
      if (success) {
        // Update local state if successful
        if (screenTimeoutMs != null) _watchScreenTimeoutMs = screenTimeoutMs;
        if (fallLow != null) _watchFallLow = fallLow;
        if (fallHigh != null) _watchFallHigh = fallHigh;
        if (stillTol != null) _watchStillTol = stillTol;
        if (angleThr != null) _watchAngleThr = angleThr;
        if (stillDur != null) _watchStillDur = stillDur;
        if (wifiEnabled != null) _watchWifiEnabled = wifiEnabled;
        if (wifiSsid != null) _watchWifiSsid = wifiSsid;
        if (wifiPass != null) _watchWifiPass = wifiPass;
        if (enableSms != null) _watchEnableSms = enableSms;
        if (smsNumbers != null) _watchSmsNumbers = smsNumbers;
        if (enableCall != null) _watchEnableCall = enableCall;
        if (callNumbers != null) _watchCallNumbers = callNumbers;
        if (enableSos != null) _watchEnableSos = enableSos;
        if (sosNumber != null) _watchSosNumber = sosNumber;
        if (actionOrigin != null) _watchActionOrigin = actionOrigin;
      }
      return success;
    } catch (e) {
      print("Failed to write watch settings: $e");
      return false;
    } finally {
      _isSyncingWatchSettings = false;
      notifyListeners();
    }
  }

  void stopScan() {
    _isScanning = false;
    _bleService.stopScan();
    notifyListeners();
  }

  void connect(BluetoothDevice device) async {
    await _bleService.connectToDevice(device);
  }

  void disconnect() {
    _bleService.disconnect();
  }

  void _parseData(List<int> data) {
    try {
      String msg = utf8.decode(data).trim();
      _rawMessage = msg;

      AlertState previousState = _alertState;

      if (msg.startsWith("POTENTIAL_FALL")) {
        _alertState = AlertState.warning;
        _extractMetrics(msg);
      } else if (msg.startsWith("FALL_ACCEPTED")) {
        if (_alertState != AlertState.alarm && !_isCountingDown) {
          _alertState = AlertState.alarm;
          _startCountdown();
        }
        _extractMetrics(msg);
      } else if (msg.startsWith("FALL_DETECTED")) {
        if (_alertState != AlertState.alarm && !_isCountingDown) {
          _alertState = AlertState.alarm;
          _startCountdown();
        }
        _extractMetrics(msg);
      } else if (msg.startsWith("STATUS")) {
        _extractMetrics(msg);
        _syncToApi();
      }

      // Always log falls to the server immediately
      if (msg.startsWith("FALL_DETECTED") || msg.startsWith("FALL_ACCEPTED")) {
        if (connectedDeviceAddress != null) {
          ApiService.saveFallEvent(
            deviceId: connectedDeviceAddress!,
            location: _fallLocation,
            gForce: _gForce,
            pulse: _pulse,
            spo2: _spo2,
          );
        }
      }

      if (_alertState != previousState) {
        _handleHaptics(_alertState);
      }

      notifyListeners();
    } catch (e) {
      print("Parse Error: $e");
    }
  }

  void _startCountdown() {
    _isCountingDown = true;
    _currentCountdown = _countdownDuration;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentCountdown--;
      if (_currentCountdown <= 0) {
        _countdownTimer?.cancel();
        _isCountingDown = false;
        _executeFallAction();
      }
      notifyListeners();
    });
  }

  void cancelFall() {
    _countdownTimer?.cancel();
    _isCountingDown = false;
    resetAlarm();
  }

  Future<void> _executeFallAction() async {
    print("Executing Multi-Action Protocol...");

    // 1. Send SMS if enabled
    if (_enableSms && _smsNumbers.isNotEmpty) {
      String googleMapsUrl = _fallLocation != null
          ? "https://maps.google.com/?q=${_fallLocation?.latitude},${_fallLocation?.longitude}"
          : "Location unavailable";

      String message = "SOS! LifeLink detected a fall. $googleMapsUrl";

      for (String number in _smsNumbers) {
        if (number.trim().isEmpty) continue;
        final Uri smsLaunchUri = Uri(
          scheme: 'sms',
          path: number,
          queryParameters: <String, String>{'body': message},
        );
        try {
          if (await canLaunchUrl(smsLaunchUri)) {
            await launchUrl(smsLaunchUri);
          }
        } catch (e) {
          print("SMS Error for $number: $e");
        }
      }
    }

    // 2. Sequential Calls if enabled
    if (_enableCall && _callNumbers.isNotEmpty) {
      for (String number in _callNumbers) {
        if (number.trim().isEmpty) continue;
        print("Sequential Call trying: $number");
        try {
          // Direct call (no user confirmation required once permission granted)
          await FlutterPhoneDirectCaller.callNumber(number);

          // Note: detection of "answered" vs "not answered" requires native telephony listeners.
          // In Flutter, we could wait some time or check call logs (if permitted),
          // but for now we initiate the protocol.

          // Wait briefly before trying next (if dialer was closed or failed)
          await Future.delayed(const Duration(seconds: 15));
        } catch (e) {
          print("Call error for $number: $e");
        }
      }
    }

    // 3. SOS Call if enabled
    if (_enableSos && _sosNumber.isNotEmpty) {
      final Uri launchUri = Uri(scheme: 'tel', path: _sosNumber);
      await launchUrl(launchUri);
    }
  }

  void _handleHaptics(AlertState state) async {
    // Vibration is only supported on mobile
    if (!Platform.isAndroid && !Platform.isIOS) return;

    bool hasVibrator = await Vibration.hasVibrator() ?? false;
    if (!hasVibrator) return;

    if (state == AlertState.alarm) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000, 500, 1000],
        intensities: [128, 255, 128, 255, 128, 255],
      );
    } else if (state == AlertState.warning) {
      Vibration.vibrate(duration: 500);
    } else {
      Vibration.cancel();
    }
  }

  void _extractMetrics(String msg) {
    RegExp latReg = RegExp(r"Lat:\s*([0-9.-]+)");
    RegExp lonReg = RegExp(r"Lon:\s*([0-9.-]+)");
    RegExp gReg = RegExp(r"G:\s*([0-9.]+)");
    RegExp pReg = RegExp(r"P:\s*([0-9]+)");
    RegExp sReg = RegExp(r"S:\s*([0-9]+)");
    RegExp bReg = RegExp(r"B:\s*([0-9]+)");

    var latMatch = latReg.firstMatch(msg);
    var lonMatch = lonReg.firstMatch(msg);
    var gMatch = gReg.firstMatch(msg);
    var pMatch = pReg.firstMatch(msg);
    var sMatch = sReg.firstMatch(msg);
    var bMatch = bReg.firstMatch(msg);

    if (latMatch != null && lonMatch != null) {
      double lat = double.tryParse(latMatch.group(1)!) ?? 0.0;
      double lon = double.tryParse(lonMatch.group(1)!) ?? 0.0;
      if (lat != 0.0 || lon != 0.0) {
        _fallLocation = LatLng(lat, lon);
      } else if (_alertState == AlertState.alarm) {
        _fetchPhoneLocation();
      }
    } else if (_alertState == AlertState.alarm && _fallLocation == null) {
      _fetchPhoneLocation();
    }

    if (gMatch != null) _gForce = double.tryParse(gMatch.group(1)!) ?? _gForce;
    if (pMatch != null) _pulse = int.tryParse(pMatch.group(1)!) ?? _pulse;
    if (sMatch != null) _spo2 = int.tryParse(sMatch.group(1)!) ?? _spo2;
    if (bMatch != null) {
      _batteryLevel = int.tryParse(bMatch.group(1)!) ?? _batteryLevel;
    }
  }

  void resetAlarm() {
    _alertState = AlertState.safe;
    _isCountingDown = false;
    _countdownTimer?.cancel();
    _gForce = 0.0;
    notifyListeners();
  }

  Future<void> _fetchPhoneLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      _fallLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
      print("Used Phone GPS for Fall Location: $_fallLocation");
    } catch (e) {
      print("Error fetching phone location: $e");
    }
  }

  void retryConnection() async {
    await _ensureBluetoothOn();
    startScan(isAutoConnect: true);
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openBluetoothSettings() async {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.BLUETOOTH_SETTINGS',
      );
      await intent.launch();
    } else if (Platform.isWindows) {
      // Open Windows Bluetooth settings
      await Process.run('start', ['ms-settings:bluetooth'], runInShell: true);
    }
  }

  void _syncToApi() {
    if (!_isConnected || connectedDeviceAddress == null) return;

    // If watch has WiFi enabled, it should send its own snapshots.
    // We only send from app if WiFi is disabled OR as a less frequent backup.
    if (_watchWifiEnabled) return;

    final now = DateTime.now();
    if (_lastSyncTime == null ||
        now.difference(_lastSyncTime!).inSeconds >= 30) {
      _lastSyncTime = now;

      ApiService.saveHealthSnapshot(
        deviceId: connectedDeviceAddress!,
        pulse: _pulse,
        spo2: _spo2,
        gForce: _gForce,
        battery: _batteryLevel,
        source: 'ble',
        lat: _fallLocation?.latitude,
        lon: _fallLocation?.longitude,
      );
    }
  }

  @override
  void notifyListeners() {
    // If there's a frame in progress, defer the notification until after the frame.
    // This prevents "setState() or markNeedsBuild() called during build" errors.
    try {
      if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
        Future.microtask(() => super.notifyListeners());
      } else {
        super.notifyListeners();
      }
    } catch (e) {
      // Fallback for cases where SchedulerBinding might not be initialized
      Future.microtask(() => super.notifyListeners());
    }
  }
}
