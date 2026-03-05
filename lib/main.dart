import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 👉 KUNCI JAWABAN: Import Provider
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/utils/background_audit_service.dart'; 
import 'presentation/providers/vault_provider.dart'; // 👉 KUNCI JAWABAN: Import VaultProvider
import 'presentation/pages/auth_page.dart';

// FUNGSI WAJIB: Harus berada di luar class (Top-Level Function)
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

  // Meminta Izin & Mengambil Token FCM
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);
  
  String? token = await messaging.getToken();
  print("\n====== T O K E N   F C M   H P   I N I ======");
  print(token);
  print("=============================================\n");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 👉 PERBAIKAN: Membungkus aplikasi dengan MultiProvider agar data tidak hilang
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VaultProvider()),
      ],
      child: MaterialApp(
        title: 'PrevenTra',
        theme: ThemeData.dark(),
        home: const AuthPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}