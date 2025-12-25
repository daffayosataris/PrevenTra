import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHelper {
  final LocalAuthentication _auth = LocalAuthentication();

  // 1. Cek apakah HP punya pengamanan? (Entah itu Sidik Jari ATAU PIN/Pola)
  Future<bool> isDeviceSupported() async {
    try {
      // isDeviceSupported mengecek apakah HP ini aman (punya lockscreen)
      return await _auth.isDeviceSupported();
    } on PlatformException catch (e) {
      print("ERROR SUPPORT CHECK: $e");
      return false;
    }
  }

  // 2. Lakukan Autentikasi (Sidik Jari / PIN / Pola)
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Gunakan Sidik Jari atau PIN untuk masuk',
        options: const AuthenticationOptions(
          // --- BAGIAN PENTING YANG DIUBAH ---
          biometricOnly: false, // FALSE = Boleh pakai PIN/Pola/Sandi
          stickyAuth: true,     // Agar dialog tidak hilang saat switch mode
          useErrorDialogs: true, // Tampilkan error bawaan Android jika gagal
        ),
      );
    } on PlatformException catch (e) {
      print("ERROR AUTH: $e");
      return false;
    }
  }
}