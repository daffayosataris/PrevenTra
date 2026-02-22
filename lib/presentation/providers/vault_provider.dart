import 'package:flutter/material.dart';
import '../../data/datasources/database_helper.dart';
import '../../data/models/account_model.dart';
import '../../data/datasources/hibp_service.dart'; 

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

  // PERBAIKAN 1: Sekarang menerima tipe data AccountModel secara utuh
  Future<void> addAccount(AccountModel newAccount) async {
    await DatabaseHelper().insertAccount(newAccount);
    await loadAccounts();
  }

  Future<void> deleteAccount(int id) async {
    final db = await DatabaseHelper().database;
    await db.delete('accounts', where: 'id = ?', whereArgs: [id]);
    await loadAccounts();
  }

  // Fungsi Edit Akun
  Future<void> updateAccount(AccountModel account) async {
    await DatabaseHelper().updateAccount(account); 
    await loadAccounts();
  }

  // --- FUNGSI BARU: AUDIT SECURITY ---
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