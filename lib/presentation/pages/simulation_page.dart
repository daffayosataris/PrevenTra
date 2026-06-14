// Lokasi: lib/presentation/pages/simulation_page.dart

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
  Color _meterColor = const Color(0xFF94A3B8); 
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
    _crackController.dispose();
    super.dispose();
  }

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  void _calculateStrength(String password) {
    setState(() {
      _entropy = PasswordStrength.calculateEntropy(password);
      _crackTime = PasswordStrength.estimateCrackTime(_entropy);
      _crackController.reset();
      _crackingText = "MENUNGGU TARGET...";
      
      if (password.isEmpty) { _meterColor = const Color(0xFF94A3B8); }
      else if (_entropy < 40) { _meterColor = const Color(0xFFEF4444); } 
      else if (_entropy < 60) { _meterColor = const Color(0xFFF97316); } 
      else if (_entropy < 80) { _meterColor = const Color(0xFFEAB308); } 
      else { _meterColor = const Color(0xFF22C55E); } 
    });
  }

  void _startCrackingSimulation() {
    if (_passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ketik sandi target terlebih dahulu!")));
      return;
    }
    setState(() { _isCracking = true; });

    int milliseconds = 1000;
    if (_entropy < 40) milliseconds = 800; 
    else if (_entropy < 60) milliseconds = 3000; 
    else if (_entropy < 80) milliseconds = 6000; 
    else milliseconds = 15000; 

    _crackController.duration = Duration(milliseconds: milliseconds);
    _crackController.forward(from: 0.0);
  }

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
      backgroundColor: Colors.white, 
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("LEVEL COMPLETED! 🏆", style: TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.w800)), 
      content: Text("Skor Sempurna di Level $_currentLevel!\nSiap untuk trik hacker yang lebih rumit?", style: const TextStyle(color: Color(0xFF334155), fontSize: 15)), 
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF22C55E),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ), 
          onPressed: () { 
            Navigator.pop(ctx); 
            setState(() { _currentLevel++; _currentQuestionIndex = 0; _score = 0; }); 
          }, 
          child: const Text("Lanjut Level", style: TextStyle(fontWeight: FontWeight.bold))
        )
      ]
    ));
  }

  void _showDialogFailed() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("MISI GAGAL ❌", style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.w800)), 
      content: const Text("Anda masih terjebak. Ingat, satu klik salah di dunia nyata bisa berakibat fatal!\n\nSyarat Lulus: Skor 100%.", style: TextStyle(color: Color(0xFF334155), fontSize: 15)), 
      actions: [
        TextButton(
          onPressed: () { Navigator.pop(ctx); setState(() { _currentQuestionIndex = 0; _score = 0; }); }, 
          child: const Text("Ulangi Level Ini", style: TextStyle(color: Color(0xFFF97316), fontWeight: FontWeight.bold))
        )
      ]
    ));
  }

  void _showDialogGameClear() {
    showDialog(context: context, barrierDismissible: false, builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white, 
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text("MASTER SECURITY! 👑", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w800)), 
      content: const Text("Luar Biasa! Anda telah menaklukkan 21 skenario phishing paling rumit. Kewaspadaan Anda setingkat ahli!", style: TextStyle(color: Color(0xFF334155), fontSize: 15)), 
      actions: [
        TextButton(
          onPressed: () { Navigator.pop(ctx); setState(() { _currentLevel = 1; _currentQuestionIndex = 0; _score = 0; }); }, 
          child: const Text("Mainkan Ulang", style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold))
        )
      ]
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Lab Edukasi Siber", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Color(0xFF0F172A), letterSpacing: -0.5)),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController, 
          indicatorColor: const Color(0xFF2563EB), 
          labelColor: const Color(0xFF2563EB), 
          unselectedLabelColor: const Color(0xFF64748B), 
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          isScrollable: true, 
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: "Materi Edukasi"), 
            Tab(icon: Icon(Icons.password_rounded), text: "Simulasi Sandi"), 
            Tab(icon: Icon(Icons.phishing_rounded), text: "Kuis Phishing")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [ _buildMateriEdukasiTab(), _buildBruteForceTab(), _buildPhishingTab() ],
      ),
    );
  }

  // ==========================================
  // TAB 0: MATERI EDUKASI (DESAIN COURSE KELAS PREMIUM)
  // ==========================================
  Widget _buildMateriEdukasiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BANNER UTAMA (HEADER)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)], // Slate 800 ke Slate 900
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [BoxShadow(color: Color(0x330F172A), blurRadius: 20, offset: Offset(0, 10))],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(Icons.security_rounded, size: 120, color: Colors.white.withOpacity(0.05)),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: const Color(0xFF3B82F6).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: const Text("PENDAHULUAN SIBER", style: TextStyle(color: Color(0xFF93C5FD), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    ),
                    const SizedBox(height: 16),
                    const Text("Pusat Pelatihan\nKeamanan Digital", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.2, letterSpacing: -0.5)), 
                    const SizedBox(height: 8), 
                    const Text("Ketahui senjata musuh sebelum bertempur di dunia maya. Baca dan pelajari modul di bawah ini.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.5)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // BAGIAN 1
          const Row(
            children: [
              Icon(Icons.vpn_key_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 10),
              Text("Modul 1: Sandi & Brute Force", style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ), 
          const SizedBox(height: 16),
          _buildCourseModule(
            icon: Icons.lock_clock_rounded, 
            mainColor: const Color(0xFFF97316), bgColor: const Color(0xFFFFF7ED), badgeText: "DASAR",
            title: "Apa itu Brute Force?", 
            content: "Serangan di mana komputer hacker mencoba JUTAAN kombinasi kata sandi setiap detiknya (A, B, C... lalu AA, AB, AC...) sampai sandi Anda terbuka secara paksa."
          ),
          _buildCourseModule(
            icon: Icons.menu_book_rounded, 
            mainColor: const Color(0xFFEAB308), bgColor: const Color(0xFFFEFCE8), badgeText: "MENENGAH",
            title: "Serangan Kamus (Dictionary)", 
            content: "Hacker tidak menebak acak. Mereka memasukkan daftar kata umum yang sering dipakai manusia (seperti 'sayang', 'ganteng', '12345'). Jika sandi Anda ada di kamus, akan diretas dalam hitungan detik!"
          ),
          const SizedBox(height: 24),
          
          // BAGIAN 2
          const Row(
            children: [
              Icon(Icons.bug_report_rounded, color: Color(0xFF2563EB), size: 20),
              SizedBox(width: 10),
              Text("Modul 2: Phishing & Penipuan", style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          _buildCourseModule(
            icon: Icons.phishing_rounded, 
            mainColor: const Color(0xFFEF4444), bgColor: const Color(0xFFFEF2F2), badgeText: "DASAR",
            title: "Anatomi Phishing", 
            content: "Phishing berarti 'Memancing'. Hacker menyebar tautan palsu yang didesain 100% mirip dengan situs bank atau kampus Anda untuk merekam sandi yang Anda ketik secara diam-diam."
          ),
          _buildCourseModule(
            icon: Icons.link_rounded, 
            mainColor: const Color(0xFF3B82F6), bgColor: const Color(0xFFEFF6FF), badgeText: "MENENGAH",
            title: "Trik Sub-domain Palsu", 
            content: "Selalu baca URL dari KANAN ke KIRI.\n✅ Asli: login.bca.co.id\n❌ Palsu: bca.co.id.server-login.com\n(Pada URL palsu, domain aslinya adalah server-login.com)"
          ),
          _buildCourseModule(
            icon: Icons.text_fields_rounded, 
            mainColor: const Color(0xFF8B5CF6), bgColor: const Color(0xFFF5F3FF), badgeText: "LANJUTAN",
            title: "Serangan Homograph (Huruf Mirip)", 
            content: "Mata Anda bisa ditipu! Hacker mengganti karakter:\n• 'm' diganti 'rn' (rnicrosoft.com)\n• 'l' (L kecil) diganti 'I' (i besar) (paypaI.com)\nSelalu teliti sebelum Anda mengklik sebuah tautan penting."
          ),
          const SizedBox(height: 32),
          
          // KARTU CALL-TO-ACTION BAWAH
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Siap Menguji Pengetahuan Anda?", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 6),
                const Text("Pilih salah satu simulator di bawah ini untuk memulai latihan.", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _tabController.animateTo(1),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                          child: const Column(
                            children: [
                              Icon(Icons.password_rounded, color: Color(0xFF0F172A), size: 28),
                              SizedBox(height: 8),
                              Text("Simulator Sandi", style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 12))
                            ]
                          )
                        )
                      )
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _tabController.animateTo(2),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(12)),
                          child: const Column(
                            children: [
                              Icon(Icons.phishing_rounded, color: Colors.white, size: 28),
                              SizedBox(height: 8),
                              Text("Kuis Phishing", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))
                            ]
                          )
                        )
                      )
                    ),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // WIDGET KARTU MODUL INTERAKTIF (PENGGANTI EXPANSION TILE LAMA)
  Widget _buildCourseModule({
    required IconData icon, required Color mainColor, required Color bgColor, 
    required String badgeText, required String title, required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 2), 
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: mainColor, size: 24),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
                child: Text(badgeText, style: TextStyle(color: mainColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
          iconColor: mainColor,
          collapsedIconColor: const Color(0xFF94A3B8),
          childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: mainColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Text(content, style: const TextStyle(color: Color(0xFF334155), height: 1.6, fontSize: 14, fontWeight: FontWeight.w600))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: BRUTE FORCE (GABUNGAN LIGHT THEME & DARK TERMINAL)
  // ==========================================
  Widget _buildBruteForceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Simulator Mesin Peretas", style: TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          const Text("Masukkan sandi target. Algoritma akan menghitung waktu yang dibutuhkan GPU untuk membongkarnya.", style: TextStyle(color: Color(0xFF64748B), height: 1.4)),
          const SizedBox(height: 25),
          
          TextField(
            controller: _passController,
            onChanged: _calculateStrength,
            obscureText: false, 
            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 20, letterSpacing: 2, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              hintText: "Ketik sandi di sini...",
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), letterSpacing: 0, fontWeight: FontWeight.normal),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: _meterColor, width: 2.5)),
              prefixIcon: Icon(Icons.radar_rounded, color: _meterColor),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _meterColor, 
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: const Text("MULAI SIMULASI", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 1)),
              onPressed: _isCracking ? null : _startCrackingSimulation, 
            ),
          ),
          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF020617), 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1E293B), width: 2),
              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 15, offset: Offset(0, 10))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(color: Color(0xFF0F172A), borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
                  child: Row(
                    children: [
                      Icon(Icons.terminal_rounded, color: _meterColor, size: 16),
                      const SizedBox(width: 8),
                      Text("root@preventra:~# cracking_module --start", style: TextStyle(color: _meterColor, fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text("ESTIMASI WAKTU:", style: TextStyle(color: Color(0xFF64748B), fontFamily: 'Courier', fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_crackTime, textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _meterColor, fontFamily: 'Courier')),
                      const SizedBox(height: 24),
                      
                      AnimatedBuilder(
                        animation: _crackController,
                        builder: (context, child) {
                          return Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: _crackController.value, 
                                  minHeight: 12,
                                  backgroundColor: const Color(0xFF1E293B),
                                  color: _meterColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _crackingText,
                                style: TextStyle(color: _meterColor, fontFamily: 'Courier', fontSize: 22, letterSpacing: 3, fontWeight: FontWeight.bold),
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
  // TAB 2: KUIS PHISHING (TEMA TERANG PREMIUM)
  // ==========================================
  Widget _buildPhishingTab() {
    final currentScenarios = _phishingLevels[_currentLevel]!;
    final scenario = currentScenarios[_currentQuestionIndex];
    Color levelColor = _currentLevel == 1 ? const Color(0xFF22C55E) : (_currentLevel == 2 ? const Color(0xFFF97316) : const Color(0xFFEF4444));
    String difficultyText = _currentLevel == 1 ? "MUDAH" : (_currentLevel == 2 ? "MENENGAH" : "SULIT");

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12), margin: const EdgeInsets.only(bottom: 20), 
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: levelColor.withOpacity(0.5), width: 1.5)), 
            child: Center(child: Text("LEVEL $_currentLevel : $difficultyText", style: TextStyle(color: levelColor, fontWeight: FontWeight.w800, letterSpacing: 2)))
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, 
            children: [
              Text("Skenario ${_currentQuestionIndex + 1} / ${currentScenarios.length}", style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)), 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFBFDBFE))), 
                child: Text("Skor: $_score", style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w800))
              )
            ]
          ),
          const SizedBox(height: 20),
          
          Container(
            padding: const EdgeInsets.all(20), 
            decoration: BoxDecoration(
              color: Colors.white, 
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 4))]
            ), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Row(
                  children: [
                    const CircleAvatar(backgroundColor: Color(0xFFF1F5F9), child: Icon(Icons.email_rounded, color: Color(0xFF64748B), size: 20)), 
                    const SizedBox(width: 15), 
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Text(scenario['title'], style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 16)), 
                          const SizedBox(height: 2),
                          Text(scenario['sender'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500))
                        ]
                      )
                    )
                  ]
                ), 
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                ),
                Text(scenario['content'], style: const TextStyle(color: Color(0xFF334155), fontSize: 14, height: 1.6, fontWeight: FontWeight.w500))
              ]
            )
          ),
          const SizedBox(height: 30),
          
          if (!_showExplanation) ...[
            const Center(child: Text("Analisis email di atas. Aman atau Phishing?", style: TextStyle(color: Color(0xFF0F172A), fontSize: 15, fontWeight: FontWeight.w800))),
            const SizedBox(height: 20), 
            Row(
              children: [
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEF2F2), 
                    foregroundColor: const Color(0xFFEF4444),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                  ), 
                  icon: const Icon(Icons.warning_rounded, size: 20), 
                  label: const Text("PHISHING!", style: TextStyle(fontWeight: FontWeight.w800)), 
                  onPressed: () => _answerQuestion(true)
                )), 
                const SizedBox(width: 14), 
                Expanded(child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF0FDF4), 
                    foregroundColor: const Color(0xFF22C55E),
                    elevation: 0,
                    side: const BorderSide(color: Color(0xFFBBF7D0), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 16), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
                  ), 
                  icon: const Icon(Icons.verified_user_rounded, size: 20), 
                  label: const Text("AMAN", style: TextStyle(fontWeight: FontWeight.w800)), 
                  onPressed: () => _answerQuestion(false)
                ))
              ]
            )
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20), 
              decoration: BoxDecoration(
                color: _isCorrect ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2), 
                borderRadius: BorderRadius.circular(16), 
                border: Border.all(color: _isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444), width: 1.5)
              ), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Row(
                    children: [
                      Icon(_isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded, color: _isCorrect ? const Color(0xFF22C55E) : const Color(0xFFEF4444), size: 28), 
                      const SizedBox(width: 12),
                      Expanded(child: Text(_isCorrect ? "TEPAT SEKALI!" : "UPS, ANDA TERJEBAK HACKER!", style: TextStyle(color: _isCorrect ? const Color(0xFF166534) : const Color(0xFF991B1B), fontWeight: FontWeight.w900, fontSize: 16)))
                    ]
                  ), 
                  const SizedBox(height: 16), 
                  Text(scenario['explanation'], style: TextStyle(color: _isCorrect ? const Color(0xFF166534) : const Color(0xFF991B1B), height: 1.5, fontWeight: FontWeight.w500)), 
                  const SizedBox(height: 24), 
                  SizedBox(
                    width: double.infinity, 
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB), 
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ), 
                      onPressed: _nextQuestion, 
                      child: Text(_currentQuestionIndex < currentScenarios.length - 1 ? "Lanjut Skenario Berikutnya" : "Selesaikan Level Ini", style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))
                    )
                  )
                ]
              )
            )
          ],
        ],
      ),
    );
  }
}