import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import '../services/api_service.dart';
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
      loadEvaluasi(forceRefresh: false);
    } else if (widget.type == 'Komitmen') {
      loadKomitmen(forceRefresh: false);
    } else {
      _isLoading = false;
    }
  }

  Future<void> loadEvaluasi({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'review_evaluasi_${widget.userId}_${widget.acaraHariId}';

      if (!forceRefresh) {
        final cached = prefs.getString(key);
        if (cached != null) {
          final evaluasi = jsonDecode(cached);
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
          print('Data Evaluasi (from shared pref): $_dataEvaluasi');
          return;
        }
      }

      final evaluasi = await ApiService.getEvaluasiByPesertaByAcara(
        context,
        widget.userId,
        widget.acaraHariId,
      );
      await prefs.setString(key, jsonEncode(evaluasi));
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
      print('Data Evaluasi (from API): $_dataEvaluasi');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadKomitmen({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'review_komitmen_${widget.userId}_${widget.acaraHariId}';

      if (!forceRefresh) {
        final cached = prefs.getString(key);
        if (cached != null) {
          final komitmen = jsonDecode(cached);
          setState(() {
            _user = komitmen['user'] ?? {};
            _dataKomitmen =
                (komitmen['data_komitmen'] as List<dynamic>?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [];
            _isLoading = false;
          });
          print('Data Komitmen (from shared pref): $_dataKomitmen');
          return;
        }
      }

      final komitmen = await ApiService.getKomitmenByPesertaByDay(
        context,
        widget.userId,
        widget.acaraHariId,
      );
      await prefs.setString(key, jsonEncode(komitmen));
      setState(() {
        _user = komitmen['user'] ?? {};
        _dataKomitmen =
            (komitmen['data_komitmen'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _isLoading = false;
      });
      print('Data Komitmen (from API): $_dataKomitmen');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tambahkan fungsi initAll untuk refresh sesuai type
  Future<void> initAll({bool forceRefresh = false}) async {
    if (widget.type == 'Evaluasi') {
      await loadEvaluasi(forceRefresh: forceRefresh);
    } else if (widget.type == 'Komitmen') {
      await loadKomitmen(forceRefresh: forceRefresh);
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
              : RefreshIndicator(
                onRefresh: () => initAll(forceRefresh: true),
                color: AppColors.brown1,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
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
                                    'Komitmen Hari: ${widget.acaraHariId}',
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
                          return CustomTextCard(
                            text: question,
                            value: answer == "1" ? 'Ya' : 'Tidak',
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
              ),
    );
  }
}
