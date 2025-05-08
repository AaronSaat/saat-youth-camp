import 'package:flutter/material.dart';

class NavigasiScreen extends StatelessWidget {
  const NavigasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigasi Lokasi')),
      body: Stack(
        children: [
          // Background container with 'Auditorium' text in the center
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey[300],
            child: const Center(
              child: Text(
                'Posisi Saya',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),
          ),

          // Icon for "Posisi Saya"
          Positioned(left: 180, top: 300, child: Icon(Icons.location_on, size: 40, color: Colors.red)),

          // Right Bottom: Gedung Auditorium
          Positioned(
            left: 280,
            top: 450,
            child: Container(
              padding: EdgeInsets.all(8),
              width: 140,
              height: 200,
              color: Colors.blueAccent,
              child: Text('Gedung Auditorium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // Left Bottom: Gedung Kelas
          Positioned(
            left: 0,
            top: 450,
            child: Container(
              padding: EdgeInsets.all(8),
              width: 140,
              height: 200,
              color: Colors.green,
              child: Text('Gedung Kelas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // Center Bottom: Lobby Utama
          Positioned(
            left: 140,
            top: 450,
            child: Container(
              padding: EdgeInsets.all(8),
              width: 140,
              height: 200,
              color: Colors.orange,
              child: Text('Lobby Utama', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // Right Top: Asrama Putri
          Positioned(
            left: 280,
            top: 50,
            child: Container(
              padding: EdgeInsets.all(8),
              width: 140,
              height: 200,
              color: Colors.pink,
              child: Text('Asrama Putri', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // Center Top: Kantin
          Positioned(
            left: 140,
            top: 50,
            child: Container(
              padding: EdgeInsets.all(8),
              width: 140,
              height: 200,
              color: Colors.indigo,
              child: Text('Kantin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),

          // Left Top: Asrama Putra
          Positioned(
            left: 0,
            top: 50,
            child: Container(
              padding: EdgeInsets.all(8),
              width: 140,
              height: 200,
              color: Colors.purple,
              child: Text('Asrama Putra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
