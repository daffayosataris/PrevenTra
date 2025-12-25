import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<VaultProvider>(context, listen: false).loadAccounts()
    );
  }

  void _copyToClipboard(BuildContext context, String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Password Disalin! (Hapus otomatis 60dtk)"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Timer(const Duration(seconds: 60), () {
      Clipboard.setData(const ClipboardData(text: ""));
    });
  }

  void _deleteItem(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Hapus Data?", style: TextStyle(color: Colors.white)),
        content: const Text("Data akan hilang permanen.", style: TextStyle(color: Colors.grey)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Provider.of<VaultProvider>(context, listen: false).deleteAccount(id);
              Navigator.pop(ctx);
            },
            child: const Text("HAPUS", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // --- FITUR BARU: POPUP AUDIT ---
  void _auditPassword(BuildContext context, String password) {
    showDialog(
      context: context,
      barrierDismissible: false, // User gak bisa klik luar untuk tutup (biar loading selesai dulu)
      builder: (ctx) => const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    // Panggil Service HIBP
    Provider.of<VaultProvider>(context, listen: false)
        .checkSinglePassword(password)
        .then((result) {
      Navigator.pop(context); // Tutup Loading
      
      // Tentukan warna alert
      bool isDanger = result.contains("BAHAYA");
      Color alertColor = isDanger ? Colors.red : Colors.green;
      IconData icon = isDanger ? Icons.warning_amber_rounded : Icons.verified_user_rounded;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          icon: Icon(icon, color: alertColor, size: 50),
          title: Text(isDanger ? "DATA LEAKED!" : "SECURE", style: TextStyle(color: alertColor)),
          content: Text(result, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("TUTUP", style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PREVENTRA VAULT", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<VaultProvider>(context, listen: false).loadAccounts(),
          )
        ],
      ),
      body: Consumer<VaultProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator(color: Colors.green));
          if (provider.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 16),
                  const Text("Brankas Aman & Kosong", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.accounts.length,
            itemBuilder: (context, index) {
              final account = provider.accounts[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.green[900],
                    child: Text(account.title.isNotEmpty ? account.title[0].toUpperCase() : "?", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(account.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(account.username, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      const Text("••••••••••••", style: TextStyle(color: Colors.greenAccent, letterSpacing: 2, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOMBOL 1: RADAR (AUDIT)
                      IconButton(
                        icon: const Icon(Icons.radar, color: Colors.orangeAccent),
                        onPressed: () => _auditPassword(context, account.password),
                        tooltip: "Cek Kebocoran",
                      ),
                      // TOMBOL 2: COPY
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: () => _copyToClipboard(context, account.password),
                      ),
                      // TOMBOL 3: HAPUS
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _deleteItem(context, account.id!),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FF00),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => _showAddDialog(context),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final titleController = TextEditingController();
    final userController = TextEditingController();
    final passController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: const Text("Simpan Password Baru", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(titleController, "Nama Aplikasi (cth: GitHub)"),
            const SizedBox(height: 10),
            _buildTextField(userController, "Username / Email"),
            const SizedBox(height: 10),
            _buildTextField(passController, "Password"),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("BATAL", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800]),
            onPressed: () {
              if (titleController.text.isNotEmpty && passController.text.isNotEmpty) {
                Provider.of<VaultProvider>(context, listen: false).addAccount(titleController.text, userController.text, passController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text("SIMPAN", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: const Color(0xFF121212),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}