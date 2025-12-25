import 'package:flutter/material.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/models/account_model.dart';
import '../../data/datasources/hibp_service.dart'; // Import Service Baru

class VaultProvider extends ChangeNotifier {
  List<AccountModel> _accounts = [];
  bool _isLoading = true;

  List<AccountModel> get accounts => _accounts;
  bool get isLoading => _isLoading;

  Future<void> loadAccounts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _accounts = await DatabaseHelper().getAccounts();
    } catch (e) {
      print("ERROR PROVIDER: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAccount(String title, String username, String password) async {
    final newAccount = AccountModel(
      title: title,
      username: username,
      password: password,
      createdAt: DateTime.now().toString(),
    );
    await DatabaseHelper().insertAccount(newAccount);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
    await loadAccounts();
  }

  // --- FUNGSI BARU: AUDIT SECURITY ---
  // Mengembalikan String pesan hasil audit
  Future<String> checkSinglePassword(String password) async {
    int leaks = await HibpService().checkPasswordSafety(password);
    
    if (leaks == -1) {
      return "ERROR: Cek koneksi internet!";
    } else if (leaks == 0) {
      return "AMAN: Password belum pernah bocor.";
    } else {
      return "BAHAYA: Password ini bocor di $leaks database hacker!";
    }
  }
}