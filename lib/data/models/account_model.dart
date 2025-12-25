class AccountModel {
  final int? id;
  final String title;     // Contoh: "Facebook", "Tokopedia"
  final String username;  // Contoh: "budi@gmail.com"
  final String password;  // Password (nanti akan kita enkripsi lagi di level aplikasi)
  final String iv;        // Vector enkripsi (biarkan kosong dulu)
  final String createdAt; // Tanggal dibuat

  AccountModel({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.iv = '', 
    required this.createdAt,
  });

  // Mengubah Data Objek menjadi Map (Agar bisa disimpan ke Database SQL)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'iv': iv,
      'created_at': createdAt,
    };
  }

  // Mengubah Map dari Database menjadi Objek Aplikasi (Agar bisa ditampilkan di UI)
  factory AccountModel.fromMap(Map<String, dynamic> map) {
    return AccountModel(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
      iv: map['iv'],
      createdAt: map['created_at'],
    );
  }
}