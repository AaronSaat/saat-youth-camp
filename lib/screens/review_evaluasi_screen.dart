import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';

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
  Map<String, dynamic> _user = {};
  Map<String, dynamic> _acara = {};
  List<Map<String, dynamic>> _dataEvaluasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    loadEvaluasi();
  }

  void loadEvaluasi() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final evaluasi = await ApiService.getEvaluasiByPesertaByAcara(
        context,
        widget.userId,
        widget.acaraHariId,
      );
      setState(() {
        _user = evaluasi['user'] ?? {};
        _acara = evaluasi['acara'] ?? {};
        _dataEvaluasi =
            (evaluasi['data_evaluasi'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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
                                'Nama: ${_user['nama'] ?? '-'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Nama Acara: ${_acara['acara_nama'] ?? '-'}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (var item in _dataEvaluasi)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: () {
                          final answerKey = 'evaluasiAnswer';
                          final answers =
                              (item[answerKey] is List) ? item[answerKey] : [];
                          final answerValue =
                              (answers.isNotEmpty)
                                  ? answers[0]['answer']
                                  : null;

                          if (item['type'] == "1") {
                            return _buildTextCard(
                              item['question'] ?? '',
                              answerValue?.toString() ?? '',
                            );
                          } else if (item['type'] == "2") {
                            return _buildChecklistCard(
                              item['question'] ?? '',
                              answerValue == "1" ? "Ya" : "Tidak",
                            );
                          } else if (item['type'] == "3") {
                            double sliderValue = 0;
                            if (answerValue != null) {
                              try {
                                sliderValue =
                                    double.tryParse(answerValue.toString()) ??
                                    0;
                              } catch (_) {}
                            }
                            return _buildSliderCard(
                              item['question'] ?? '',
                              sliderValue,
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }(),
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
