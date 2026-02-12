import 'package:flutter/material.dart';
import '../../core/utils/backup_service.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  bool _isLoading = false;

  // Fungsi Wrapper untuk memanggil BackupService dengan Loading UI
  void _handleBackup() async {
    setState(() => _isLoading = true);
    String? message = await BackupService().createBackup();
    setState(() => _isLoading = false);
    
    _showDialog(message != null ? "Backup Sukses" : "Backup Gagal", 
                message ?? "Terjadi kesalahan sistem.");
  }

  void _handleRestore() async {
    setState(() => _isLoading = true);
    String? message = await BackupService().restoreBackup();
    
    // Refresh tampilan Vault jika sukses
    if (message != null && message.contains("BERHASIL")) {
      Provider.of<VaultProvider>(context, listen: false).loadAccounts();
    }
    
    setState(() => _isLoading = false);
    _showDialog("Status Restore", message ?? "Gagal memproses file.");
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
        title: const Text("ALAT BANTU (TOOLS)", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GridView.count(
              crossAxisCount: 2, // 2 Kolom sesuai desain Gambar 3.15
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildToolCard(Icons.save_alt, "Backup Data", "Ekspor ke .pvt", _handleBackup, Colors.blue),
                _buildToolCard(Icons.restore_page, "Restore Data", "Impor File .pvt", _handleRestore, Colors.orange),
                _buildToolCard(Icons.password, "Generator", "Buat Pass Kuat", () {}, Colors.purple), // Placeholder
                _buildToolCard(Icons.security, "Cek Root", "Integritas HP", () {}, Colors.red),     // Placeholder
              ],
            ),
          ),
          
          // Info Box di Bawah (Sesuai Desain)
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
                      "Gunakan fitur Backup secara berkala untuk mencegah kehilangan data jika HP rusak.",
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