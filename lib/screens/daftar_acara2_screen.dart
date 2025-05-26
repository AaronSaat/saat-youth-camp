import 'package:flutter/material.dart';

class DaftarAcara2Screen extends StatelessWidget {
  const DaftarAcara2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> acaraList = [
      {'judul': 'Acara Pertama', 'deskripsi': 'Deskripsi singkat acara pertama'},
      {'judul': 'Acara Kedua', 'deskripsi': 'Deskripsi singkat acara kedua'},
      {'judul': 'Acara Ketiga', 'deskripsi': 'Deskripsi singkat acara ketiga'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Acara 2')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acaraList.length,
        itemBuilder: (context, index) {
          final acara = acaraList[index];
          return SizedBox(
            child: Stack(
              children: [
                Image.asset('assets/buttons/panel_acara.png', width: double.infinity, height: 200, fit: BoxFit.cover),
                Positioned(
                  left: 24,
                  bottom: 24,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        acara['judul'] ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(acara['deskripsi'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
