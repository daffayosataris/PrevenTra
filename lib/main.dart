import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Import Provider & Page yang sudah kita buat kemarin
import 'package:preventra/presentation/providers/vault_provider.dart';
import 'package:preventra/presentation/pages/vault_page.dart';
import 'package:preventra/presentation/pages/auth_page.dart';

void main() {
  runApp(const PreventraApp());
}

class PreventraApp extends StatelessWidget {
  const PreventraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // KITA BUNGKUS APLIKASI DENGAN MULTIPROVIDER
    // Agar "Otak" aplikasi (VaultProvider) bisa diakses dari mana saja
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VaultProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'PrevenTra',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF00FF00), // Hijau Hacker
          scaffoldBackgroundColor: const Color(0xFF121212), // Hitam Pekat
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF00FF00),
            secondary: Colors.greenAccent,
            surface: const Color(0xFF1E1E1E),
          ),
        ),
        // --- BAGIAN PENTING: GANTI HOME JADI VAULT PAGE ---
        // Jangan pakai HomePage() yang lama, tapi pakai VaultPage()
        home: const AuthPage(),
      ),
    );
  }
}