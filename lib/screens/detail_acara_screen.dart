import 'package:flutter/material.dart';

class DetailAcaraScreen extends StatelessWidget {
  final String title;
  final String detail;

  const DetailAcaraScreen({Key? key, required this.title, required this.detail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Detail Acara',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        leading: BackButton(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Deskripsi Acara:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(detail, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Text('Catatan Tambahan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Silakan hadir tepat waktu. Siapkan hati dan catatan untuk mengikuti seluruh sesi dengan baik.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
