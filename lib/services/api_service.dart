import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Centralized API service for LifeLink MariaDB backend on tsp.edu.rs
class ApiService {
  // Production URL for the MariaDB PHP API
  static const String _baseUrl = "http://lifelink.tsp.edu.rs/api/update.php";

  static Future<void> initialize() async {
    // No initialization needed for pure HTTP API
  }

  /// Registers or updates device info in MariaDB
  static Future<void> registerDevice({
    required String deviceId,
    required String deviceName,
    required int battery,
    required bool isOnline,
  }) async {
    try {
      await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'name': deviceName,
          'battery': battery,
          'isOnline': isOnline ? 1 : 0,
          'source': 'mobile_app',
        }),
      );
    } catch (e) {
      print("API registerDevice error: $e");
    }
  }

  /// Updates health data snapshot in MariaDB
  static Future<void> saveHealthSnapshot({
    required String deviceId,
    required int pulse,
    required int spo2,
    required double gForce,
    required int battery,
    required String source,
    double? lat,
    double? lon,
  }) async {
    try {
      await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'pulse': pulse,
          'spo2': spo2,
          'gForce': gForce,
          'battery': battery,
          'source': source,
          if (lat != null) 'lat': lat,
          if (lon != null) 'lon': lon,
        }),
      );
    } catch (e) {
      print("API saveHealthSnapshot error: $e");
    }
  }

  /// Logs a fall event in MariaDB
  static Future<void> saveFallEvent({
    required String deviceId,
    required LatLng? location,
    required double gForce,
    required int pulse,
    required int spo2,
  }) async {
    try {
      await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'is_fall': true,
          'gForce': gForce,
          'pulse': pulse,
          'spo2': spo2,
          if (location != null) 'lat': location.latitude,
          if (location != null) 'lon': location.longitude,
        }),
      );
    } catch (e) {
      print("API saveFallEvent alert error: $e");
    }
  }

  /// Updates connection status in MariaDB
  static Future<void> updateDeviceStatus(String deviceId, bool isOnline, int battery) async {
    try {
      await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'isOnline': isOnline ? 1 : 0,
          'battery': battery,
        }),
      );
    } catch (e) {
      print("API updateDeviceStatus error: $e");
    }
  }

  /// Updates phone's current location in MariaDB
  static Future<void> updatePhoneLocation({
    required String deviceId,
    required double lat,
    required double lon,
  }) async {
    try {
      await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'phoneLat': lat,
          'phoneLon': lon,
          'source': 'mobile_phone_gps',
        }),
      );
    } catch (e) {
      print("API updatePhoneLocation error: $e");
    }
  }
}
