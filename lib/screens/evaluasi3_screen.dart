import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'review_evaluasi3_screen.dart';

class EvaluasiScreen3 extends StatefulWidget {
  const EvaluasiScreen3({super.key});

  @override
  State<EvaluasiScreen3> createState() => _EvaluasiScreen3State();
}

class _EvaluasiScreen3State extends State<EvaluasiScreen3> {
  double _sliderValue1 = 3;
  double _sliderValue2 = 3;
  String? answerDrama;
  final TextEditingController _komentarDramaController = TextEditingController();
  final TextEditingController _saranIbadahController = TextEditingController();
  bool isLoading = false;

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
      _sliderValue1 = prefs.getDouble('opening_slider1') ?? 3;
      _sliderValue2 = prefs.getDouble('opening_slider2') ?? 3;
      answerDrama = prefs.getString('opening_answer_drama');
      _komentarDramaController.text = prefs.getString('opening_komentar_drama') ?? '';
      _saranIbadahController.text = prefs.getString('opening_saran_ibadah') ?? '';
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('opening_slider1', _sliderValue1);
    await prefs.setDouble('opening_slider2', _sliderValue2);
    await prefs.setString('opening_answer_drama', answerDrama ?? '');
    await prefs.setString('opening_komentar_drama', _komentarDramaController.text);
    await prefs.setString('opening_saran_ibadah', _saranIbadahController.text);
  }

  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);
    await _saveProgress();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    if (context.mounted) Navigator.pop(context);
  }

  Widget _buildSliderQuestion({
    required String title,
    required double value,
    required Function(double) onChanged,
    required String label,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Slider(
              value: value,
              min: 1,
              max: 6,
              divisions: 5,
              label: value.toInt().toString(),
              onChanged: onChanged,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.primary.withAlpha(40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('Sangat Tidak Setuju', style: TextStyle(fontSize: 14)),
                Text('Sangat Setuju', style: TextStyle(fontSize: 14)),
              ],
            ),
            Center(child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistQuestion({
    required String title,
    required String? selectedValue,
    required Function(String) onChanged,
  }) {
    bool isChecked = selectedValue == 'Ya';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        value: isChecked,
        onChanged: (bool? value) {
          onChanged(value == true ? 'Ya' : 'Tidak');
        },
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildTextArea({
    required String title,
    required TextEditingController controller,
    String hintText = 'Tuliskan di sini...',
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evaluasi Opening')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSliderQuestion(
              title: 'Saya dapat menikmati rangkaian acara dan ibadah',
              value: _sliderValue1,
              onChanged: (val) => setState(() => _sliderValue1 = val),
              label: tingkatEvaluasiLabels[_sliderValue1.toInt() - 1],
            ),
            _buildSliderQuestion(
              title: 'Isi khotbah sangat sesuai dengan tema yang dibawakan',
              value: _sliderValue2,
              onChanged: (val) => setState(() => _sliderValue2 = val),
              label: tingkatEvaluasiLabels[_sliderValue2.toInt() - 1],
            ),
            _buildChecklistQuestion(
              title: 'Apakah drama menolongmu memahami tema?',
              selectedValue: answerDrama,
              onChanged: (val) => setState(() => answerDrama = val),
            ),
            _buildTextArea(
              title: 'Secara singkat, apa yang kamu dapat dan apa saranmu untuk drama di Opening?',
              controller: _komentarDramaController,
            ),
            _buildTextArea(title: 'Tanggapan dan saran kamu untuk ibadah Opening', controller: _saranIbadahController),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await _saveProgress();
                      if (context.mounted) Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed:
                        isLoading
                            ? null
                            : () async {
                              setState(() => isLoading = true);
                              await _saveProgress();
                              await Future.delayed(const Duration(seconds: 1));
                              if (mounted) {
                                setState(() => isLoading = false);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ReviewEvaluasi3Screen()),
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                            : const Icon(Icons.arrow_forward),
                    label:
                        isLoading
                            ? const Text('')
                            : const Text('Review Jawaban', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
