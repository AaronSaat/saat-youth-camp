import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

class ReviewEvaluasi2Screen extends StatefulWidget {
  const ReviewEvaluasi2Screen({super.key});

  @override
  State<ReviewEvaluasi2Screen> createState() => _ReviewEvaluasi2ScreenState();
}

class _ReviewEvaluasi2ScreenState extends State<ReviewEvaluasi2Screen> {
  double answer1 = 3;
  double answer2 = 3;
  double answer3 = 3;
  String evaluasi2_status = "";

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
    _loadAnswers();
  }

  Future<void> _loadAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      answer1 = prefs.getDouble('evaluasi2_answer1') ?? 3;
      answer2 = prefs.getDouble('evaluasi2_answer2') ?? 3;
      answer3 = prefs.getDouble('evaluasi2_answer3') ?? 3;
      evaluasi2_status = prefs.getString('evaluasi2_status') ?? '';
    });
  }

  Future<void> _handleSubmit() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('evaluasi2_status', 'completed');
    await prefs.setDouble('evaluasi2_answer1', answer1);
    await prefs.setDouble('evaluasi2_answer2', answer2);
    await prefs.setDouble('evaluasi2_answer3', answer3);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Column(children: [Text('Terima Kasih!', textAlign: TextAlign.center)]),
            content: const Text('Evaluasi Pendaftaran Anda telah dicatat.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
    );
  }

  Widget _buildReviewTile(String question, double answer) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            '${answer.toInt()} - ${tingkatEvaluasiLabels[answer.toInt() - 1]}',
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Evaluasi Pendafataran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildReviewTile('1. Proses registrasi ulang dapat dipahami dengan mudah', answer1),
            _buildReviewTile('2. Kehadiran usher dan pengantar sangat membantu saya', answer2),
            _buildReviewTile('3. Tim registrasi dan usher ramah dan membuat saya merasa disambut', answer3),
            const SizedBox(height: 16),
            if (evaluasi2_status != 'completed')
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: _handleSubmit,
                  icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
                  label: const Text('Submit Evaluasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  ),
                ),
              )
            else
              const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
