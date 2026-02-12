import 'package:flutter/material.dart';
import 'vault_page.dart';
import 'simulation_page.dart';
import 'tools_page.dart'; // IMPORT BARU: Halaman Alat Bantu

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  
  // Daftar Halaman (Urutan harus sama dengan icon di bawah)
  final List<Widget> _pages = [
    const VaultPage(),       // Halaman 0: Brankas
    const SimulationPage(),  // Halaman 1: Lab Edukasi
    const ToolsPage(),       // Halaman 2: Alat Bantu (Backup/Restore)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menampilkan halaman sesuai index yang dipilih
      body: _pages[_currentIndex], 
      
      // MENU BAWAH (Bottom Navigation)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212), // Warna latar belakang gelap
        selectedItemColor: const Color(0xFF00FF00), // Hijau Neon (Aktif)
        unselectedItemColor: Colors.grey,           // Abu-abu (Tidak Aktif)
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Agar posisi icon stabil jika > 3 menu
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          // MENU 1: VAULT
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'My Vault',
          ),
          // MENU 2: LAB
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Hacker Lab',
          ),
          // MENU 3: TOOLS (BARU)
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle), // Ikon obeng/kunci pas
            label: 'Tools',
          ),
        ],
      ),
    );
  }
}