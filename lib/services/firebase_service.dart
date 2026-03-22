import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> initialize() async {
    // Firebase.initializeApp() should be called in main.dart
  }

  /// Registers or updates device info in Firestore
  static Future<void> registerDevice({
    required String deviceId,
    required String deviceName,
    required int battery,
    required bool isOnline,
  }) async {
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

  /// Updates health data snapshot for a device
  static Future<void> saveHealthSnapshot({
    required String deviceId,
    required int pulse,
    required int spo2,
    required double gForce,
    required int battery,
    required String source, // 'ble' or 'wifi'
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Update main device document
      final deviceRef = _firestore.collection('devices').doc(deviceId);
      batch.set(deviceRef, {
        'pulse': pulse,
        'spo2': spo2,
        'gForce': gForce,
        'battery': battery,
        'lastSeen': FieldValue.serverTimestamp(),
        'isOnline': true,
        'uploadSource': source,
      }, SetOptions(merge: true));

      // Add to history
      final snapshotRef = deviceRef.collection('health_snapshots').doc();
      batch.set(snapshotRef, {
        'timestamp': FieldValue.serverTimestamp(),
        'pulse': pulse,
        'spo2': spo2,
        'gForce': gForce,
        'battery': battery,
        'source': source,
      });

      await batch.commit();
    } catch (e) {
      print("Firebase health save error: $e");
    }
  }

  /// Logs a fall event
  static Future<void> saveFallEvent({
    required String deviceId,
    required LatLng? location,
    required double gForce,
    required int pulse,
    required int spo2,
  }) async {
    try {
      await _firestore
          .collection('devices')
          .doc(deviceId)
          .collection('fall_events')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'lat': location?.latitude,
        'lon': location?.longitude,
        'gForce': gForce,
        'pulse': pulse,
        'spo2': spo2,
        'resolved': false,
      });
    } catch (e) {
      print("Firebase fall alert save error: $e");
    }
  }

  /// Updates connection status
  static Future<void> updateDeviceStatus(String deviceId, bool isOnline, int battery) async {
    try {
      await _firestore.collection('devices').doc(deviceId).update({
        'isOnline': isOnline,
        'battery': battery,
        'lastSeen': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Might fail if device doc doesn't exist yet, but registration handles that
      print("Firebase status update error: $e");
    }
  }
}
