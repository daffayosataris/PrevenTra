// Lokasi: lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/utils/background_audit_service.dart'; 
import 'presentation/providers/vault_provider.dart'; 
import 'presentation/pages/splash_screen_page.dart'; 

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data.isNotEmpty) {
    if (message.data['action'] == 'TRIGGER_AUDIT') {
      await BackgroundAuditService.initNotifications();
      await BackgroundAuditService.executeSilentAudit();
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await BackgroundAuditService.initNotifications();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  
  // 👉 KODE EMAS BARU: Mendaftarkan HP ini ke kelompok (Topic) Audit Harian
  try {
    await messaging.subscribeToTopic('audit_harian');
    debugPrint("\n=============================================");
    debugPrint("🔥 MISI SUKSES: Yang Mulia, HP ini telah resmi bergabung ke topik 'audit_harian'!");
    debugPrint("=============================================\n");
  } catch (e) {
    debugPrint("❌ GAGAL BERGABUNG KE TOPIK: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VaultProvider()),
      ],
      child: MaterialApp(
        title: 'PrevenTra',
        // TEMA TERANG (LIGHT THEME) YANG BERSIH DAN PROFESIONAL
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F7FA), // Latar belakang abu-abu sangat muda
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blueAccent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          useMaterial3: true,
        ),
        // Menjadikan Splash Screen dengan animasi Fade-In sebagai halaman awal aplikasi
        home: const SplashScreenPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}