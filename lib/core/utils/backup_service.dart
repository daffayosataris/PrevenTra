import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:encrypt/encrypt.dart' as encrypt; // Library enkripsi tambahan
import '../../data/datasources/database_helper.dart';
import '../../data/models/account_model.dart';

class BackupService {
  // Kunci Enkripsi Statis (Simulasi Master Key untuk Backup)
  // Di versi Final nanti bisa diganti input PIN User
  static final _key = encrypt.Key.fromUtf8('PrevenTraBackupKey32CharsLong!!'); 
  static final _iv = encrypt.IV.fromLength(16);

  // --- FUNGSI 1: BACKUP (EKSPOR) ---
  // Sesuai Flowchart Gambar 3.4 di Laporan
  Future<String?> createBackup() async {
    try {
      // 1. Ambil semua data dari SQLite
      List<AccountModel> accounts = await DatabaseHelper().getAccounts();
      if (accounts.isEmpty) return "Data Kosong, tidak bisa backup.";

      // 2. Serialisasi (Ubah ke JSON)
      List<Map<String, dynamic>> jsonList = accounts.map((e) => e.toMap()).toList();
      String jsonString = jsonEncode(jsonList);

      // 3. Enkripsi AES-256 (Agar file aman jika dicuri)
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final encrypted = encrypter.encrypt(jsonString, iv: _iv);

      // 4. Simpan ke File (.pvt)
      // Kita simpan di folder Download HP agar mudah ditemukan
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      // Cek izin folder (jika gagal, pakai folder aplikasi)
      if (!await directory.exists()) directory = await getExternalStorageDirectory();

      String fileName = "PrevenTra_Backup_${DateTime.now().millisecondsSinceEpoch}.pvt";
      File file = File('${directory!.path}/$fileName');
      
      await file.writeAsString(encrypted.base64);

      return "SUKSES! File tersimpan di:\n${file.path}";
    } catch (e) {
      print("ERROR BACKUP: $e");
      return null; // Gagal
    }
  }

  // --- FUNGSI 2: RESTORE (IMPOR) ---
  // Sesuai Flowchart Gambar 3.5 di Laporan
  Future<String?> restoreBackup() async {
    try {
      // 1. Pilih File Backup (.pvt)
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result == null) return "Dibatalkan oleh user.";

      File file = File(result.files.single.path!);
      String encryptedContent = await file.readAsString();

      // 2. Dekripsi AES-256
      final encrypter = encrypt.Encrypter(encrypt.AES(_key));
      final decrypted = encrypter.decrypt64(encryptedContent, iv: _iv);

      // 3. Parsing JSON ke Objek
      List<dynamic> jsonList = jsonDecode(decrypted);
      List<AccountModel> accounts = jsonList.map((e) => AccountModel.fromMap(e)).toList();

      // 4. Simpan ke SQLite (Looping)
      int successCount = 0;
      for (var acc in accounts) {
        // Hapus ID lama agar auto-increment baru (mencegah duplikat ID crash)
        final newAcc = AccountModel(
          title: acc.title,
          username: acc.username,
          password: acc.password,
          createdAt: DateTime.now().toString(),
        );
        await DatabaseHelper().insertAccount(newAcc);
        successCount++;
      }

      return "BERHASIL! $successCount data dipulihkan.";
    } catch (e) {
      print("ERROR RESTORE: $e");
      return "GAGAL: File rusak atau password salah.";
    }
  }
}