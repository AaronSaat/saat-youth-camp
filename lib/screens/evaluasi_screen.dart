import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'review_evaluasi_screen.dart';

class EvaluasiScreen extends StatefulWidget {
  const EvaluasiScreen({super.key});

  @override
  State<EvaluasiScreen> createState() => _EvaluasiScreenState();
}

class _EvaluasiScreenState extends State<EvaluasiScreen> {
  String? answer1;
  String? answer2;
  String? answer3;
  final TextEditingController _textController = TextEditingController();
  double _sliderValue = 3;
  bool isLoading = false;
  // ada tipe jawabannya misal 1 = setuju, 2 = baik, 3 = lama, dst
  final List<String> tingkatEvaluasiLabels = [
    'Sangat Tidak Setuju',
    'Tidak Setuju',
    'Cukup Tidak Setuju',
    'Cukup Setuju',
    'Setuju',
    'Sangat Setuju',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedProgress();
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      answer1 = prefs.getString('evaluasi_answer1');
      answer2 = prefs.getString('evaluasi_answer2');
      answer3 = prefs.getString('evaluasi_answer3');
      _textController.text = prefs.getString('evaluasi_komentar') ?? '';
      _sliderValue = prefs.getDouble('evaluasi_slider') ?? 3;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('evaluasi_answer1', answer1 ?? '');
    await prefs.setString('evaluasi_answer2', answer2 ?? '');
    await prefs.setString('evaluasi_answer3', answer3 ?? '');
    await prefs.setString('evaluasi_komentar', _textController.text);
    await prefs.setDouble('evaluasi_slider', _sliderValue);
  }

  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);
    await _saveProgress();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewEvaluasiScreen()));
  }

  Widget _buildYesNoQuestion({
    required String title,
    required String? selectedValue,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Ya'),
                value: 'Ya',
                groupValue: selectedValue,
                onChanged: onChanged,
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Tidak'),
                value: 'Tidak',
                groupValue: selectedValue,
                onChanged: onChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChecklistQuestion({
    required String title,
    required String? selectedValue,
    required Function(String) onChanged,
  }) {
    bool isChecked = selectedValue == 'Ya';

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      value: isChecked,
      onChanged: (bool? value) {
        onChanged(value == true ? 'Ya' : 'Tidak');
      },
      controlAffinity: ListTileControlAffinity.trailing, // checkbox di kanan
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'SYC 2024 APP',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Checklist
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Checklist Evaluasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildChecklistQuestion(
                      title: 'Proses registrasi ulang dapat dipahami dengan mudah',
                      selectedValue: answer1,
                      onChanged: (val) => setState(() => answer1 = val),
                    ),
                    _buildChecklistQuestion(
                      title: 'Kehadiran usher dan pengantar sangat membantu saya',
                      selectedValue: answer2,
                      onChanged: (val) => setState(() => answer2 = val),
                    ),
                    _buildChecklistQuestion(
                      title: 'Tim registrasi dan usher ramah dan membuat saya merasa disambut',
                      selectedValue: answer3,
                      onChanged: (val) => setState(() => answer3 = val),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Card Slider
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saya dapat menikmati rangkaian acara dan ibadah',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
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
                    // Menambahkan teks di kiri dan kanan slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Tidak setuju', style: TextStyle(fontSize: 14)),
                        Text('Sangat setuju', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                    Center(
                      child: Text(
                        '${tingkatEvaluasiLabels[_sliderValue.toInt() - 1]}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Card Komentar
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secara singkat, apa yang kamu dapat dan apa saranmu untuk drama di Opening?',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan evaluasi...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Button Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await _saveProgress();
                    if (context.mounted) Navigator.pop(context); // kembali ke halaman sebelumnya
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    elevation: 5,
                  ),
                  child: const Text('Save Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  ),
                  child:
                      isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                          : const Text('Review Jawaban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
