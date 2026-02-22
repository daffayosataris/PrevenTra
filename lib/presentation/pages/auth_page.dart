import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // Tambahkan library ini
import '../../core/utils/biometric_helper.dart';
import 'dashboard_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // Fungsi Login Biometrik (Sidik Jari/Wajah)
  void _loginWithBiometric() async {
    bool isAuthenticated = await BiometricHelper().authenticate();
    if (isAuthenticated && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Autentikasi Biometrik Dibatalkan")));
    }
  }

  // Fungsi Login Manual (PIN / Pola / Sandi Bawaan HP)
  void _loginWithPIN() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      // Memanggil sistem keamanan native Android (PIN/Pola)
      bool authenticated = await auth.authenticate(
        localizedReason: 'Gunakan PIN atau Pola layar HP Anda',
        options: const AuthenticationOptions(
          biometricOnly: false, // FALSE = Izinkan PIN/Pola
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );

      if (authenticated && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Terjadi kesalahan: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A), // Warna biru dongker elegan
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // HEADER (Logo & Judul)
              Column(
                children: [
                  const SizedBox(height: 50),
                  Icon(Icons.shield_moon, size: 80, color: Colors.blue[300]),
                  const SizedBox(height: 20),
                  const Text("PrevenTra", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  const SizedBox(height: 10),
                  const Text("Personal Security Assistant", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 40),
                  // Ilustrasi ala BRImo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      "Data Anda dienkripsi secara lokal.\nKami tidak menyimpan sandi Anda di server.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, height: 1.5),
                    ),
                  ),
                ],
              ),

              // TOMBOL LOGIN (Gaya BRImo)
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _loginWithPIN, // Panggil fungsi PIN/Pola
                        child: const Text("Login", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    height: 55,
                    width: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _loginWithBiometric, // Panggil fungsi Sidik Jari
                      child: const Icon(Icons.fingerprint, color: Colors.white, size: 30),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}