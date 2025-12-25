import 'package:flutter/material.dart';
// IMPORT PAKET ANIMASI BARU
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/utils/biometric_helper.dart';
import 'dashboard_page.dart'; 

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isAuthenticating = false;
  // Ubah teks awal agar lebih "techy"
  String _status = "INITIALIZING SECURITY PROTOCOLS...";

  @override
  void initState() {
    super.initState();
    // Beri jeda sedikit sebelum cek biometrik agar animasi sempat terlihat
    Future.delayed(const Duration(seconds: 2), () {
      _checkSecurity();
    });
  }

  Future<void> _checkSecurity() async {
    setState(() {
      _isAuthenticating = true;
      _status = "SCANNING BIOMETRICS / CREDENTIALS...";
    });
    
    bool isSupported = await BiometricHelper().isDeviceSupported();
    
    if (!isSupported) {
      setState(() {
        _isAuthenticating = false;
        _status = "SECURITY BREACH WARNING!\nDevice lock not detected.\nEnable PIN/Pattern in settings.";
      });
      return; 
    }

    bool authenticated = await BiometricHelper().authenticate();

    setState(() => _isAuthenticating = false);

    if (authenticated) {
      setState(() => _status = "ACCESS GRANTED. WELCOME.");
      // Jeda sedikit biar user baca "Access Granted" sebelum pindah
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      }
    } else {
      setState(() => _status = "ACCESS DENIED.\nTap button to retry authentication.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Gunakan Stack agar kita bisa menaruh efek background jika mau nanti
      body: Stack(
        children: [
          // --- EFEK BACKGROUND SAMAR (Opsional: Grid Hacker) ---
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/icon.png', repeat: ImageRepeat.repeat),
            ).animate().fade(duration: 2000.ms), // Background muncul perlahan
          ),

          // --- KONTEN UTAMA ---
          Center(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. ANIMASI LOGO/ICON
                  const Icon(Icons.lock_person_rounded, size: 100, color: Color(0xFF00FF00))
                  .animate() // Mulai animasi
                  .scale(duration: 600.ms, curve: Curves.easeOutBack) // Muncul membesar (pop)
                  .then(delay: 200.ms) // Tunggu sebentar
                  .shimmer(duration: 1500.ms, color: Colors.white.withOpacity(0.4)) // Efek kilatan scan
                  .then(delay: 500.ms)
                  // Efek "bernapas" (berdenyut pelan) terus menerus
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .scaleXY(end: 1.05, duration: 1000.ms), 
                  
                  const SizedBox(height: 30),
                  
                  // 2. ANIMASI JUDUL
                  const Text(
                    "PREVENTRA LOCK",
                    style: TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3, // Spasi huruf lebih lebar ala terminal
                      fontFamily: 'Courier', // Font ala coding
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 500.ms) // Muncul perlahan
                  .slideY(begin: 0.5, end: 0), // Bergeser dari bawah ke atas
                  
                  const SizedBox(height: 20),
                  
                  // 3. ANIMASI STATUS TEXT
                  AnimatedSwitcher(
                    // Agar teks berubah dengan animasi halus
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _status,
                      key: ValueKey(_status), // Penting untuk AnimatedSwitcher
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.greenAccent, height: 1.5, fontFamily: 'Courier', fontSize: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // 4. ANIMASI TOMBOL COBA LAGI
                  if (!_isAuthenticating)
                    ElevatedButton.icon(
                      onPressed: _checkSecurity,
                      icon: const Icon(Icons.key),
                      label: const Text("RE-AUTHENTICATE"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.greenAccent) // Garis pinggir neon
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1000.ms) // Muncul paling terakhir
                    .slideY(begin: 1, end: 0), // Geser dari bawah
                    
                  // Loading Indicator jika sedang scan
                  if (_isAuthenticating)
                     const CircularProgressIndicator(color: Colors.greenAccent)
                     .animate().fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}