import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewEvaluasiScreen extends StatefulWidget {
  const ReviewEvaluasiScreen({super.key});

  @override
  State<ReviewEvaluasiScreen> createState() => _ReviewEvaluasiScreenState();
}

class _ReviewEvaluasiScreenState extends State<ReviewEvaluasiScreen> {
  String? answer1;
  String? answer2;
  String? answer3;
  String komentar = '';
  double _sliderValue = 3;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      answer1 = prefs.getString('evaluasi_answer1') ?? '';
      answer2 = prefs.getString('evaluasi_answer2') ?? '';
      answer3 = prefs.getString('evaluasi_answer3') ?? '';
      komentar = prefs.getString('evaluasi_komentar') ?? '';
      _sliderValue = prefs.getDouble('evaluasi_slider') ?? 0;
      isLoading = false;
    });
  }

  void _handleFinalSubmit(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus jawaban dari SharedPreferences
    await prefs.remove('evaluasi_answer1');
    await prefs.remove('evaluasi_answer2');
    await prefs.remove('evaluasi_answer3');
    await prefs.remove('evaluasi_komentar');
    await prefs.remove('evaluasi_slider');

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Terima kasih!'),
            content: const Text('Evaluasi Anda telah dicatat.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SYC 2024 APP',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Evaluasi Anda:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            // Checklist cards
            _buildChecklistCard('Proses registrasi ulang dapat dipahami dengan mudah', answer1),
            _buildChecklistCard('Kehadiran usher dan pengantar sangat membantu saya', answer2),
            _buildChecklistCard('Tim registrasi dan usher ramah dan membuat saya merasa disambut', answer3),

            const SizedBox(height: 16),
            const Text(
              'Saya dapat menikmati rangkaian acara dan ibadah',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [Text('$_sliderValue dari 6', style: const TextStyle(fontSize: 16)), const Spacer()],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Secara singkat, apa yang kamu dapat dari ibadah opening ini?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.shade100,
              ),
              child: Text(komentar.isEmpty ? '(Tidak ada komentar)' : komentar),
            ),

            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => _handleFinalSubmit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  elevation: 5,
                ),
                child: const Text('Submit Evaluasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard(String text, String? value) {
    bool isYes = (value?.toLowerCase() == 'ya');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [TextSpan(text: text, style: const TextStyle(fontSize: 16, color: Colors.black))],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(isYes ? Icons.check_circle : Icons.cancel, color: isYes ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }
}
