// Lokasi: lib/presentation/pages/tools_page.dart

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
    
    if (!mounted) return; 
    setState(() => _isLoading = false);
    
    _showDialog(message != null ? "Backup Sukses" : "Backup Gagal", 
                message ?? "Terjadi kesalahan sistem.");
  }

  // --- FUNGSI RESTORE ---
  void _handleRestore() async {
    setState(() => _isLoading = true);
    String? message = await BackupService().restoreBackup();
    
    if (!mounted) return; 
    
    if (message != null && message.contains("BERHASIL")) {
      Provider.of<VaultProvider>(context, listen: false).loadAccounts();
    }
    
    setState(() => _isLoading = false);
    _showDialog("Status Restore", message ?? "Gagal memproses file.");
  }

  // --- FITUR: GENERATOR PASSWORD & PASSPHRASE ---
  void _showPasswordGenerator() {
    double length = 16;
    double wordCount = 3; 
    bool useUpper = true;
    bool useLower = true;
    bool useNumbers = true;
    bool useSymbols = true;
    bool isPassphraseMode = false; 
    String generatedPassword = "Klik 'GENERATE' 👇";

    final List<String> kamusIndo = [
      'gajah', 'kucing', 'mobil', 'sepeda', 'gunung', 'laut', 'langit', 'bintang',
      'kopi', 'buku', 'meja', 'pintu', 'rumah', 'jendela', 'kaca', 'lampu',
      'merah', 'biru', 'hijau', 'hitam', 'putih', 'besar', 'kecil', 'cepat',
      'lambat', 'kuat', 'pintar', 'maju', 'sukses', 'jaya', 'elang', 'harimau',
      'laptop', 'kode', 'data', 'sistem', 'aman', 'kunci', 'awan', 'angin',
      'singa', 'kuda', 'sapi', 'ayam', 'bebek', 'kelinci', 'tikus', 'ular',
      'buaya', 'kura', 'monyet', 'gorila', 'zebra', 'jerapah', 'badak', 'panda',
      'beruang', 'rubah', 'serigala', 'rusa', 'kancil', 'tupai', 'landak', 'musang',
      'burung', 'merpati', 'kakaktua', 'merak', 'flamingo', 'pinguin', 'hiu', 'paus',
      'lumba', 'gurita', 'ubur', 'kepiting', 'udang', 'ikan', 'katak', 'cacing',
      'hujan', 'petir', 'pelangi', 'banjir', 'salju', 'badai', 'kabut', 'embun',
      'sungai', 'danau', 'hutan', 'padang', 'bukit', 'lembah', 'pantai', 'pulau',
      'bumi', 'bulan', 'matahari', 'planet', 'galaksi', 'meteor', 'komet', 'orbit',
      'tanah', 'pasir', 'batu', 'lumpur', 'karang', 'terumbu', 'savana', 'gurun',
      'nasi', 'mie', 'soto', 'bakso', 'sate', 'rendang', 'gulai', 'opor',
      'gado', 'pecel', 'rawon', 'tongseng', 'semur', 'tumis', 'goreng', 'bakar',
      'tahu', 'tempe', 'oncom', 'kerupuk', 'emping', 'sambal', 'kecap', 'saos',
      'susu', 'jus', 'teh', 'jahe', 'kunyit', 'rempah', 'bumbu', 'garam',
      'gula', 'madu', 'coklat', 'keju', 'roti', 'kue', 'puding', 'es',
      'mangga', 'pisang', 'apel', 'jeruk', 'anggur', 'semangka', 'melon', 'pepaya',
      'durian', 'rambutan', 'lychee', 'salak', 'jambu', 'nanas', 'sirsak', 'alpukat',
      'server', 'jaringan', 'internet', 'website', 'aplikasi', 'program', 'robot',
      'sensor', 'baterai', 'sinyal', 'frekuensi', 'antena', 'satelit', 'radar',
      'komputer', 'printer', 'scanner', 'monitor', 'keyboard', 'mouse', 'kamera',
      'ponsel', 'tablet', 'drone', 'wifi', 'bluetooth', 'layar', 'memori', 'prosesor',
      'algoritma', 'basis', 'cloud', 'enkripsi', 'firewall', 'jaringan', 'protokol',
      'kursi', 'lemari', 'kasur', 'bantal', 'selimut', 'tikar', 'karpet', 'cermin',
      'piring', 'gelas', 'sendok', 'garpu', 'pisau', 'wajan', 'panci', 'kompor',
      'kulkas', 'mesin', 'pompa', 'ember', 'sapu', 'sikat', 'spons', 'sabun',
      'pensil', 'pena', 'penggaris', 'gunting', 'lem', 'staples', 'amplop', 'kertas',
      'tas', 'dompet', 'koper', 'payung', 'topi', 'sarung', 'sepatu', 'sandal',
      'cincin', 'gelang', 'kalung', 'jam', 'kacamata', 'ikat', 'gesper', 'bros',
      'dokter', 'guru', 'pilot', 'tentara', 'polisi', 'hakim', 'jaksa', 'notaris',
      'arsitek', 'insinyur', 'akuntan', 'manajer', 'direktur', 'petani', 'nelayan',
      'pedagang', 'sopir', 'koki', 'pelayan', 'penjahit', 'tukang', 'montir', 'satpam',
      'ilmuwan', 'peneliti', 'wartawan', 'fotografer', 'seniman', 'musisi', 'aktor',
      'sekolah', 'kampus', 'kantor', 'pabrik', 'toko', 'pasar', 'mall', 'hotel',
      'rumah sakit', 'klinik', 'apotek', 'masjid', 'gereja', 'pura', 'vihara',
      'stadion', 'museum', 'galeri', 'perpustakaan', 'bioskop', 'teater', 'taman',
      'bandara', 'pelabuhan', 'terminal', 'stasiun', 'jembatan', 'terowongan', 'bendungan','monumen', 'tugu', 'patung', 'air terjun', 'gunung', 'lembah', 'hutan',
      'motor', 'truk', 'bus', 'kereta', 'pesawat', 'kapal', 'perahu', 'helikopter',
      'ambulans', 'taksi', 'ojek', 'becak', 'andong', 'traktor', 'forklift', 'crane',
      'roket', 'kapal selam', 'feri', 'gondola', 'trem', 'metro', 'monorel',
      'tinggi', 'rendah', 'panjang', 'pendek', 'lebar', 'sempit', 'tebal', 'tipis',
      'keras', 'lembut', 'kasar', 'halus', 'panas', 'dingin', 'basah', 'kering',
      'berat', 'ringan', 'gelap', 'terang', 'ramai', 'sepi', 'bersih', 'kotor',
      'indah', 'jelek', 'bagus', 'buruk', 'mahal', 'murah', 'baru', 'lama',
      'cerdas', 'bodoh', 'rajin', 'malas', 'berani', 'takut', 'jujur', 'bohong',
      'baik', 'jahat', 'ramah', 'sombong', 'sabar', 'pemarah', 'dermawan', 'pelit',
      'sepak bola', 'basket', 'voli', 'renang', 'lari', 'tinju', 'gulat', 'panahan',
      'mendaki', 'bersepeda', 'yoga', 'senam', 'tenis', 'bulu tangkis', 'golf', 'polo',
      'memancing', 'berburu', 'berkuda', 'selam', 'surfing', 'panjat', 'lompat', 'lempar',
      'musik', 'lagu', 'tari', 'lukis', 'pahat', 'puisi', 'cerita', 'drama',
      'wayang', 'batik', 'tenun', 'ukiran', 'anyaman', 'tembikar', 'keramik', 'mosaik',
      'gamelan', 'angklung', 'sasando', 'kolintang', 'rebab', 'kendang', 'suling', 'kecapi',
      'fisika', 'kimia', 'biologi', 'matematika', 'sejarah', 'geografi', 'ekonomi', 'sosiologi',
      'astronomi', 'geologi', 'ekologi', 'psikologi', 'filsafat', 'linguistik', 'arkeologi',
      'atom', 'molekul', 'elektron', 'proton', 'neutron', 'energi', 'massa', 'gravitasi',
      'evolusi', 'genetika', 'sel', 'virus', 'bakteri', 'jamur', 'alga', 'enzim',
      'makan', 'minum', 'tidur', 'bangun', 'jalan', 'lari', 'loncat', 'renang',
      'baca', 'tulis', 'gambar', 'hitung', 'pikir', 'rasa', 'dengar', 'lihat',
      'bicara', 'diam', 'tertawa', 'menangis', 'tersenyum', 'marah', 'takut', 'senang',
      'kerja', 'belajar', 'bermain', 'istirahat', 'berdoa', 'memasak', 'mencuci', 'menyapu',
      'membeli', 'menjual', 'meminjam', 'menabung', 'berinvestasi', 'mengirim', 'menerima',
      'satu', 'dua', 'tiga', 'empat', 'lima', 'enam', 'tujuh', 'delapan',
      'sembilan', 'sepuluh', 'ratus', 'ribu', 'juta', 'miliar',
      'detik', 'menit', 'jam', 'hari', 'minggu', 'bulan', 'tahun', 'abad',
      'pagi', 'siang', 'sore', 'malam', 'subuh', 'fajar', 'senja', 'tengah malam',
      'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu',
      'januari', 'februari', 'maret', 'april', 'mei', 'juni',
      'juli', 'agustus', 'september', 'oktober', 'november', 'desember',
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      elevation: 10,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder( 
        builder: (BuildContext context, StateSetter setModalState) {

          void generate() {
            Random rnd = Random();
            String result = "";

            if (isPassphraseMode) {
              for (int i = 0; i < wordCount.toInt(); i++) {
                String word = kamusIndo[rnd.nextInt(kamusIndo.length)];
                word = word[0].toUpperCase() + word.substring(1); 
                result += word;
                if (i < wordCount.toInt() - 1) result += "-"; 
              }
              if (useNumbers) result += "${rnd.nextInt(99)}";
              if (useSymbols) {
                String sym = "!@#\$%^&*";
                result += sym[rnd.nextInt(sym.length)];
              }
            } else {
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
                Center(
                  child: Container(
                    width: 40, height: 4, 
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10))
                  ),
                ),
                const Center(
                  child: Text("PASSWORD GENERATOR", style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ),
                const SizedBox(height: 25),

                // LAYAR TAMPILAN PASSWORD (PREMIUM)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Text(
                    generatedPassword,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF8B5CF6), 
                      fontSize: isPassphraseMode ? 16 : 22, 
                      fontFamily: 'Courier', 
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // TOGGLE MODE 
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Mode Passphrase", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: const Text("Gunakan frasa (Mudah dihafal & Kuat)", style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                  value: isPassphraseMode,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF8B5CF6),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFCBD5E1),
                  onChanged: (val) => setModalState(() => isPassphraseMode = val),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(color: Color(0xFFF1F5F9), thickness: 1.5),
                ),

                // SLIDER DINAMIS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isPassphraseMode ? "Jumlah Kata" : "Panjang Karakter", style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    Text(isPassphraseMode ? "${wordCount.toInt()} Kata" : "${length.toInt()}", style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 16)),
                  ],
                ),
                SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: const Color(0xFF8B5CF6),
                    inactiveTrackColor: const Color(0xFFF1F5F9),
                    thumbColor: const Color(0xFF8B5CF6),
                    overlayColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    trackHeight: 6.0,
                  ),
                  child: Slider(
                    value: isPassphraseMode ? wordCount : length,
                    min: isPassphraseMode ? 2 : 8,
                    max: isPassphraseMode ? 5 : 32,
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                        ),
                        icon: const Icon(Icons.copy_rounded, color: Color(0xFF64748B), size: 20),
                        label: const Text("SALIN", style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.w700)),
                        onPressed: () {
                          if (generatedPassword.length > 5 && !generatedPassword.contains("Klik")) {
                            Clipboard.setData(ClipboardData(text: generatedPassword));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                    SizedBox(width: 10),
                                    Text("Password berhasil disalin!", style: TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                backgroundColor: const Color(0xFF8B5CF6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                behavior: SnackBarBehavior.floating,
                              )
                            );
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6), 
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                        ),
                        onPressed: generate,
                        child: const Text("GENERATE PASSWORD", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
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
    return Theme(
      data: ThemeData(unselectedWidgetColor: const Color(0xFFCBD5E1)),
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(color: Color(0xFF475569), fontSize: 14, fontWeight: FontWeight.w600)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF8B5CF6),
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800)),
        content: Text(content, style: const TextStyle(color: Color(0xFF475569), fontSize: 15, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            child: const Text("OK", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      appBar: AppBar(
        title: const Text("Alat Keamanan", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24, color: Color(0xFF0F172A), letterSpacing: -0.5)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: GridView.count(
              crossAxisCount: 2, 
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.95,
              children: [
                _buildToolCard(Icons.cloud_upload_rounded, "Backup Data", "Ekspor ke .pvt", _handleBackup, const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                _buildToolCard(Icons.settings_backup_restore_rounded, "Restore Data", "Impor File .pvt", _handleRestore, const Color(0xFFF97316), const Color(0xFFFFF7ED)),
                _buildToolCard(Icons.password_rounded, "Generator", "Buat Sandi Kuat", _showPasswordGenerator, const Color(0xFF8B5CF6), const Color(0xFFF5F3FF)), 
                _buildToolCard(Icons.admin_panel_settings_rounded, "Cek Root", "Integritas HP", () {}, const Color(0xFFEF4444), const Color(0xFFFEF2F2)), 
              ],
            ),
          ),
          
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 24),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Gunakan Password Generator untuk membuat sandi unik setiap kali Anda mendaftar akun baru demi mencegah peretasan.",
                      style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_isLoading)
            Container(
              color: const Color(0xFF0F172A).withValues(alpha: 0.5),
              // 👉 PERBAIKAN: Menghapus keyword 'const' dari widget Center
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const CircularProgressIndicator(color: Color(0xFF2563EB))
                )
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolCard(IconData icon, String title, String subtitle, VoidCallback onTap, Color mainColor, Color bgColor) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
          boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 32, color: mainColor),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}