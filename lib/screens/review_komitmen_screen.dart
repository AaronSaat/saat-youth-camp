import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';

class ReviewKomitmenScreen extends StatefulWidget {
  final String userId;
  final int acaraHariId;

  const ReviewKomitmenScreen({
    super.key,
    required this.userId,
    required this.acaraHariId,
  });

  @override
  State<ReviewKomitmenScreen> createState() => _ReviewKomitmenScreenState();
}

class _ReviewKomitmenScreenState extends State<ReviewKomitmenScreen> {
  List<Map<String, dynamic>> _dataKomitmen = [];
  bool _isLoading = true;

  // Simpan jawaban lokal
  Map<String, dynamic> _localAnswers = {};
  List<String> _localAnswerIds = [];
  @override
  void initState() {
    super.initState();
    loadKomitmen();
  }

  void loadKomitmen() async {
    setState(() => _isLoading = true);
    try {
      final komitmen = await ApiService.getKomitmenByDay(
        context,
        widget.acaraHariId,
      );
      setState(() {
        _dataKomitmen =
            (komitmen['data_komitmen'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _isLoading = false;
      });
      await _loadSavedProgress();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final typeKey = "Komitmen";
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

  Future<void> _handleSubmit() async {
    setState(() => _isLoading = true);
    // Ambil user_id
    final userId = int.tryParse(widget.userId.toString()) ?? widget.userId;
    // Siapkan list jawaban
    List<Map<String, dynamic>> komitmenAnswer = [];
    for (var id in _localAnswerIds) {
      final item = _dataKomitmen.firstWhere(
        (e) => e['id'].toString() == id.toString(),
        orElse: () => {},
      );
      if (item.isEmpty) continue;
      final type = item['type']?.toString();
      final answer = _localAnswers[id];
      if (type == "1") {
        komitmenAnswer.add({
          "komitmen_question_id": int.tryParse(id) ?? id,
          "user_id": userId,
          "answer": answer ?? '',
        });
      } else if (type == "2") {
        komitmenAnswer.add({
          "komitmen_question_id": int.tryParse(id) ?? id,
          "user_id": userId,
          "answer": (answer == true || answer == 'Ya') ? 1 : 0,
        });
      }
    }
    print('Submitting answers: $komitmenAnswer');
    // Kirim ke API
    try {
      await ApiService.postKomitmenAnswer(context, komitmenAnswer);
      // Sukses, bisa tampilkan snackbar atau navigasi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jawaban berhasil dikirim!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengirim jawaban: $e')));
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
        title: Text('Review Komitmen', style: const TextStyle(fontSize: 18)),
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
                    // Contoh akses user
                    SizedBox(
                      width: double.infinity,
                      child: Card(
                        color: AppColors.brown1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nama: ${widget.userId}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._localAnswerIds.map((id) {
                      final item = _dataKomitmen.firstWhere(
                        (e) => e['id'].toString() == id.toString(),
                        orElse: () => {},
                      );
                      if (item.isEmpty) return const SizedBox.shrink();
                      final question = item['question'] ?? 'Pertanyaan';
                      final type = item['type']?.toString();
                      final answer = _localAnswers[id];
                      if (type == "1") {
                        return _buildTextCard(
                          question,
                          answer?.toString() ?? '',
                        );
                      } else if (type == "2") {
                        return _buildChecklistCard(
                          question,
                          answer == true ? 'Ya' : 'Tidak',
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    }).toList(),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brown1,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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

  Widget _buildChecklistCard(String text, String? value) {
    bool isYes = (value?.toLowerCase() == 'ya');

    return Card(
      color: AppColors.brown1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isYes ? Icons.check_circle : Icons.cancel,
              color: isYes ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderCard(String text, double value) {
    return Card(
      color: AppColors.brown1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  '$value dari 6',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                const Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextCard(String text, String value) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: AppColors.brown1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                value.isEmpty ? '(Tidak ada komentar)' : value,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
