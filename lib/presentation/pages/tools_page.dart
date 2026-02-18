import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/backup_service.dart';
import '../providers/vault_provider.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  bool _isLoading = false;

  // --- FUNGSI BACKUP ---
  void _handleBackup() async {
    setState(() => _isLoading = true);
    String? message = await BackupService().createBackup();
    setState(() => _isLoading = false);
    
    _showDialog(message != null ? "Backup Sukses" : "Backup Gagal", 
                message ?? "Terjadi kesalahan sistem.");
  }

  // --- FUNGSI RESTORE ---
  void _handleRestore() async {
    setState(() => _isLoading = true);
    String? message = await BackupService().restoreBackup();
    
    // Refresh tampilan Vault jika restore sukses
    if (message != null && message.contains("BERHASIL")) {
      Provider.of<VaultProvider>(context, listen: false).loadAccounts();
    }
    
    setState(() => _isLoading = false);
    _showDialog("Status Restore", message ?? "Gagal memproses file.");
  }

  // --- FITUR BARU: GENERATOR PASSWORD & PASSPHRASE ---
  void _showPasswordGenerator() {
    double length = 16;
    double wordCount = 3; // Untuk mode Passphrase
    bool useUpper = true;
    bool useLower = true;
    bool useNumbers = true;
    bool useSymbols = true;
    bool isPassphraseMode = false; // Toggle Mode
    String generatedPassword = "Klik 'GENERATE' 👇";

    // Kamus kata sederhana untuk Passphrase (Bisa ditambah ratusan kata lagi nanti)
    final List<String> kamusIndo = [
      'gajah', 'kucing', 'mobil', 'sepeda', 'gunung', 'laut', 'langit', 'bintang', 
      'kopi', 'buku', 'meja', 'pintu', 'rumah', 'jendela', 'kaca', 'lampu', 
      'merah', 'biru', 'hijau', 'hitam', 'putih', 'besar', 'kecil', 'cepat', 
      'lambat', 'kuat', 'pintar', 'maju', 'sukses', 'jaya', 'elang', 'harimau',
      'laptop', 'kode', 'data', 'sistem', 'aman', 'kunci', 'awan', 'angin'
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (ctx) => StatefulBuilder( // StatefulBuilder penting agar UI BottomSheet bisa update
        builder: (BuildContext context, StateSetter setModalState) {

          void generate() {
            Random rnd = Random();
            String result = "";

            if (isPassphraseMode) {
              // --- MODE PASSPHRASE (Mudah Dihafal, Sangat Kuat) ---
              for (int i = 0; i < wordCount.toInt(); i++) {
                String word = kamusIndo[rnd.nextInt(kamusIndo.length)];
                // Ubah huruf pertama jadi kapital (Title Case)
                word = word[0].toUpperCase() + word.substring(1); 
                result += word;
                if (i < wordCount.toInt() - 1) result += "-"; // Karakter Pemisah
              }
              // Tambahkan ekstra keamanan (Angka/Simbol di belakang) jika dicentang
              if (useNumbers) result += "${rnd.nextInt(99)}";
              if (useSymbols) {
                String sym = "!@#\$%^&*";
                result += sym[rnd.nextInt(sym.length)];
              }
            } else {
              // --- MODE ACAK (Random String Konvensional) ---
              String chars = "";
              if (useUpper) chars += "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
              if (useLower) chars += "abcdefghijklmnopqrstuvwxyz";
              if (useNumbers) chars += "0123456789";
              if (useSymbols) chars += "!@#\$%^&*()_+~`|}{[]:;?><,./-=";

              if (chars.isEmpty) {
                setModalState(() => generatedPassword = "Pilih minimal 1 opsi!");
                return;
              }

              for (int i = 0; i < length.toInt(); i++) {
                result += chars[rnd.nextInt(chars.length)];
              }
            }
            
            setModalState(() => generatedPassword = result);
          }

          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24, right: 24, top: 24
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("PASSWORD GENERATOR", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 25),

                // LAYAR TAMPILAN PASSWORD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.5)),
                  ),
                  child: Text(
                    generatedPassword,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.purpleAccent, 
                      fontSize: isPassphraseMode ? 16 : 22, // Perkecil font jika mode passphrase agar muat
                      fontFamily: 'Courier', 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // TOGGLE MODE (Biasa vs Passphrase)
                SwitchListTile(
                  title: const Text("Mode Passphrase", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Gunakan frasa bahasa Indonesia (Mudah dihafal)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  value: isPassphraseMode,
                  activeColor: Colors.purpleAccent,
                  onChanged: (val) => setModalState(() => isPassphraseMode = val),
                ),
                const Divider(color: Colors.white24),

                // SLIDER DINAMIS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isPassphraseMode ? "Jumlah Kata" : "Panjang Karakter", style: const TextStyle(color: Colors.grey)),
                    Text(isPassphraseMode ? "${wordCount.toInt()} Kata" : "${length.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Slider(
                  value: isPassphraseMode ? wordCount : length,
                  min: isPassphraseMode ? 2 : 8,
                  max: isPassphraseMode ? 5 : 32,
                  activeColor: Colors.purpleAccent,
                  inactiveColor: Colors.grey[800],
                  onChanged: (val) {
                    setModalState(() {
                      if (isPassphraseMode) {
                        wordCount = val;
                      } else {
                        length = val;
                      }
                    });
                  },
                ),

                // CHECKBOX OPSI EKSTRA
                if (!isPassphraseMode) ...[
                  _buildCheckbox("Huruf Besar (A-Z)", useUpper, (val) => setModalState(() => useUpper = val!)),
                  _buildCheckbox("Huruf Kecil (a-z)", useLower, (val) => setModalState(() => useLower = val!)),
                ],
                _buildCheckbox("Sertakan Angka (0-9)", useNumbers, (val) => setModalState(() => useNumbers = val!)),
                _buildCheckbox("Sertakan Simbol (!@#\$...)", useSymbols, (val) => setModalState(() => useSymbols = val!)),
                
                const SizedBox(height: 25),

                // TOMBOL AKSI
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        icon: const Icon(Icons.copy, color: Colors.white),
                        label: const Text("SALIN", style: TextStyle(color: Colors.white)),
                        onPressed: () {
                          if (generatedPassword.length > 5 && !generatedPassword.contains("Klik")) {
                            Clipboard.setData(ClipboardData(text: generatedPassword));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password disalin!"), backgroundColor: Colors.purple));
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: generate,
                        child: const Text("GENERATE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildCheckbox(String title, bool value, ValueChanged<bool?> onChanged) {
    return CheckboxListTile(
      title: Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.purpleAccent,
      checkColor: Colors.black,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(title, style: const TextStyle(color: Colors.greenAccent)),
        content: Text(content, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ALAT BANTU (TOOLS)", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2, 
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildToolCard(Icons.save_alt, "Backup Data", "Ekspor ke .pvt", _handleBackup, Colors.blue),
                _buildToolCard(Icons.restore_page, "Restore Data", "Impor File .pvt", _handleRestore, Colors.orange),
                _buildToolCard(Icons.password, "Generator", "Buat Pass Kuat", _showPasswordGenerator, Colors.purple), 
                _buildToolCard(Icons.security, "Cek Root", "Integritas HP", () {}, Colors.red), // Placeholder untuk fitur Root Checker
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Gunakan Generator untuk membuat sandi unik setiap kali Anda mendaftar akun baru.",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator(color: Colors.greenAccent)),
            ),
        ],
      ),
    );
  }

  Widget _buildToolCard(IconData icon, String title, String subtitle, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 5),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}