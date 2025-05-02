import 'package:flutter/material.dart';
import 'komitmen_screen.dart'; // Pastikan file ini sudah dibuat

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _navigateToKomitmen(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const KomitmenScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // const Icon(Icons.dashboard, size: 100, color: Colors.blue),
            // const SizedBox(height: 20),
            const Text('Komitmen yang Perlu diisi', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            // Scrollable Horizontal List
            SizedBox(
              height: 140,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _komitmenCard(context, 'Komitmen 1'),
                  const SizedBox(width: 16),
                  _komitmenCard(context, 'Komitmen 2'),
                  const SizedBox(width: 16),
                  _komitmenCard(context, 'Komitmen 3'),
                  const SizedBox(width: 16),
                  _komitmenCard(context, 'Komitmen 3'),
                  const SizedBox(width: 16),
                  _komitmenCard(context, 'Komitmen 3'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _komitmenCard(BuildContext context, String title) {
    return GestureDetector(
      onTap: () => _navigateToKomitmen(context),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.assignment, size: 40, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
