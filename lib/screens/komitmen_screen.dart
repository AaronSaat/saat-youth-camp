import 'package:flutter/material.dart';
import 'review_komitmen_screen.dart';

class KomitmenScreen extends StatefulWidget {
  const KomitmenScreen({super.key});

  @override
  State<KomitmenScreen> createState() => _KomitmenScreenState();
}

class _KomitmenScreenState extends State<KomitmenScreen> {
  bool checklist1 = false;
  bool checklist2 = false;
  bool checklist3 = false;
  final TextEditingController _textController = TextEditingController();
  double _sliderValue = 3;
  bool isLoading = false;

  void _handleSubmit() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    // Navigasi ke halaman review sambil mengirim data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => ReviewKomitmenScreen(
              checklist1: checklist1,
              checklist2: checklist2,
              checklist3: checklist3,
              komentar: _textController.text,
              komitmenLevel: _sliderValue.toInt(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SYC 2024 App'), backgroundColor: Colors.blueAccent),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Checklist Komitmen', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            CheckboxListTile(
              title: const Text('Percaya kepada Tuhan Yesus Kristus sebagai Juruselamat saya pribadi.'),
              value: checklist1,
              onChanged: (val) => setState(() => checklist1 = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('Bertobat dari dosa-dosa yang membelenggu.'),
              value: checklist2,
              onChanged: (val) => setState(() => checklist2 = val ?? false),
            ),
            CheckboxListTile(
              title: const Text('Belajar untuk sungguh-sungguh mencintai Firman Tuhan.'),
              value: checklist3,
              onChanged: (val) => setState(() => checklist3 = val ?? false),
            ),
            const SizedBox(height: 20),

            const Text('Seberapa besar komitmen saya untuk hidup bagi Kristus?', style: TextStyle(fontSize: 18)),
            Slider(
              value: _sliderValue,
              min: 1,
              max: 6,
              divisions: 5,
              label: _sliderValue.toInt().toString(),
              onChanged: (value) => setState(() => _sliderValue = value),
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.blue[100],
            ),
            Text('Nilai: ${_sliderValue.toInt()}', style: const TextStyle(fontSize: 16)),

            const SizedBox(height: 20),
            const Text('Tuliskan komitmen lainnya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _textController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tuliskan komitmen lainnya terkait dengan pesan dari KKR malam ini...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  elevation: 5,
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                        : const Text('Submit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
