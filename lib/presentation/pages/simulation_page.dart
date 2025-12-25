import 'package:flutter/material.dart';
import '../../core/utils/password_strength.dart';

class SimulationPage extends StatefulWidget {
  const SimulationPage({super.key});

  @override
  State<SimulationPage> createState() => _SimulationPageState();
}

class _SimulationPageState extends State<SimulationPage> {
  // KITA HAPUS CONTROLLER AGAR TOMBOL BACKSPACE LANCAR
  String _timeToCrack = "Menunggu Input...";
  int _score = 0;
  double _progress = 0;

  void _analyze(String val) {
    setState(() {
      var result = PasswordStrength.calculate(val);
      _timeToCrack = result['time'];
      _score = result['score'];
      
      // Update Progress Bar
      if (val.isEmpty) {
        _progress = 0;
        _timeToCrack = "Menunggu Input...";
        _score = 0;
      } else {
        _progress = (_score + 1) * 0.2; 
      }
    });
  }

  Color _getColor() {
    if (_score == 0) return Colors.red;
    if (_score == 1) return Colors.orange;
    if (_score == 2) return Colors.yellow;
    if (_score == 3) return Colors.blue;
    return Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tambahkan SingleChildScrollView agar tidak error kalau keyboard muncul (overflow)
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text("HACKER LAB", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white)),
              ),
              const SizedBox(height: 40),

              const Text(
                "SIMULASI BRUTE FORCE",
                style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 2),
              ),
              const SizedBox(height: 10),
              const Text(
                "Seberapa cepat komputer hacker bisa menebak password Anda?",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 30),
              
              // INPUT FIELD (Tanpa Controller)
              TextField(
                onChanged: _analyze, // Cukup pakai ini
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  labelText: "Ketik Password Percobaan",
                  labelStyle: const TextStyle(color: Colors.greenAccent),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.lock_open, color: Colors.greenAccent),
                  // Tambahkan tombol clear
                  suffixIcon: const Icon(Icons.keyboard, color: Colors.grey),
                ),
              ),
              
              const SizedBox(height: 40),

              // HASIL ANALISA
              Center(
                child: Column(
                  children: [
                    const Text("ESTIMASI WAKTU JEBOL:", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Text(
                      _timeToCrack,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _getColor(),
                        fontSize: 24, // Sedikit diperkecil agar muat di HP kecil
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier'
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // VISUALISASI BAR
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 20,
                  backgroundColor: Colors.grey[800],
                  color: _getColor(),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Lemah", style: TextStyle(color: Colors.red, fontSize: 12)),
                  Text("Mustahil", style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}