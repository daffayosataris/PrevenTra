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

  void _showAccountDialog({AccountModel? existingAccount}) {
    final titleCtrl = TextEditingController(text: existingAccount?.title ?? '');
    final userCtrl = TextEditingController(text: existingAccount?.username ?? '');
    final passCtrl = TextEditingController(text: existingAccount?.password ?? '');
    bool isEdit = existingAccount != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(isEdit ? "Edit Akun" : "Tambah Akun", style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Nama Platform (ex: Instagram)", labelStyle: TextStyle(color: Colors.grey))),
            TextField(controller: userCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Username / Email", labelStyle: TextStyle(color: Colors.grey))),
            TextField(controller: passCtrl, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(labelText: "Password", labelStyle: TextStyle(color: Colors.grey))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              final newAcc = AccountModel(
                id: existingAccount?.id, 
                title: titleCtrl.text,
                username: userCtrl.text,
                password: passCtrl.text,
                createdAt: existingAccount?.createdAt ?? DateTime.now().toString(),
              );
              
              if (isEdit) {
                Provider.of<VaultProvider>(context, listen: false).updateAccount(newAcc);
              } else {
                Provider.of<VaultProvider>(context, listen: false).addAccount(newAcc);
              }
              Navigator.pop(ctx);
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BRANKAS SANDI", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: Consumer<VaultProvider>(
        builder: (context, provider, child) {
          if (provider.accounts.isEmpty) {
            return const Center(child: Text("Brankas masih kosong.", style: TextStyle(color: Colors.grey)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: provider.accounts.length,
            itemBuilder: (context, index) {
              final acc = provider.accounts[index];
              return AccountCardWidget(
                account: acc,
                onEdit: () => _showAccountDialog(existingAccount: acc),
                onDelete: () => provider.deleteAccount(acc.id!),
                // --- FUNGSI KLIK AUDIT BARU ---
                onAudit: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Memeriksa ke server HIBP..."), duration: Duration(seconds: 1)));
                  
                  String result = await provider.checkSinglePassword(acc.password);
                  
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: const Color(0xFF1E1E1E),
                        title: const Text("Hasil Audit", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        content: Text(
                          result, 
                          style: TextStyle(
                            color: result.contains("BAHAYA") ? Colors.redAccent : Colors.greenAccent, 
                            fontSize: 16
                          )
                        ),
                        actions: [ TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup", style: TextStyle(color: Colors.blueAccent))) ]
                      )
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () => _showAccountDialog(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AccountCardWidget extends StatefulWidget {
  final AccountModel account;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAudit; // Callback tambahan untuk tombol audit

  const AccountCardWidget({super.key, required this.account, required this.onEdit, required this.onDelete, required this.onAudit});

  @override
  State<AccountCardWidget> createState() => _AccountCardWidgetState();
}

class _AccountCardWidgetState extends State<AccountCardWidget> {
  bool _isObscured = true;

  void _copyToClipboard(String text, String type) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("$type disalin ke clipboard!"),
      backgroundColor: Colors.green,
      duration: const Duration(seconds: 1),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.2),
                child: Text(widget.account.title[0].toUpperCase(), style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              Text(widget.account.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(widget.account.username, style: const TextStyle(color: Colors.white70, fontSize: 16))),
              IconButton(icon: const Icon(Icons.copy, color: Colors.grey, size: 20), onPressed: () => _copyToClipboard(widget.account.username, "Username/Email")),
            ],
          ),
          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _isObscured ? '••••••••••••' : widget.account.password, 
                  style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2)
                )
              ),
              Row(
                children: [
                  IconButton(icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20), onPressed: () => setState(() => _isObscured = !_isObscured)),
                  IconButton(icon: const Icon(Icons.copy, color: Colors.grey, size: 20), onPressed: () => _copyToClipboard(widget.account.password, "Password")),
                ],
              )
            ],
          ),
          
          const Divider(color: Colors.white24, height: 20),
          
          // TOMBOL BAWAH (EDIT, HAPUS, CEK BOCOR)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Menyebar tombol
            children: [
              // TOMBOL AUDIT HIBP KEMBALI HADIR!
              TextButton.icon(
                style: TextButton.styleFrom(backgroundColor: Colors.orangeAccent.withOpacity(0.1)),
                icon: const Icon(Icons.security, color: Colors.orangeAccent, size: 16),
                label: const Text("Cek Bocor", style: TextStyle(color: Colors.orangeAccent)),
                onPressed: widget.onAudit,
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
                    onPressed: widget.onEdit,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                    onPressed: widget.onDelete,
                    tooltip: 'Hapus',
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}