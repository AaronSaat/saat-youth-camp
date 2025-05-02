import 'package:flutter/material.dart';

class ReviewKomitmenScreen extends StatelessWidget {
  final bool checklist1;
  final bool checklist2;
  final bool checklist3;
  final String komentar;
  final int komitmenLevel;

  const ReviewKomitmenScreen({
    super.key,
    required this.checklist1,
    required this.checklist2,
    required this.checklist3,
    required this.komentar,
    required this.komitmenLevel,
  });

  void _handleFinalSubmit(BuildContext context) {
    // Di sini bisa tambahkan logika simpan ke backend jika diperlukan
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
    List<String> komitmenList = [];
    if (checklist1) komitmenList.add('• Percaya kepada Tuhan Yesus Kristus sebagai Juruselamat saya pribadi.');
    if (checklist2) komitmenList.add('• Bertobat dari dosa-dosa yang membelenggu.');
    if (checklist3) komitmenList.add('• Belajar untuk sungguh-sungguh mencintai Firman Tuhan.');

    return Scaffold(
      appBar: AppBar(title: const Text('SYC 2024 App'), backgroundColor: Colors.blueAccent),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Review Komitmen Anda:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            if (komitmenList.isEmpty)
              const Text('Tidak ada checklist yang dipilih.', style: TextStyle(color: Colors.red))
            else
              ...komitmenList.map((text) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text))),

            const SizedBox(height: 16),
            Text('Tingkat Komitmen: $komitmenLevel dari 6', style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 16),
            const Text('Komitmen lainnya:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                child: const Text('Submit Komitmen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
