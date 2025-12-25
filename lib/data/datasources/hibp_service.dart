import 'dart:convert';
import 'package:crypto/crypto.dart'; // Untuk hashing SHA-1
import 'package:dio/dio.dart'; // Untuk request internet

class HibpService {
  final Dio _dio = Dio();

  // Fungsi: Cek apakah password pernah bocor
  // Return: Jumlah kebocoran (0 = Aman, >0 = Bahaya)
  Future<int> checkPasswordSafety(String password) async {
    try {
      // 1. HASHING (Ubah password jadi kode SHA-1)
      var bytes = utf8.encode(password);
      var digest = sha1.convert(bytes);
      String hash = digest.toString().toUpperCase(); // Contoh: 5BAA61E4C9...

      // 2. K-ANONYMITY (Ambil 5 huruf depan saja)
      String prefix = hash.substring(0, 5); // 5BAA6
      String suffix = hash.substring(5);    // 1E4C9...

      // 3. API CALL (Tanya ke HaveIBeenPwned)
      // Kita cuma kirim 5 huruf, jadi server TIDAK TAU password aslinya.
      final response = await _dio.get('https://api.pwnedpasswords.com/range/$prefix');

      if (response.statusCode == 200) {
        String data = response.data.toString();
        // 4. CEK LOKAL (Cari suffix kita di dalam jawaban server)
        List<String> lines = data.split('\n'); // Pisahkan per baris
        
        for (var line in lines) {
          List<String> parts = line.split(':');
          String serverSuffix = parts[0];
          int count = int.parse(parts[1]);

          if (serverSuffix == suffix) {
            // KETEMU! Password ini sudah bocor sebanyak 'count' kali
            return count; 
          }
        }
      }
      return 0; // Tidak ketemu, berarti Aman.
    } catch (e) {
      print("ERROR HIBP: $e");
      return -1; // -1 Kode Error (misal gak ada internet)
    }
  }
}