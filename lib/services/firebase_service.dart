import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  // Reference ke node utama 'led_data' di database baru
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('led_data');

  Stream<DatabaseEvent> getMainModeDataStream() {
    return _dbRef.child('main').onValue;
  }

// Fungsi untuk mendapatkan stream data Custom Mode (jika dibutuhkan nanti)
  Stream<DatabaseEvent> getCustomModeDataStream() {
    return _dbRef.child('custom').onValue;
  }
  // Fungsi untuk mengatur mode saat ini (main atau custom)
  Future<void> setCurrentMode(String mode) async {
    try {
      await _dbRef.child('mode').set(mode);
      print("✅ Mode berhasil diatur ke: $mode");
    } catch (e) {
      print("❌ Gagal mengatur mode: $e");
      rethrow;
    }
  }

  // Fungsi untuk memperbarui data di Main Mode
  Future<void> updateMainMode({
    required String status,
    required int brightness,
    required String color,
  }) async {
    try {
      await _dbRef.child('main').update({
        "status": status,
        "brightness": brightness,
        "color": color,
      });
      print("✅ Data Main Mode berhasil disimpan!");
    } catch (e) {
      print("❌ Gagal menyimpan data Main Mode: $e");
      rethrow;
    }
  }

  // Fungsi untuk memperbarui data di Custom Mode
  Future<void> updateCustomMode({
    required String effect,
    required int speed,
    required String color,
  }) async {
    try {
      await _dbRef.child('custom').update({
        "effect": effect,
        "speed": speed,
        "color": color,
      });
      print("✅ Data Custom Mode berhasil disimpan!");
    } catch (e) {
      print("❌ Gagal menyimpan data Custom Mode: $e");
      rethrow;
    }
  }
}