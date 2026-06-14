// Lokasi: lib/presentation/pages/dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../../core/utils/password_strength.dart'; 
import 'vault_page.dart';
import 'simulation_page.dart';
import 'tools_page.dart'; 
import 'info_aplikasi_page.dart'; // 👉 PERUBAHAN: Import file baru

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final vaultProvider = Provider.of<VaultProvider>(context);
    int totalAkun = vaultProvider.accounts.length;

    int akunBerisiko = 0;
    for (var acc in vaultProvider.accounts) {
      double entropy = PasswordStrength.calculateEntropy(acc.password);
      if (entropy < 40) {
        akunBerisiko++;
      }
    }

    final List<Widget> pages = [
      _buildHomeHub(totalAkun, akunBerisiko), 
      const VaultPage(),        
      const SimulationPage(),   
      const ToolsPage(),        
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Color(0x0D000000), blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white, 
          selectedItemColor: const Color(0xFF2563EB), 
          unselectedItemColor: const Color(0xFF94A3B8), 
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
            BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: 'Brankas'),
            BottomNavigationBarItem(icon: Icon(Icons.science_rounded), label: 'Edukasi'),
            BottomNavigationBarItem(icon: Icon(Icons.build_rounded), label: 'Alat'),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeHub(int totalAkun, int akunBerisiko) {
    String statusTeks;
    String subTeks;
    List<Color> cardGradient;
    IconData statusIcon;

    if (totalAkun == 0) {
      statusTeks = "Belum Ada Data";
      subTeks = "Brankas Anda masih kosong";
      cardGradient = [const Color(0xFF64748B), const Color(0xFF475569)]; 
      statusIcon = Icons.gpp_bad_rounded;
    } else if (akunBerisiko > 0) {
      statusTeks = "Sistem Terancam!";
      subTeks = "$akunBerisiko Kredensial Terdeteksi Lemah/Berisiko!";
      cardGradient = [const Color(0xFFEF4444), const Color(0xFFB91C1C)]; 
      statusIcon = Icons.gpp_maybe_rounded;
    } else {
      statusTeks = "Sistem Terlindungi";
      subTeks = "$totalAkun Kredensial Aman di Brankas";
      cardGradient = [const Color(0xFF2563EB), const Color(0xFF1D4ED8)]; 
      statusIcon = Icons.gpp_good_rounded;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "PrevenTra Hub", 
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: -0.5)
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // 👉 PERBAIKAN: Mengubah ikon gerigi menjadi ikon info_outline_rounded
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF475569)),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoAplikasiPage()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: cardGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: cardGradient[0].withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("STATUS KEAMANAN", style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                      Icon(statusIcon, color: Colors.white70, size: 24),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    statusTeks, 
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Divider(color: Colors.white24, height: 1),
                  ),
                  Row(
                    children: [
                      Icon(akunBerisiko > 0 ? Icons.warning_rounded : Icons.folder_shared_rounded, color: Colors.white70, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subTeks, 
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text("MENU NAVIGASI UTAMA", style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.05,
              children: [
                _buildMenuGridCard("Brankas Data", "Kelola sandi aman", Icons.shield_outlined, const Color(0xFF2563EB), const Color(0xFFEFF6FF), () {
                  setState(() => _currentIndex = 1); 
                }),
                _buildMenuGridCard("Lab Edukasi", "Simulasi serangan", Icons.science_outlined, const Color(0xFF22C55E), const Color(0xFFF0FDF4), () {
                  setState(() => _currentIndex = 2); 
                }),
                _buildMenuGridCard("Alat Keamanan", "Backup & Generator", Icons.build_outlined, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), () {
                  setState(() => _currentIndex = 3); 
                }),
                // 👉 PERBAIKAN: Mengubah Menu Pengaturan menjadi Info Aplikasi dengan ikon info_outline_rounded
                _buildMenuGridCard("Info Aplikasi", "Detail & Kredit", Icons.info_outline_rounded, const Color(0xFF475569), const Color(0xFFF8FAFC), () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const InfoAplikasiPage())); 
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGridCard(String title, String subtitle, IconData icon, Color mainColor, Color bgColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: mainColor, size: 26),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 15)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}