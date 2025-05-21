import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'review_evaluasi2_screen.dart';
import 'review_evaluasi_screen.dart';

class EvaluasiScreen2 extends StatefulWidget {
  const EvaluasiScreen2({super.key});

  @override
  State<EvaluasiScreen2> createState() => _EvaluasiScreen2State();
}

class _EvaluasiScreen2State extends State<EvaluasiScreen2> {
  double _answer1 = 3;
  double _answer2 = 3;
  double _answer3 = 3;
  final TextEditingController _textController = TextEditingController();
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
      _answer1 = prefs.getDouble('evaluasi2_answer1') ?? 3;
      _answer2 = prefs.getDouble('evaluasi2_answer2') ?? 3;
      _answer3 = prefs.getDouble('evaluasi2_answer3') ?? 3;
      _textController.text = prefs.getString('evaluasi2_komentar') ?? '';
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('evaluasi2_answer1', _answer1);
    await prefs.setDouble('evaluasi2_answer2', _answer2);
    await prefs.setDouble('evaluasi2_answer3', _answer3);
    await prefs.setString('evaluasi2_komentar', _textController.text);
  }

  Future<void> _handleSubmit() async {
    setState(() => isLoading = true);
    await _saveProgress();
    await Future.delayed(const Duration(seconds: 1));
    setState(() => isLoading = false);

    Navigator.push(context, MaterialPageRoute(builder: (_) => ReviewEvaluasiScreen()));
  }

  Widget _buildSliderQuestion({
    required String title,
    required double value,
    required void Function(double) onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
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
            Center(
              child: Text(
                '${tingkatEvaluasiLabels[value.toInt() - 1]}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      appBar: AppBar(title: const Text('Evaluasi Pendaftaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Slider Pertanyaan 1
            _buildSliderQuestion(
              title: 'Proses registrasi ulang dapat dipahami dengan mudah',
              value: _answer1,
              onChanged: (val) => setState(() => _answer1 = val),
            ),

            const SizedBox(height: 10),

            // Slider Pertanyaan 2
            _buildSliderQuestion(
              title: 'Kehadiran usher dan pengantar sangat membantu saya',
              value: _answer2,
              onChanged: (val) => setState(() => _answer2 = val),
            ),

            const SizedBox(height: 10),

            // Slider Pertanyaan 3
            _buildSliderQuestion(
              title: 'Tim registrasi dan usher ramah dan membuat saya merasa disambut',
              value: _answer3,
              onChanged: (val) => setState(() => _answer3 = val),
            ),

            const SizedBox(height: 10),

            // Button Row
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
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      elevation: 5,
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
                                  MaterialPageRoute(builder: (context) => const ReviewEvaluasi2Screen()),
                                );
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
