// Lokasi: lib/presentation/pages/auth_page.dart

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; 
import '../../core/utils/biometric_helper.dart';
import 'dashboard_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {

  // Fungsi Login Biometrik (Tetap Terjaga)
  void _loginWithBiometric() async {
    bool isAuthenticated = await BiometricHelper().authenticate();
    if (isAuthenticated && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Autentikasi Biometrik Dibatalkan")),
      );
    }
  }

  // Fungsi Login Manual PIN (Tetap Terjaga)
  void _loginWithPIN() async {
    final LocalAuthentication auth = LocalAuthentication();
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Gunakan PIN atau Pola layar HP Anda',
        options: const AuthenticationOptions(
          biometricOnly: false, 
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      if (authenticated && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardPage()));
      }
    } catch (e) {
      debugPrint("Error PIN: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna putih keabuan super bersih sesuai standar UI modern
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      
                      // 1. STRUKTUR IKON UTAMA (Dibuat minimalis dan presisi sesuai cetak biru)
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28), // Sudut melengkung halus, bukan lingkaran penuh
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.admin_panel_settings_rounded, // Ikon asisten keamanan profesional
                            size: 72,
                            color: Color(0xFF2563EB), // Warna Biru Primer Premium
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 2. TEKS JUDUL (Tipografi disesuaikan dengan bobot font desain)
                      const Text(
                        "PrevenTra",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800, // Lebih tegas dan solid
                          color: Color(0xFF0F172A), // Slate 900 untuk warna teks premium
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      
                      // 3. TEKS SUBJUDUL
                      const Text(
                        "Personal Security Assistant",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF64748B), // Slate 500 untuk kontras teks sekunder
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                      
                      const SizedBox(height: 80),

                      // 4. STRUKTUR TOMBOL MASUK SISTEM (Dibuat kokoh, sejajar, dan proporsional)
                      Row(
                        children: [
                          // Tombol Eksekusi Utama (PIN/Sandi)
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB), // Biru Murni Kompatibel
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _loginWithPIN,
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.lock_open_rounded, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      "Masuk Ke Brankas", 
                                      style: TextStyle(
                                        fontSize: 16, 
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          
                          // Tombol Akses Cepat Biometrik (Sidik Jari)
                          SizedBox(
                            height: 56,
                            width: 56,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF2563EB),
                                side: const BorderSide(
                                  color: Color(0xFFE2E8F0), // Border tipis transparan Slate 200
                                  width: 1.5,
                                ),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _loginWithBiometric,
                              child: const Icon(Icons.fingerprint_rounded, size: 28),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}