// Lokasi: lib/presentation/pages/vault_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/vault_provider.dart';
import '../../data/models/account_model.dart';

class VaultPage extends StatefulWidget {
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VaultProvider>(context, listen: false).loadAccounts();
    });
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
            const SizedBox(width: 10),
            Text("$label berhasil disalin", style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAccountDialog({AccountModel? existingAccount}) {
    final titleCtrl = TextEditingController(text: existingAccount?.title ?? '');
    final userCtrl = TextEditingController(text: existingAccount?.username ?? '');
    final passCtrl = TextEditingController(text: existingAccount?.password ?? '');
    bool isEdit = existingAccount != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isEdit ? "Edit Akun Brankas" : "Tambah Kredensial Baru", 
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: "Nama Aplikasi atau Situs Web",
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userCtrl,
                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  labelText: "Username, Email, atau No. HP",
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passCtrl,
                style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Kata Sandi / Rahasia Keamanan",
                  labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  floatingLabelStyle: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w600),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.only(bottom: 20, right: 24, left: 24),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 15)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              final vaultProvider = Provider.of<VaultProvider>(context, listen: false);
              if (isEdit) {
                final updated = AccountModel(
                  id: existingAccount.id,
                  title: titleCtrl.text,
                  username: userCtrl.text,
                  password: passCtrl.text,
                  createdAt: existingAccount.createdAt,
                );
                vaultProvider.updateAccount(updated);
              } else {
                final newAccount = AccountModel(
                  title: titleCtrl.text,
                  username: userCtrl.text,
                  password: passCtrl.text,
                  createdAt: DateTime.now().toString(),
                );
                vaultProvider.addAccount(newAccount);
              }
              Navigator.pop(ctx);
            },
            child: const Text("Simpan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  void _handleAudit(String password) async {
    final provider = Provider.of<VaultProvider>(context, listen: false);
    String result = await provider.checkSinglePassword(password);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.analytics_rounded, color: Color(0xFF2563EB), size: 26),
            SizedBox(width: 12),
            Text("Analisis Kredensial", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(result, style: const TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.5, fontWeight: FontWeight.w400)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: const Text(
          "Brankas Data", 
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: -0.5)
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE2E8F0),
              radius: 18,
              // 👉 PERBAIKAN: Menggunakan Color(0xFF475569) untuk menggantikan Colors.slate.shade600
              child: const Icon(Icons.person_rounded, color: Color(0xFF475569), size: 20),
            ),
          )
        ],
      ),
      body: Consumer<VaultProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)));
          }
          if (provider.accounts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                    // 👉 PERBAIKAN: Menggunakan Color(0xFF94A3B8) untuk menggantikan Colors.slate.shade400
                    child: const Icon(Icons.folder_open_rounded, size: 64, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Brankas Masih Kosong",
                    style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Simpan akun penting Anda dengan aman.",
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: provider.accounts.length,
            itemBuilder: (context, index) {
              final account = provider.accounts[index];
              return AccountCard(
                account: account,
                onCopyUser: () => _copyToClipboard(account.username, "Username"),
                onCopyPass: () => _copyToClipboard(account.password, "Password"),
                onEdit: () => _showAccountDialog(existingAccount: account),
                onDelete: () {
                  if (account.id != null) {
                    provider.deleteAccount(account.id!);
                  }
                },
                onAudit: () => _handleAudit(account.password),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F172A), 
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () => _showAccountDialog(),
        icon: const Icon(Icons.add, size: 20),
        label: const Text("Tambah Akun", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2)),
      ),
    );
  }
}

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onCopyUser;
  final VoidCallback onCopyPass;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAudit;

  const AccountCard({
    super.key,
    required this.account,
    required this.onCopyUser,
    required this.onCopyPass,
    required this.onEdit,
    required this.onDelete,
    required this.onAudit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF), 
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2563EB), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    account.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.3
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8)),
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Color(0xFF334155)),
                          SizedBox(width: 10),
                          Text("Ubah Akun", style: TextStyle(color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                          SizedBox(width: 10),
                          Text("Hapus", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          account.username, 
                          style: const TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w600)
                        ),
                      ),
                      GestureDetector(
                        onTap: onCopyUser,
                        child: const Icon(Icons.copy_rounded, color: Color(0xFF64748B), size: 16),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(color: Color(0xFFE2E8F0), height: 1, thickness: 0.8),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.key_outlined, size: 16, color: Color(0xFF94A3B8)),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "••••••••••••", 
                          style: TextStyle(fontSize: 14, color: Color(0xFF475569), fontWeight: FontWeight.w700, letterSpacing: 1.5)
                        ),
                      ),
                      GestureDetector(
                        onTap: onCopyPass,
                        child: const Icon(Icons.copy_rounded, color: Color(0xFF64748B), size: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFFF7ED), 
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: const BorderSide(color: Color(0xFFFFEDD5), width: 1),
                ),
                icon: const Icon(Icons.gpp_maybe_rounded, color: Color(0xFFD97706), size: 18),
                label: const Text(
                  "Periksa Kebocoran Kredensial (HIBP)", 
                  style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: -0.1)
                ),
                onPressed: onAudit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}