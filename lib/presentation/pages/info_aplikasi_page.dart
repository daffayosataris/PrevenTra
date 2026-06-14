// Lokasi: lib/presentation/pages/info_aplikasi_page.dart

import 'package:flutter/material.dart';

class InfoAplikasiPage extends StatelessWidget {
  const InfoAplikasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Info Aplikasi", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Color(0xFF0F172A), letterSpacing: -0.5)
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // PANEL PROFIL UTAMA
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 32),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Pengguna PrevenTra", 
                      style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800)
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Status: Aktif & Terlindungi", 
                      style: TextStyle(color: Color(0xFF22C55E), fontSize: 13, fontWeight: FontWeight.w600)
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 32),

          // SEKSI INFORMASI PRODUK
          const Text(
            "INFORMASI APLIKASI", 
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)
          ),
          const SizedBox(height: 12),
          _buildInfoTile(Icons.info_outline_rounded, "Versi Aplikasi", "v1.0.0 (Final Project)"),

          const SizedBox(height: 28),

          // SEKSI KREDIT PENGEMBANG
          const Text(
            "KREDIT PENGEMBANG", 
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)
          ),
          const SizedBox(height: 12),
          _buildInfoTile(Icons.code_rounded, "Nama Pengembang", "Daffa Yosataris"),
          _buildInfoTile(Icons.badge_rounded, "Peran Utama", "Full-Stack Developer"),
          _buildInfoTile(Icons.palette_rounded, "Spesialisasi", "UI/UX Designer"),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x02000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF475569), size: 22),
        ),
        title: Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 15)),
        trailing: Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 13)),
      ),
    );
  }
}