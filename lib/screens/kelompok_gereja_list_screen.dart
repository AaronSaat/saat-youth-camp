import 'package:flutter/material.dart';

class KelompokGerejaListScreen extends StatelessWidget {
  final List<String> dummyKelompok = [
    'Kelompok 1 - Paulus',
    'Kelompok 2 - Petrus',
    'Kelompok 3 - Yohanes',
    'Kelompok 4 - Markus',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // penting agar background sampai ke appbar
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.white),
        title: const Text('Daftar Kelompok Gereja', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background_member_list.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
          ),

          // Konten
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              itemCount: dummyKelompok.length,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    // color: Colors.white10,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(color: Colors.white),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(dummyKelompok[index], style: const TextStyle(color: Colors.white, fontSize: 16)),
                    trailing: const Icon(Icons.arrow_right_sharp, color: Colors.white, size: 48),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
