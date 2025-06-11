import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';

import '../services/api_service.dart';
import '../widgets/custom_checkbox_card.dart';
import '../widgets/custom_text_card.dart';

class EvaluasiKomitmenViewScreen extends StatefulWidget {
  final String type;
  final String userId;
  final int acaraHariId;

  const EvaluasiKomitmenViewScreen({
    super.key,
    required this.type,
    required this.userId,
    required this.acaraHariId,
  });

  @override
  State<EvaluasiKomitmenViewScreen> createState() =>
      _EvaluasiKomitmenViewScreenState();
}

class _EvaluasiKomitmenViewScreenState
    extends State<EvaluasiKomitmenViewScreen> {
  String? answer1;
  String? answer2;
  String? answer3;
  String komentar = '';
  Map<String, dynamic> _user = {};
  Map<String, dynamic> _acara = {};
  List<Map<String, dynamic>> _dataKomitmen = [];
  List<Map<String, dynamic>> _dataEvaluasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    if (widget.type == 'Evaluasi') {
      loadEvaluasi();
    } else if (widget.type == 'Komitmen') {
      loadKomitmen();
    } else {
      _isLoading = false;
    }
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
        print('Data Evaluasi: $_dataEvaluasi');
        print('Widget type: ${widget.type}');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadKomitmen() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final komitmen = await ApiService.getKomitmenByPesertaByDay(
        context,
        widget.userId,
        widget.acaraHariId,
      );
      setState(() {
        _user = komitmen['user'] ?? {};
        _dataKomitmen =
            (komitmen['data_komitmen'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _isLoading = false;
        print('Data Komitmen: $_dataKomitmen');
        print('Widget type: ${widget.type}');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> dataList =
        widget.type == 'Evaluasi' ? _dataEvaluasi : _dataKomitmen;
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          widget.type == 'Evaluasi' ? 'Review Evaluasi' : 'Review Komitmen',
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Terjadi kesalahan saat memuat data.',
                      style: TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
                              if (widget.type == 'Evaluasi')
                                Text(
                                  'Nama Acara: ${_acara['acara_nama'] ?? '-'}',
                                  style: const TextStyle(color: Colors.white),
                                )
                              else if (widget.type == 'Komitmen')
                                Text(
                                  'Komitmen Hari: ${widget.acaraHariId ?? '???'}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tampilkan hasil jawaban
                    ...dataList.map((item) {
                      final question = item['question'] ?? '';
                      final type = item['type']?.toString();
                      final answerList =
                          (item['komitmenAnswer'] ?? item['evaluasiAnswer'])
                              as List?;
                      final answer =
                          (answerList != null && answerList.isNotEmpty)
                              ? answerList[0]['answer']
                              : null;

                      if (["1", "18", "19"].contains(type)) {
                        // Text answer
                        return CustomTextCard(
                          text: question,
                          value: answer?.toString() ?? '',
                          backgroundColor: AppColors.brown1,
                        );
                      } else if (type == "2") {
                        // Checkbox answer
                        return CustomCheckboxCard(
                          text: question,
                          value: answer == "1" ? "Ya" : "Tidak",
                          textStyle: const TextStyle(color: Colors.white),
                          backgroundColor: AppColors.brown1,
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
                        final scale =
                            item['questionType']['scale_range']?.toString() ??
                            '';
                        return CustomTextCard(
                          text: question,
                          value: '${answer?.toString() ?? '0'} dari ${scale}',
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
