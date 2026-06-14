import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../data/datasources/database_helper.dart';
import '../../data/datasources/hibp_service.dart';

class BackgroundAuditService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidInitSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
    );
  }

  static Future<void> executeSilentAudit() async {
    debugPrint(
      'MEMBANGUNKAN APLIKASI: Memulai Audit Kredensial Latar Belakang...',
    );

    final dbHelper = DatabaseHelper();
    final accounts = await dbHelper.getAccounts();

    if (accounts.isEmpty) {
      return;
    }

    final hibpService = HibpService();

    int totalLeaks = 0;
    final List<String> leakedAccounts = [];

    for (final acc in accounts) {
      final int leaks =
          await hibpService.checkPasswordSafety(acc.password);

      if (leaks > 0) {
        totalLeaks++;
        leakedAccounts.add(acc.title);
      }
    }

    if (totalLeaks > 0) {
      await _showBreachNotification(
        totalLeaks,
        leakedAccounts,
      );
    }
  }

  static Future<void> _showBreachNotification(
    int leakCount,
    List<String> leakedAccounts,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'breach_alert_loud_v1',
      'Peringatan Kebocoran (Darurat)',
      channelDescription:
          'Notifikasi darurat bersuara nyaring saat data bocor',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      color: Color(0xFFFF0000),
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    final String bodyText =
        'Bahaya! $leakCount akun Anda (${leakedAccounts.join(', ')}) terdeteksi bocor.';

    await _notificationsPlugin.show(
      id: 1,
      title: '⚠️ PERINGATAN KEBOCORAN DATA!',
      body: bodyText,
      notificationDetails: notificationDetails,
    );
  }
}