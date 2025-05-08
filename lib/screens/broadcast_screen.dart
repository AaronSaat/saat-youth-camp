import 'package:flutter/material.dart';
import 'package:syc/utils/app_colors.dart';

class BroadcastScreen extends StatelessWidget {
  const BroadcastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> previousMessages = [
      'Ibadah pembukaan akan segera dimulai di auditorium!',
      'Harap membawa Alkitab dan alat tulis masing-masing.',
      'Jangan lupa mengisi evaluasi registrasi!!!.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Broadcast Pesan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tulis pesan baru untuk di-broadcast:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Masukkan pesan di sini...'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: const Text('Broadcast'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Aksi broadcast di sini
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Pesan sebelumnya:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            for (var message in previousMessages)
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(message, style: const TextStyle(fontSize: 14, color: Colors.white)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
