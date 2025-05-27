import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_panel_shape.dart';

class DaftarAcara2Screen extends StatelessWidget {
  const DaftarAcara2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> acaraList = [
      {'judul': 'Acara Pertama', 'deskripsi': 'Deskripsi pertama'},
      {'judul': 'Acara Kedua', 'deskripsi': 'Deskripsi kedua'},
      {'judul': 'Acara Ketiga', 'deskripsi': 'Deskripsi ketiga'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Acara 2')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: acaraList.length,
        itemBuilder: (context, index) {
          final acara = acaraList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16), // jarak antar item 16 px
            child: SizedBox(
              child: Stack(
                children: [
                  // CustomPanelShape(width: 350, height: 180, imageProvider: AssetImage('assets/images/event.jpg')),
                  CustomPanelShape(width: 350, height: 180, color: AppColors.primary),
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
            ),
          );
        },
      ),
    );
  }
}
