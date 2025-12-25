import 'package:flutter/material.dart';
import 'vault_page.dart';
import 'simulation_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  
  // Daftar Halaman
  final List<Widget> _pages = [
    const VaultPage(),       // Halaman 0: Brankas
    const SimulationPage(),  // Halaman 1: Lab Edukasi
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], // Tampilkan halaman sesuai pilihan
      
      // MENU BAWAH (Bottom Navigation)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121212),
        selectedItemColor: const Color(0xFF00FF00), // Hijau Aktif
        unselectedItemColor: Colors.grey,           // Abu Tidak Aktif
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'My Vault',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Hacker Lab',
          ),
        ],
      ),
    );
  }
}