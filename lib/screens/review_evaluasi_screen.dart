import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/evaluasi_komitmen_success_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_text_card.dart';

import '../services/api_service.dart';
import '../widgets/custom_checkbox_card.dart';

class ReviewEvaluasiScreen extends StatefulWidget {
  final String userId;
  final int acaraHariId;

  const ReviewEvaluasiScreen({
    super.key,
    required this.userId,
    required this.acaraHariId,
  });

  @override
  State<ReviewEvaluasiScreen> createState() => _ReviewEvaluasiScreenState();
}

class _ReviewEvaluasiScreenState extends State<ReviewEvaluasiScreen> {
  List<Map<String, dynamic>> _dataEvaluasi = [];
  bool _isLoading = true;
  String _userName = '';

  // Simpan jawaban lokal
  Map<String, dynamic> _localAnswers = {};
  List<String> _localAnswerIds = [];
  @override
  void initState() {
    super.initState();
    _loadEvaluasi();
    _loadUserData();
  }

  void _loadEvaluasi() async {
    setState(() => _isLoading = true);
    try {
      final evaluasi = await ApiService.getEvaluasiByAcara(
        context,
        widget.acaraHariId,
      );
      setState(() {
        _dataEvaluasi =
            (evaluasi['data_evaluasi'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _isLoading = false;

        print('Loaded Evaluasi: $_dataEvaluasi');
      });
      await _loadSavedProgress();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final typeKey = "Evaluasi";
    final ids = prefs.getStringList('${typeKey}_answer_ids') ?? [];
    setState(() {
      _localAnswerIds = ids;
      _localAnswers = {};
      for (var id in ids) {
        final key = '${typeKey}_answer_$id';
        final value = prefs.get('${key}');
        _localAnswers[id] = value;
      }
      print('Loaded answer IDs: $_localAnswerIds');
      print('Loaded local answers: $_localAnswers');
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('username') ?? 'User';
    });
  }

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    // Ambil user_id
    final userId = int.tryParse(widget.userId.toString()) ?? widget.userId;
    // Siapkan list jawaban
    List<Map<String, dynamic>> evaluasiAnswer = [];
    for (var id in _localAnswerIds) {
      final item = _dataEvaluasi.firstWhere(
        (e) => e['id'].toString() == id.toString(),
        orElse: () => {},
      );
      if (item.isEmpty) continue;
      final type = item['type']?.toString();
      final answer = _localAnswers[id];
      if (type == "1") {
        evaluasiAnswer.add({
          "eval_question_id": int.tryParse(id) ?? id,
          "user_id": userId,
          "answer": answer ?? '',
        });
      } else if (type == "2") {
        evaluasiAnswer.add({
          "eval_question_id": int.tryParse(id) ?? id,
          "user_id": userId,
          "answer": (answer == true || answer == 'Ya') ? 1 : 0,
        });
      } else if ([
        "3",
        "4",
        "5",
        "6",
        "7",
        "8",
        "9",
        "10",
        "11",
        "12",
        "13",
        "14",
        "15",
      ].contains(type)) {
        evaluasiAnswer.add({
          "eval_question_id": int.tryParse(id) ?? id,
          "user_id": userId,
          "answer": answer ?? '',
        });
      } else if (type == "18" || type == "19") {
        evaluasiAnswer.add({
          "eval_question_id": int.tryParse(id) ?? id,
          "user_id": userId,
          "answer": answer ?? '',
        });
      } else if (type == "16") {
        evaluasiAnswer.add({
          "eval_question_id": int.tryParse(id) ?? id,
          "user_id": userId,
          "answer": answer ?? '',
        });
      }
    }
    print('Submitting answers: $evaluasiAnswer');
    // Kirim ke API
    try {
      await ApiService.postEvaluasiAnswer(context, evaluasiAnswer);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => EvaluasiKomitmenSuccessScreen(
                  userId: widget.userId,
                  type: 'Evaluasi',
                  isSuccess: true,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) => EvaluasiKomitmenSuccessScreen(
                  userId: widget.userId,
                  type: 'Evaluasi',
                  isSuccess: false,
                ),
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text('Review Evaluasi', style: const TextStyle(fontSize: 18)),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: AppColors.brown1),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: AppColors.brown1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Form Evaluasi Acara ke-${widget.acaraHariId}\nNama: $_userName',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._localAnswerIds.map((id) {
                      final item = _dataEvaluasi.firstWhere(
                        (e) => e['id'].toString() == id.toString(),
                        orElse: () => {},
                      );
                      if (item.isEmpty) return const SizedBox.shrink();
                      final question = item['question'] ?? 'Pertanyaan';
                      final type = item['type']?.toString();
                      final scale =
                          item['questionType']['scale_range']?.toString() ?? '';
                      final answer = _localAnswers[id];
                      print(
                        'MBEK Processing question: $question, type: $type, answer: $answer',
                      );
                      if (["1", "18", "19"].contains(type)) {
                        return CustomTextCard(
                          text: question,
                          value: answer?.toString() ?? '',
                        );
                      } else if (type == "2") {
                        return CustomTextCard(
                          text: question,
                          value: answer == true ? 'Ya' : 'Tidak',
                        );
                      } else if ([
                        "3",
                        "4",
                        "5",
                        "6",
                        "7",
                        "8",
                        "9",
                        "10",
                        "11",
                        "12",
                        "13",
                        "14",
                        "15",
                      ].contains(type)) {
                        final answerValue =
                            answer is double ? answer.toInt() : answer;
                        return CustomTextCard(
                          text: question,
                          value:
                              '${answerValue?.toString() ?? '0'} dari ${scale}',
                          backgroundColor: AppColors.brown1, // opsional
                        );
                      } else if (type == "16") {
                        final raw = answer?.toString() ?? '';
                        final displayValue =
                            raw.isEmpty
                                ? ''
                                : '- ' + raw.replaceAll(';', '\n- ');
                        return CustomTextCard(
                          text: question,
                          value: displayValue,
                          backgroundColor: AppColors.brown1, // opsional
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }).toList(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brown1,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          onPressed: _isLoading ? null : _handleSubmit,
                          child: const Text(
                            'Submit',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
