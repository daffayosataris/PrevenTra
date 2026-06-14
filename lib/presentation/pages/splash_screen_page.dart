// Lokasi: lib/presentation/pages/splash_screen_page.dart

import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_page.dart';

class SplashScreenPage extends StatefulWidget {
  const SplashScreenPage({super.key});

  @override
  State<SplashScreenPage> createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Konfigurasi durasi animasi muncul perlahan (1.5 detik)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Mulai animasi
    _animationController.forward();

    // Timer: Pindah ke AuthPage setelah 3 detik
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Sinkron dengan Premium Light Theme
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // PEMANGGILAN LOGO DARI FOLDER ASSETS
              Image.asset(
                'assets/LOGO.png',
                width: 140, // Sesuaikan ukuran logo di sini
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              
              // TEKS JUDUL
              const Text(
                "PrevenTra",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              
              // TEKS SUBJUDUL
              const Text(
                "Personal Security Assistant",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}