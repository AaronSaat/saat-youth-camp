import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

class ReviewKomitmenScreen extends StatefulWidget {
  const ReviewKomitmenScreen({super.key});

  @override
  State<ReviewKomitmenScreen> createState() => _ReviewKomitmenScreenState();
}

class _ReviewKomitmenScreenState extends State<ReviewKomitmenScreen> {
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
      answer1 = prefs.getString('komitmen_answer1') ?? '';
      answer2 = prefs.getString('komitmen_answer2') ?? '';
      answer3 = prefs.getString('komitmen_answer3') ?? '';
      komentar = prefs.getString('komitmen_komentar') ?? '';
      _sliderValue = prefs.getDouble('komitmen_slider') ?? 0;
      isLoading = false;
    });
  }

  void _handleFinalSubmit(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus jawaban dari SharedPreferences
    await prefs.remove('komitmen_answer1');
    await prefs.remove('komitmen_answer2');
    await prefs.remove('komitmen_answer3');
    await prefs.remove('komitmen_komentar');
    await prefs.remove('komitmen_slider');

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Terima kasih!'),
            content: const Text('Komitmen Anda telah dicatat.'),
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Komitmen Anda:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _buildChecklistCard('Percaya kepada Tuhan Yesus Kristus sebagai Juruselamat saya pribadi.', answer1),
            _buildChecklistCard('Bertobat dari dosa-dosa yang membelenggu.', answer2),
            _buildChecklistCard('Belajar untuk sungguh-sungguh mencintai Firman Tuhan.', answer3),

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
                        : const Text('Submit Komitmen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
