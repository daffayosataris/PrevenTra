import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/utils/background_audit_service.dart';
import 'presentation/providers/vault_provider.dart';
import 'presentation/pages/splash_screen_page.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();

  debugPrint("================================");
  debugPrint("🔥 FCM MASUK BACKGROUND");
  debugPrint("DATA: ${message.data}");
  debugPrint("================================");

  if (message.data['action'] == 'TRIGGER_AUDIT') {
    debugPrint("🔥 MENJALANKAN AUDIT BACKGROUND");

    await BackgroundAuditService.initNotifications();
    await BackgroundAuditService.executeSilentAudit();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await BackgroundAuditService.initNotifications();

  FirebaseMessaging.onBackgroundMessage(
    _firebaseMessagingBackgroundHandler,
  );

  FirebaseMessaging messaging =
      FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  try {
    await messaging.subscribeToTopic(
      'audit_harian',
    );

    debugPrint(
      "🔥 BERHASIL SUBSCRIBE TOPIC audit_harian",
    );
  } catch (e) {
    debugPrint(
      "❌ GAGAL SUBSCRIBE TOPIC: $e",
    );
  }

  String? token =
      await FirebaseMessaging.instance.getToken();

  debugPrint(
      "====== T O K E N   F C M ======");
  debugPrint(token);
  debugPrint(
      "===============================");

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) async {
      debugPrint("================================");
      debugPrint("🔥 FCM MASUK FOREGROUND");
      debugPrint("DATA: ${message.data}");
      debugPrint("================================");

      if (message.data['action'] ==
          'TRIGGER_AUDIT') {
        debugPrint(
          "🔥 MENJALANKAN AUDIT FOREGROUND",
        );

        await BackgroundAuditService
            .executeSilentAudit();
      }
    },
  );

  FirebaseMessaging.onMessageOpenedApp.listen(
    (RemoteMessage message) async {
      debugPrint(
        "🔥 NOTIFIKASI DIBUKA USER",
      );

      if (message.data['action'] ==
          'TRIGGER_AUDIT') {
        await BackgroundAuditService
            .executeSilentAudit();
      }
    },
  );

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VaultProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'PrevenTra',
        debugShowCheckedModeBanner: false,
        home: const SplashScreenPage(),
      ),
    );
  }
}