import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle dual-writing to both Firebase Firestore and local MariaDB API
class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Placeholder URL - User should update to their server IP
  static const String _baseUrl = "http://192.168.1.100/api/update.php";

  static Future<void> initialize() async {
    // Firebase is initialized in main.dart
  }

  /// Registers or updates device info in BOTH MariaDB and Firestore
  static Future<void> registerDevice({
    required String deviceId,
    required String deviceName,
    required int battery,
    required bool isOnline,
  }) async {
    // 1. MariaDB Update
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
      print("API record error: $e");
    }

    // 2. Firebase Update
    try {
      await _firestore.collection('devices').doc(deviceId).set({
        'name': deviceName,
        'deviceId': deviceId,
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': isOnline,
        'battery': battery,
      }, SetOptions(merge: true));
    } catch (e) {
      print("Firebase record error: $e");
    }
  }

  /// Updates health data snapshot in BOTH MariaDB and Firestore
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
    // 1. MariaDB Update
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
      print("API health save error: $e");
    }

    // 2. Firebase Update
    try {
      final batch = _firestore.batch();
      final deviceRef = _firestore.collection('devices').doc(deviceId);
      
      Map<String, dynamic> deviceUpdate = {
        'pulse': pulse,
        'spo2': spo2,
        'gForce': gForce,
        'battery': battery,
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
        'uploadSource': source,
      };
      if (lat != null) deviceUpdate['lat'] = lat;
      if (lon != null) deviceUpdate['lon'] = lon;
      
      batch.set(deviceRef, deviceUpdate, SetOptions(merge: true));

      final snapshotRef = deviceRef.collection('health_snapshots').doc();
      Map<String, dynamic> snapshotData = {
        'timestamp': FieldValue.serverTimestamp(),
        'pulse': pulse,
        'spo2': spo2,
        'gForce': gForce,
        'battery': battery,
        'source': source,
      };
      if (lat != null) snapshotData['lat'] = lat;
      if (lon != null) snapshotData['lon'] = lon;
      
      batch.set(snapshotRef, snapshotData);
      await batch.commit();
    } catch (e) {
      print("Firebase health save error: $e");
    }
  }

  /// Logs a fall event in BOTH MariaDB and Firestore
  static Future<void> saveFallEvent({
    required String deviceId,
    required LatLng? location,
    required double gForce,
    required int pulse,
    required int spo2,
  }) async {
    // 1. MariaDB Update
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
      print("API fall alert error: $e");
    }

    // 2. Firebase Update
    try {
      await _firestore.collection('devices').doc(deviceId).collection('fall_events').add({
        'timestamp': FieldValue.serverTimestamp(),
        'lat': location?.latitude,
        'lon': location?.longitude,
        'gForce': gForce,
        'pulse': pulse,
        'spo2': spo2,
        'resolved': false,
      });
    } catch (e) {
      print("Firebase fall save error: $e");
    }
  }

  /// Updates connection status in BOTH MariaDB and Firestore
  static Future<void> updateDeviceStatus(String deviceId, bool isOnline, int battery) async {
    // 1. MariaDB
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
      print("API status error: $e");
    }

    // 2. Firebase
    try {
      await _firestore.collection('devices').doc(deviceId).update({
        'isOnline': isOnline,
        'battery': battery,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Firebase status error: $e");
    }
  }

  /// Updates phone's current location in BOTH MariaDB and Firestore
  static Future<void> updatePhoneLocation({
    required String deviceId,
    required double lat,
    required double lon,
  }) async {
    // 1. MariaDB
    try {
      await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'device_id': deviceId,
          'lat': lat,
          'lon': lon,
          'source': 'mobile_phone_gps',
        }),
      );
    } catch (e) {
      print("API location error: $e");
    }

    // 2. Firebase
    try {
      await _firestore.collection('devices').doc(deviceId).update({
        'phoneLat': lat,
        'phoneLon': lon,
        'phoneLastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Firebase location error: $e");
    }
  }
}
