import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_sqlcipher/sqflite.dart'; 
import '../../core/constants/db_constants.dart';
// Import Model yang baru saja kita buat
import '../../data/models/account_model.dart';

class DatabaseHelper {
  // 1. SINGLETON PATTERN
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // 2. GETTER DATABASE
  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // KUNCI SEMENTARA (Nanti diganti Biometrik/PIN)
    String dummyKey = "RahasiaNegara123"; 
    
    _database = await _initDatabase(dummyKey);
    return _database!;
  }

  // 3. INISIALISASI DATABASE
  Future<Database> _initDatabase(String key) async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DbConstants.databaseName);

    return await openDatabase(
      path,
      version: 1,
      password: key, // Enkripsi AES-256 Aktif
      onCreate: _onCreate,
    );
  }

  // 4. MEMBUAT TABEL
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableAccounts} (
        ${DbConstants.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${DbConstants.colTitle} TEXT NOT NULL,
        ${DbConstants.colUsername} TEXT NOT NULL,
        ${DbConstants.colPassword} TEXT NOT NULL,
        ${DbConstants.colIv} TEXT NOT NULL,
        ${DbConstants.colCreatedAt} TEXT NOT NULL
      )
    ''');
    print("LOG: Brankas Berhasil Dibuat! Tabel 'accounts' siap.");
  }

  // ==================================================
  // FUNGSI BARU (CRUD)
  // ==================================================

  // FUNGSI 1: SIMPAN DATA BARU (CREATE)
  Future<int> insertAccount(AccountModel account) async {
    final db = await database;
    return await db.insert(
      DbConstants.tableAccounts,
      account.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // FUNGSI 2: AMBIL SEMUA DATA (READ)
  Future<List<AccountModel>> getAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(DbConstants.tableAccounts);

    return List.generate(maps.length, (i) {
      return AccountModel.fromMap(maps[i]);
    });
  }

// --- FUNGSI BARU UNTUK EDIT DATA ---
  Future<int> updateAccount(AccountModel account) async {
    final db = await database;
    return await db.update(
      'accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
  }

}