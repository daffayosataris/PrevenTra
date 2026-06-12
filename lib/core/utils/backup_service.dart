// Lokasi: lib/core/utils/backup_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt; 
import '../../data/datasources/database_helper.dart';
import '../../data/models/account_model.dart';

class BackupService {
  // Kunci Mutlak 32 Karakter & IV Mutlak 16 Karakter
  static final _key = encrypt.Key.fromUtf8('PrevenTraBackupKey32CharsLong!!!'); 
  static final _iv = encrypt.IV.fromUtf8('PrevenTraIV16Chr'); 

  // --- FUNGSI 1: BACKUP (EKSPOR) ---
  Future<String?> createBackup() async {
    try {
      List<AccountModel> accounts = await DatabaseHelper().getAccounts();
      if (accounts.isEmpty) return "Data Brankas kosong, tidak ada yang bisa di-backup.";

      List<Map<String, dynamic>> jsonList = accounts.map((e) => e.toMap()).toList();
      String jsonString = jsonEncode(jsonList);

      // 👉 PERBAIKAN: Mode AES dikunci eksplisit ke CBC
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encrypt(jsonString, iv: _iv);

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      String fileName = "PrevenTra_Backup_${DateTime.now().millisecondsSinceEpoch}.pvt";
      File file = File('${directory!.path}/$fileName');
      
      await file.writeAsString(encrypted.base64);

      return "SUKSES BERHASIL!\nFile aman di: Folder Download/$fileName";
    } catch (e) {
      print("ERROR BACKUP FATAL: $e");
      return null; 
    }
  }

  // --- FUNGSI 2: RESTORE (IMPOR) ---
  Future<String?> restoreBackup() async {
    try {
      await DatabaseHelper().database;

      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return "Proses Restore dibatalkan.";

      File file = File(result.files.single.path!);
      String encryptedContent = await file.readAsString();
      
      // 👉 PERBAIKAN: Sapu bersih SEMUA karakter gaib (spasi, enter, tab) dari Android
      encryptedContent = encryptedContent.replaceAll(RegExp(r'\s+'), '');

      // 👉 PERBAIKAN: Mode AES dikunci eksplisit ke CBC
      final encrypter = encrypt.Encrypter(encrypt.AES(_key, mode: encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedContent, iv: _iv);

      List<dynamic> jsonList = jsonDecode(decrypted);
      List<AccountModel> accounts = jsonList.map((e) => AccountModel.fromMap(e)).toList();

      int successCount = 0;
      for (var acc in accounts) {
        final newAcc = AccountModel(
          title: acc.title,
          username: acc.username,
          password: acc.password,
          createdAt: DateTime.now().toString(),
        );
        await DatabaseHelper().insertAccount(newAcc);
        successCount++;
      }

      return "BERHASIL KEMBALI!\n$successCount akun dipulihkan.";
    } catch (e) {
      print("ERROR RESTORE FATAL: $e");
      return "GAGAL RESTORE: File backup berasal dari versi lama atau format rusak.";
    }
  }
}