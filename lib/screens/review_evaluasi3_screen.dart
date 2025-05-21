import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

class ReviewEvaluasi3Screen extends StatefulWidget {
  const ReviewEvaluasi3Screen({super.key});

  @override
  State<ReviewEvaluasi3Screen> createState() => _ReviewEvaluasi3ScreenState();
}

class _ReviewEvaluasi3ScreenState extends State<ReviewEvaluasi3Screen> {
  double _slider1Value = 3;
  double _slider2Value = 3;
  String? answer1;
  String saran = '';
  String komentar = '';
  bool isLoading = true;
  String evaluasi3_status = "";

  @override
  void initState() {
    super.initState();
    _loadDataFromPrefs();
  }

  Future<void> _loadDataFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _slider1Value = prefs.getDouble('opening_slider1') ?? 0;
      _slider2Value = prefs.getDouble('opening_slider2') ?? 0;
      answer1 = prefs.getString('opening_answer_drama') ?? '';
      komentar = prefs.getString('opening_komentar_drama') ?? '';
      saran = prefs.getString('opening_saran_ibadah') ?? '';
      isLoading = false;
      evaluasi3_status = prefs.getString('evaluasi3_status') ?? '';
    });
  }

  Future<void> _handleFinalSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('evaluasi3_status', 'completed');
    await prefs.setDouble('opening_slider1', _slider1Value);
    await prefs.setDouble('opening_slider2', _slider2Value);
    await prefs.setString('opening_answer_drama', answer1 ?? '');
    await prefs.setString('opening_komentar_drama', komentar);
    await prefs.setString('opening_saran_ibadah', saran);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Terima kasih!'),
            content: const Text('Evaluasi Opening Anda telah dicatat.'),
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
      appBar: AppBar(title: const Text('Review Evaluasi Opening')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    Row(
                      children: [Text('$_slider1Value dari 6', style: const TextStyle(fontSize: 16)), const Spacer()],
                    ),
                  ],
                ),
              ),
            ),

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
                      'Isi khotbah sangat sesuai dengan tema yang dibawakan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [Text('$_slider2Value dari 6', style: const TextStyle(fontSize: 16)), const Spacer()],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _buildChecklistCard('Apakah drama menolongmu memahami tema? ', answer1),

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
                          color: AppColors.primary.withAlpha(10),
                        ),
                        child: Text(saran.isEmpty ? '(Tidak ada komentar)' : saran),
                      ),
                    ],
                  ),
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
                        'Tanggapan dan saran kamu untuk ibadah opening?',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primary.withAlpha(10),
                        ),
                        child: Text(komentar.isEmpty ? '(Tidak ada saran)' : komentar),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            if (evaluasi3_status != 'completed')
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _handleFinalSubmit,
                  icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
                  label: const Text('Submit Evaluasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
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
