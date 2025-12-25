class DbConstants {
  // Nama Database
  static const String databaseName = 'preventra_vault.db';
  
  // Nama Tabel
  static const String tableAccounts = 'accounts';

  // Kolom Tabel Accounts
  static const String colId = 'id';
  static const String colTitle = 'title';       // Misal: "Instagram", "KlikBCA"
  static const String colUsername = 'username'; // Misal: "arenta_99"
  static const String colPassword = 'password'; // Password TERENKRIPSI
  static const String colIv = 'iv';             // Vector inisialisasi (untuk dekripsi)
  static const String colCreatedAt = 'created_at';
}