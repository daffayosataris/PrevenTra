import 'dart:math';

class PasswordStrength {
  
  // 1. FUNGSI MENGHITUNG ENTROPI (Rumus: E = L * log2(N))
  static double calculateEntropy(String password) {
    if (password.isEmpty) return 0.0;

    int poolSize = 0;
    
    // Cek Set Karakter (N)
    if (RegExp(r'[a-z]').hasMatch(password)) poolSize += 26; // Huruf kecil
    if (RegExp(r'[A-Z]').hasMatch(password)) poolSize += 26; // Huruf besar
    if (RegExp(r'[0-9]').hasMatch(password)) poolSize += 10; // Angka
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(password)) poolSize += 32; // Simbol

    if (poolSize == 0) return 0.0;

    // Hitung Entropi
    double entropy = password.length * (log(poolSize) / log(2));
    return entropy;
  }

  // 2. FUNGSI MENGHITUNG ESTIMASI WAKTU CRACK (Rumus: 2^E / GPU Speed)
  static String estimateCrackTime(double entropy) {
    if (entropy == 0.0) return "0 Detik";

    // Asumsi Kecepatan Hacker (GPU Speed): 1 Miliar tebakan per detik (10^9)
    double guessesPerSecond = 1e9; 
    
    // Total Kombinasi = 2 Pangkat Entropi
    double totalCombinations = pow(2, entropy).toDouble(); 
    
    // Waktu dalam detik
    double seconds = totalCombinations / guessesPerSecond;

    // Konversi detik ke format manusiawi
    if (seconds < 1) return "Instan (Sangat Lemah)";
    if (seconds < 60) return "${seconds.toStringAsFixed(0)} Detik";
    if (seconds < 3600) return "${(seconds / 60).toStringAsFixed(0)} Menit";
    if (seconds < 86400) return "${(seconds / 3600).toStringAsFixed(0)} Jam";
    if (seconds < 31536000) return "${(seconds / 86400).toStringAsFixed(0)} Hari";
    if (seconds < 3153600000) return "${(seconds / 31536000).toStringAsFixed(0)} Tahun";
    
    return "Ribuan Tahun (Aman)"; // Jika lebih dari seabad
  }
}