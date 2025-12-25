import 'dart:math'; // WAJIB: Import library matematika

class PasswordStrength {
  // Kecepatan Hacker: 1 Miliar tebakan per detik (RTX 4090 Bruteforce)
  static const double guessesPerSecond = 1000000000; 

  static Map<String, dynamic> calculate(String password) {
    if (password.isEmpty) {
      return {"score": 0, "time": "0 detik", "color": 0xFF808080};
    }

    // 1. Hitung Pool Size (Variasi Karakter)
    int poolSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26; // a-z
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26; // A-Z
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10; // 0-9
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) poolSize += 32; // Simbol

    // Jika user cuma ketik simbol aneh yang tidak terdeteksi, kasih nilai default 1 biar gak error
    if (poolSize == 0) poolSize = 1;

    // 2. Hitung Entropi (Total Kemungkinan)
    // RUMUS BENAR: Pool Pangkat Panjang (poolSize ^ length)
    // Contoh: PIN 6 angka = 10^6 = 1 Juta kombinasi
    num combinations = pow(poolSize, password.length);
    
    // 3. Hitung Waktu (Detik)
    double seconds = combinations / guessesPerSecond;

    // 4. Konversi ke Waktu Manusia
    String timeString = _humanizeTime(seconds);
    
    // 5. Tentukan Skor (0-4)
    int score = 0;
    if (poolSize > 10 && seconds > 60) score = 1;       
    if (poolSize > 20 && seconds > 3600) score = 2;     
    if (poolSize > 40 && seconds > 86400 * 30) score = 3; 
    if (seconds > 31536000 * 100) score = 4; // Sangat Kuat (> 100 Tahun)

    return {
      "score": score,
      "time": timeString,
      "combinations": combinations,
    };
  }

  static String _humanizeTime(double seconds) {
    if (seconds < 0.0001) return "Instan (0 Detik)"; // Sangat cepat
    if (seconds < 1) return "${seconds.toStringAsFixed(4)} Detik";
    if (seconds < 60) return "${seconds.toStringAsFixed(1)} Detik";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(1)} Menit";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(1)} Jam";
    if (seconds < 31536000) return "${(seconds / 86400).toStringAsFixed(1)} Hari";
    if (seconds < 3153600000) return "${(seconds / 31536000).toStringAsFixed(1)} Tahun";
    
    // Jika angka terlalu besar, pakai notasi ilmiah atau kata-kata
    return "Berabad-abad";
  }
}