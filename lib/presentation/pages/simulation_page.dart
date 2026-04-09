import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/utils/password_strength.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> with TickerProviderStateMixin {
  late TabController _tabController;
  
  late AnimationController _crackController;
  final TextEditingController _passController = TextEditingController();
  double _entropy = 0;
  String _crackTime = "0 Detik";
  Color _meterColor = Colors.grey;
  bool _isCracking = false;
  String _crackingText = "MENUNGGU TARGET...";

  int _currentLevel = 1;
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showExplanation = false;
  bool _isCorrect = false;

  final Map<int, List<Map<String, dynamic>>> _phishingLevels = {
    1: [ // LEVEL 1: MUDAH
      {"title": "Email dari Bank BCA", "sender": "support@bca-klik-aman.com", "content": "Akun Anda ditangguhkan. Klik tautan berikut untuk verifikasi: http://bca-klik-aman.com/login", "isPhishing": true, "explanation": "PHISHING! Domain BCA adalah bca.co.id. Domain ini menggunakan kata tambahan dan HTTP (tidak aman)."},
      {"title": "Keamanan Google", "sender": "no-reply@accounts.google.com", "content": "Login baru terdeteksi. Amankan akun Anda di: https://myaccount.google.com/security", "isPhishing": false, "explanation": "AMAN! Email dari domain resmi Google dan menggunakan koneksi HTTPS yang valid."},
      {"title": "Notifikasi Instagram", "sender": "security@instargam-support.com", "content": "Seseorang mencoba masuk ke akun Anda. Reset sandi: https://instargam-support.com/reset", "isPhishing": true, "explanation": "PHISHING! Typo terdeteksi: 'instargam' bukan 'instagram'. Hacker sering salah eja agar tidak ketahuan sistem."},
      {"title": "Promo Tokopedia", "sender": "promo@tokopedia.com", "content": "Cashback 90% khusus pengguna terpilih! Klaim di aplikasi atau web: https://tokopedia.com/promo", "isPhishing": false, "explanation": "AMAN! Tautan mengarah langsung ke domain utama tokopedia.com tanpa embel-embel."},
      {"title": "Tagihan Listrik PLN", "sender": "billing@pln.co.id", "content": "Tagihan listrik Anda bulan ini Rp 450.000. Bayar sekarang: http://bayar-tagihan-pln.com", "isPhishing": true, "explanation": "PHISHING! Meski email pengirim terlihat asli, tautan mengarah ke situs pihak ketiga yang mencurigakan dan tidak terenkripsi (http)."},
      {"title": "Kode Verifikasi WhatsApp", "sender": "sms@whatsapp-verification-123.com", "content": "Kode OTP Anda adalah 84920. Jangan berikan kepada siapapun. Konfirmasi di: https://whatsapp-verification-123.com", "isPhishing": true, "explanation": "PHISHING! WhatsApp tidak pernah meminta konfirmasi OTP melalui tautan web eksternal dengan nama acak."},
      {"title": "Kuitansi Pembelian Apple", "sender": "receipts@apple.com", "content": "Terima kasih atas pembelian iCloud 50GB. Lihat struk Anda di: https://finance.apple.com/receipts", "isPhishing": false, "explanation": "AMAN! Tautan mengarah ke sub-domain resmi Apple (finance.apple.com)."},
    ],
    2: [ // LEVEL 2: MENENGAH 
      {"title": "Netflix Tertunggak", "sender": "billing@netflix.com.payment-update.info", "content": "Pembayaran gagal! Akun dihapus dalam 24 jam. Perbarui kartu kredit: https://netflix.com.payment-update.info", "isPhishing": true, "explanation": "PHISHING! Trik Sub-domain. Domain aslinya BUKAN netflix.com, melainkan 'payment-update.info'."},
      {"title": "Tiket Traveloka", "sender": "promo@traveloka.com", "content": "E-Tiket penerbangan ke Bali Anda sudah terbit: https://traveloka.com/flight/eticket", "isPhishing": false, "explanation": "AMAN! Domain utama adalah traveloka.com yang sah."},
      {"title": "Portal Akademik PNM", "sender": "admin@portal.pnm.ac.id.login-update.com", "content": "Wajib update password SIAKAD Anda hari ini atau di-DO: https://portal.pnm.ac.id.login-update.com", "isPhishing": true, "explanation": "PHISHING! Memanfaatkan rasa takut (Urgensi) dan menggunakan trik sub-domain palsu 'login-update.com'."},
      {"title": "Pemberitahuan OVO", "sender": "no-reply@ovo.id", "content": "Transfer masuk sebesar Rp 1.000.000 dari nomor tidak dikenal. Cek riwayat: https://ovo.id/history", "isPhishing": false, "explanation": "AMAN! Tautan bersih dan mengarah tepat ke domain resmi ovo.id."},
      {"title": "Pemblokiran Facebook", "sender": "security@facebook.com-recover-account.net", "content": "Seseorang melaporkan akun Anda. Banding keputusan di: https://facebook.com-recover-account.net", "isPhishing": true, "explanation": "PHISHING! Tanda hubung (-) memisahkan nama asli, sehingga domain aslinya adalah 'facebook.com-recover-account.net'."},
      {"title": "Bank Mandiri Update", "sender": "info@ib.bankmandiri.co.id.secure-login.com", "content": "Sistem keamanan Livin diubah. Aktifkan fitur baru: https://ib.bankmandiri.co.id.secure-login.com", "isPhishing": true, "explanation": "PHISHING! Contoh klasik sub-domain spoofing. Mereka meletakkan URL asli di depan URL palsu."},
      {"title": "Promo Shopee", "sender": "info@shopee.co.id", "content": "Gratis ongkir Rp 0 untuk pembelian pertama. Yuk belanja di: https://shopee.co.id/campaign", "isPhishing": false, "explanation": "AMAN! Tidak ada manipulasi URL, asli dari domain Shopee Indonesia."},
    ],
    3: [ // LEVEL 3: SULIT 
      {"title": "Verifikasi PayPal", "sender": "security@paypaI.com", "content": "Aktivitas aneh terdeteksi. Konfirmasi di: https://www.paypaI.com/auth", "isPhishing": true, "explanation": "PHISHING TINGKAT LANJUT! Huruf 'l' (L kecil) diganti dengan 'I' (i besar). Ini Serangan Homograph."},
      {"title": "Penawaran Kerja Microsoft", "sender": "hrd@rnicrosoft.com", "content": "Unduh dokumen kontrak Anda: https://rnicrosoft.com/careers/offer.pdf", "isPhishing": true, "explanation": "PHISHING TINGKAT LANJUT! Domain menggunakan 'rn' (R dan N) yang terlihat sangat mirip dengan 'm' (microsoft)."},
      {"title": "Kebijakan PNM", "sender": "admin@pnm.ac.id", "content": "Baca aturan baru kampus: https://akademik.pnm.ac.id/kebijakan", "isPhishing": false, "explanation": "AMAN! Tautan bersih menggunakan domain perguruan tinggi resmi (.ac.id)."},
      {"title": "Peringatan Twitter", "sender": "support@twltter.com", "content": "Akun Anda diakses dari Rusia. Amankan sekarang: https://twltter.com/security", "isPhishing": true, "explanation": "PHISHING SULIT! Huruf 'i' diganti dengan huruf 'l' (L kecil). Sangat sulit dibedakan sekilas."},
      {"title": "Pesan LinkedIn", "sender": "messages@Iinkedin.com", "content": "Anda mendapat pesan dari Recruiter Google: https://Iinkedin.com/inbox", "isPhishing": true, "explanation": "PHISHING SULIT! Menggunakan huruf 'I' (i besar) sebagai pengganti 'l' (L kecil) pada kata awalan."},
      {"title": "Airdrop Kripto Binance", "sender": "marketing@binance.com", "content": "Klaim gratis 1 BTC untuk 100 orang pertama! Klik: https://bit.ly/binance-airdrop-free", "isPhishing": true, "explanation": "PHISHING (Hati-hati)! URL Shortener (bit.ly) sering digunakan menyembunyikan situs jahat asli. Lembaga resmi tidak pernah memakai bit.ly untuk fitur krusial."},
      {"title": "Peringatan GitHub", "sender": "notifications@github.com", "content": "Repository PrevenTra di-star oleh 5 orang: https://github.com/daffayosataris/PrevenTra", "isPhishing": false, "explanation": "AMAN! Domain bersih tanpa trik URL pendek atau salah ejaan."},
    ]
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    
    // Inisialisasi Animasi Cracking
    _crackController = AnimationController(vsync: this);
    _crackController.addListener(() {
      if (_isCracking) {
        setState(() {
          _crackingText = _generateRandomString(_passController.text.length);
        });
      }
    });
    
    _crackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isCracking = false;
          _crackingText = "TERETAS: ${_passController.text}";
        });
      }
    });
  }

  @override
  void dispose() {
    _passController.dispose();
    _tabController.dispose();
    _crackController.dispose(); // Wajib dibersihkan
    super.dispose();
  }

  // Fungsi Pembuat Teks Acak (Matrix Effect)
  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // --- LOGIKA BRUTE FORCE ---
  void _calculateStrength(String password) {
    setState(() {
      _entropy = PasswordStrength.calculateEntropy(password);
      _crackTime = PasswordStrength.estimateCrackTime(_entropy);
      _crackController.reset(); // Reset animasi jika user mengetik lagi
      _crackingText = "MENUNGGU TARGET...";
      
      if (password.isEmpty) { _meterColor = Colors.grey; } 
      else if (_entropy < 40) { _meterColor = Colors.redAccent; } 
      else if (_entropy < 60) { _meterColor = Colors.orangeAccent; } 
      else if (_entropy < 80) { _meterColor = Colors.yellowAccent; } 
      else { _meterColor = Colors.greenAccent; }
    });
  }

  // Fungsi Pemicu Simulasi Cracking
  void _startCrackingSimulation() {
    if (_passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ketik sandi target terlebih dahulu!")));
      return;
    }

    setState(() {
      _isCracking = true;
    });

    // Sesuaikan durasi visual dengan kekuatan sandi
    int milliseconds = 1000;
    if (_entropy < 40) milliseconds = 800; // Sangat cepat (Lemah)
    else if (_entropy < 60) milliseconds = 3000; // Sedang
    else if (_entropy < 80) milliseconds = 6000; // Lambat (Kuat)
    else milliseconds = 15000; // Sangat Lambat merayap (Sangat Kuat)

    _crackController.duration = Duration(milliseconds: milliseconds);
    _crackController.forward(from: 0.0);
  }

  // --- LOGIKA KUIS PHISHING ---
  void _answerQuestion(bool userChoiceIsPhishing) {
    bool actualIsPhishing = _phishingLevels[_currentLevel]![_currentQuestionIndex]['isPhishing'];
    setState(() {
      _isCorrect = (userChoiceIsPhishing == actualIsPhishing);
      if (_isCorrect) _score += 10;
      _showExplanation = true; 
    });
  }

  void _nextQuestion() {
    setState(() {
      _showExplanation = false;
      int maxQs = _phishingLevels[_currentLevel]!.length;
      if (_currentQuestionIndex < maxQs - 1) {
        _currentQuestionIndex++;
      } else {
        _checkLevelCompletion(maxQs);
      }
    });
  }

  void _checkLevelCompletion(int totalQs) {
    if (_score == (totalQs * 10)) {
      if (_currentLevel < _phishingLevels.length) {
        _showDialogLevelUp();
      } else {
        _showDialogGameClear();
      }
    } else {
      _showDialogFailed();
    }
  }

  void _showDialogLevelUp() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), title: const Text("LEVEL COMPLETED! 🏆", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)), content: Text("Skor Sempurna di Level $_currentLevel!\nSiap untuk trik hacker yang lebih rumit?", style: const TextStyle(color: Colors.white)), actions: [ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), onPressed: () { Navigator.pop(ctx); setState(() { _currentLevel++; _currentQuestionIndex = 0; _score = 0; }); }, child: const Text("Lanjut Level Berikutnya", style: TextStyle(color: Colors.white)))]));
  }

  void _showDialogFailed() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), title: const Text("MISI GAGAL ❌", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)), content: const Text("Anda masih terjebak. Ingat, satu klik salah di dunia nyata bisa berakibat fatal!\n\nSyarat Lulus: Skor 100%.", style: TextStyle(color: Colors.white)), actions: [TextButton(onPressed: () { Navigator.pop(ctx); setState(() { _currentQuestionIndex = 0; _score = 0; }); }, child: const Text("Ulangi Level Ini", style: TextStyle(color: Colors.orange)))]));
  }

  void _showDialogGameClear() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E), title: const Text("MASTER SECURITY! 👑", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)), content: const Text("Luar Biasa! Anda telah menaklukkan 21 skenario phishing paling rumit. Kewaspadaan Anda setingkat ahli!", style: TextStyle(color: Colors.white)), actions: [TextButton(onPressed: () { Navigator.pop(ctx); setState(() { _currentLevel = 1; _currentQuestionIndex = 0; _score = 0; }); }, child: const Text("Mainkan Ulang"))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HACKER LAB (EDUKASI)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.black,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController, indicatorColor: Colors.greenAccent, labelColor: Colors.greenAccent, unselectedLabelColor: Colors.grey, isScrollable: true, 
          tabs: const [Tab(icon: Icon(Icons.menu_book_rounded), text: "Materi Edukasi"), Tab(icon: Icon(Icons.password), text: "Simulasi Sandi"), Tab(icon: Icon(Icons.phishing), text: "Kuis Phishing")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ _buildMateriEdukasiTab(), _buildBruteForceTab(), _buildPhishingTab() ],
      ),
    );
  }

  // ==========================================
  // TAB 0: MATERI EDUKASI (TETAP SAMA)
  // ==========================================
  Widget _buildMateriEdukasiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.purple, Colors.blueAccent]), borderRadius: BorderRadius.circular(15)),
            child: Row(children: [const Icon(Icons.school, size: 40, color: Colors.white), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [Text("Pusat Pelatihan Siber", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text("Ketahui senjata musuh sebelum bertempur di dunia maya.", style: TextStyle(color: Colors.white70, fontSize: 12))]))]),
          ),
          const SizedBox(height: 25),
          const Text("Bagian 1: Modul Sandi & Brute Force", style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
          _buildExpandableCard(icon: Icons.vpn_key, color: Colors.orangeAccent, title: "1. Apa itu Brute Force?", content: "Serangan di mana komputer hacker mencoba JUTAAN kombinasi kata sandi setiap detiknya (A, B, C... lalu AA, AB, AC...) sampai sandi Anda terbuka."),
          _buildExpandableCard(icon: Icons.menu_book, color: Colors.amber, title: "2. Serangan Kamus (Dictionary)", content: "Hacker tidak menebak acak, mereka memasukkan daftar kata umum yang sering dipakai manusia (seperti 'sayang', 'ganteng', '12345'). Jika sandi Anda ada di kamus, akan diretas dalam 1 detik!"),
          const SizedBox(height: 15),
          const Text("Bagian 2: Modul Phishing & Penipuan", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
          _buildExpandableCard(icon: Icons.bug_report, color: Colors.redAccent, title: "3. Anatomi Phishing", content: "Phishing berarti 'Memancing'. Hacker menyebar tautan palsu yang didesain 100% mirip dengan situs bank atau kampus Anda untuk merekam sandi yang Anda ketik."),
          _buildExpandableCard(icon: Icons.link, color: Colors.blueAccent, title: "4. Trik Sub-domain Palsu", content: "Selalu baca URL dari KANAN ke KIRI.\n✅ Asli: login.bca.co.id\n❌ Palsu: bca.co.id.server-login.com\n(Pada URL palsu, domain aslinya adalah server-login.com)"),
          _buildExpandableCard(icon: Icons.text_fields, color: Colors.purpleAccent, title: "5. Serangan Homograph (Huruf Mirip)", content: "Mata Anda bisa ditipu! Hacker mengganti karakter:\n• 'm' diganti 'rn' (rnicrosoft.com)\n• 'l' (L kecil) diganti 'I' (i besar) (paypaI.com)\nSelalu teliti sebelum klik."),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[800], padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.password, color: Colors.white, size: 20), label: const Text("Coba Brute Force", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), onPressed: () => _tabController.animateTo(1))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.phishing, color: Colors.white, size: 20), label: const Text("Mulai Kuis", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)), onPressed: () => _tabController.animateTo(2))),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildExpandableCard({required IconData icon, required Color color, required String title, required String content}) {
    return Card(color: const Color(0xFF1E1E1E), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3), width: 1.5)), margin: const EdgeInsets.only(bottom: 12), clipBehavior: Clip.antiAlias, child: Theme(data: Theme.of(context).copyWith(dividerColor: Colors.transparent), child: ExpansionTile(leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color, size: 20)), title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)), iconColor: color, collapsedIconColor: Colors.grey, childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20), backgroundColor: Colors.black12, children: [Text(content, style: const TextStyle(color: Colors.white70, height: 1.5, fontSize: 14))])));
  }

  // ==========================================
  // TAB 1: BRUTE FORCE (UI TERMINAL HACKER BARU!)
  // ==========================================
  Widget _buildBruteForceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Simulator Mesin Peretas", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Masukkan sandi target. Algoritma akan menghitung waktu yang dibutuhkan GPU untuk membongkarnya.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          
          // INPUT TARGET
          TextField(
            controller: _passController,
            onChanged: _calculateStrength,
            obscureText: false, // Biarkan terlihat agar user bisa belajar
            style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
            decoration: InputDecoration(
              hintText: "Masukkan Sandi...",
              hintStyle: TextStyle(color: Colors.grey[700]),
              filled: true, fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: _meterColor, width: 2)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: _meterColor, width: 2)),
              prefixIcon: Icon(Icons.radar, color: _meterColor),
            ),
          ),
          const SizedBox(height: 20),

          // TOMBOL MULAI SIMULASI
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _meterColor.withOpacity(0.8), padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              icon: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
              label: const Text("MULAI SIMULASI", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: _isCracking ? null : _startCrackingSimulation, // Nonaktifkan tombol saat sedang jalan
            ),
          ),
          const SizedBox(height: 30),

          // LALAYAR TERMINAL HACKER 
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF050505), // Hitam pekat
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _meterColor.withOpacity(0.5), width: 2),
              boxShadow: [BoxShadow(color: _meterColor.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Terminal
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(color: _meterColor.withOpacity(0.2), borderRadius: const BorderRadius.vertical(top: Radius.circular(8))),
                  child: Row(
                    children: [
                      Icon(Icons.terminal, color: _meterColor, size: 16),
                      const SizedBox(width: 8),
                      Text("root@preventra:~# cracking_module --start", style: TextStyle(color: _meterColor, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                
                // Layar Output
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text("ESTIMASI WAKTU:", style: TextStyle(color: Colors.grey[600], fontFamily: 'Courier', fontSize: 12)),
                      const SizedBox(height: 5),
                      Text(_crackTime, textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _meterColor, fontFamily: 'Courier')),
                      const SizedBox(height: 20),
                      
                      // ANIMASI PROGRESS BAR
                      AnimatedBuilder(
                        animation: _crackController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: LinearProgressIndicator(
                                  value: _crackController.value, // Bergerak sesuai durasi
                                  minHeight: 20,
                                  backgroundColor: Colors.grey[900],
                                  color: _meterColor,
                                ),
                              ),
                              const SizedBox(height: 15),
                              // TEXT KODE ACAK
                              Text(
                                _crackingText,
                                style: TextStyle(color: _meterColor, fontFamily: 'Courier', fontSize: 24, letterSpacing: 3, fontWeight: FontWeight.bold),
                              ),
                            ],
                          );
                        }
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 2: KUIS PHISHING (TETAP SAMA)
  // ==========================================
  Widget _buildPhishingTab() {
    final currentScenarios = _phishingLevels[_currentLevel]!;
    final scenario = currentScenarios[_currentQuestionIndex];
    Color levelColor = _currentLevel == 1 ? Colors.green : (_currentLevel == 2 ? Colors.orange : Colors.redAccent);
    String difficultyText = _currentLevel == 1 ? "MUDAH" : (_currentLevel == 2 ? "MENENGAH" : "SULIT");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10), margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: levelColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10), border: Border.all(color: levelColor)), child: Center(child: Text("LEVEL $_currentLevel : $difficultyText", style: TextStyle(color: levelColor, fontWeight: FontWeight.bold, letterSpacing: 2)))),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text("Skenario ${_currentQuestionIndex + 1} / ${currentScenarios.length}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.blueAccent)), child: Text("Skor: $_score", style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 20),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.email, color: Colors.white, size: 20)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(scenario['title'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)), Text(scenario['sender'], style: TextStyle(color: Colors.grey[600], fontSize: 12))]))]), const Divider(height: 30, color: Colors.grey), Text(scenario['content'], style: const TextStyle(color: Colors.black87, fontSize: 14, height: 1.5))])),
          const SizedBox(height: 30),
          if (!_showExplanation) ...[const Center(child: Text("Apakah pesan di atas Aman atau Phishing?", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))), const SizedBox(height: 20), Row(children: [Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.red[800], padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.warning, color: Colors.white), label: const Text("PHISHING!", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), onPressed: () => _answerQuestion(true))), const SizedBox(width: 15), Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green[800], padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), icon: const Icon(Icons.verified_user, color: Colors.white), label: const Text("AMAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), onPressed: () => _answerQuestion(false)))])] else ...[Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: _isCorrect ? Colors.green : Colors.red, width: 2)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Icon(_isCorrect ? Icons.check_circle : Icons.cancel, color: _isCorrect ? Colors.green : Colors.red, size: 30), const SizedBox(width: 10), Expanded(child: Text(_isCorrect ? "TEPAT SEKALI!" : "UPS, ANDA TERJEBAK HACKER!", style: TextStyle(color: _isCorrect ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 16)))]), const SizedBox(height: 15), Text(scenario['explanation'], style: const TextStyle(color: Colors.white, height: 1.5)), const SizedBox(height: 20), SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 15)), onPressed: _nextQuestion, child: Text(_currentQuestionIndex < currentScenarios.length - 1 ? "Lanjut Skenario" : "Selesaikan Level", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))]))],
        ],
      ),
    );
  }
}