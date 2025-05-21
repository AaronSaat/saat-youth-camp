import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

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
      appBar: AppBar(title: const Text('Review Evaluasi Lainnya')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChecklistCard('Proses registrasi ulang dapat dipahami dengan mudah', answer1),
            _buildChecklistCard('Kehadiran usher dan pengantar sangat membantu saya', answer2),
            _buildChecklistCard('Tim registrasi dan usher ramah dan membuat saya merasa disambut', answer3),

            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saya dapat menikmati rangkaian acara dan ibadah',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(children: [Text('$_sliderValue dari 6', style: const TextStyle(fontSize: 16)), const Spacer()]),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Secara singkat, apa yang kamu dapat dari ibadah opening ini?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: Text(komentar.isEmpty ? '(Tidak ada komentar)' : komentar),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _handleFinalSubmit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  elevation: 5,
                ),
                child:
                    isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Evaluasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      elevation: 4,
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
