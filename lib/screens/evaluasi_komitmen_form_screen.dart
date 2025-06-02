import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/custom_slider.dart';
import 'evaluasi_komitmen_review_screen.dart';

class EvaluasiKomitmenFormScreen extends StatefulWidget {
  final String type;
  final String userId;
  final int acaraHariId;

  const EvaluasiKomitmenFormScreen({
    super.key,
    required this.type,
    required this.userId,
    required this.acaraHariId,
  });

  @override
  State<EvaluasiKomitmenFormScreen> createState() =>
      _EvaluasiKomitmenFormScreenState();
}

class _EvaluasiKomitmenFormScreenState
    extends State<EvaluasiKomitmenFormScreen> {
  String? answer1;
  String? answer2;
  String? answer3;
  final TextEditingController _textController = TextEditingController();
  double _sliderValue = 3;
  bool isLoading = false;
  Map<String, dynamic> _acara = {};
  List<Map<String, dynamic>> _dataKomitmen = [];
  List<Map<String, dynamic>> _dataEvaluasi = [];
  bool _isLoading = true;
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
      final evaluasi = await ApiService.getEvaluasiByAcara(
        context,
        widget.acaraHariId,
      );
      setState(() {
        _acara = evaluasi['acara'] ?? {};
        _dataEvaluasi =
            (evaluasi['data_evaluasi'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [];
        _isLoading = false;

        print('Data Evaluasi: $_dataEvaluasi');
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

        print('Data Komitmen: $_dataKomitmen');
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
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

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => EvaluasiKomitmenReviewScreen(
              type: widget.type,
              userId: widget.userId,
              acaraHariId: widget.acaraHariId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.brown1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Evaluasi Lainnya',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: AppColors.brown1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Checklist
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.brown1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Checklist Evaluasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CustomCheckbox(
                      value: answer1 == 'Ya',
                      onChanged:
                          (val) => setState(() {
                            answer1 = val ? 'Ya' : 'Tidak';
                          }),
                      label:
                          'Proses registrasi ulang dapat dipahami dengan mudah',
                    ),
                    const SizedBox(height: 8),
                    CustomCheckbox(
                      value: answer1 == 'Ya',
                      onChanged:
                          (val) => setState(() {
                            answer1 = val ? 'Ya' : 'Tidak';
                          }),
                      label:
                          'Proses registrasi ulang dapat dipahami dengan mudah',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Card Slider
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.brown1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seberapa besar komitmen saya untuk hidup bagi Kristus?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Slider(
                      value: _sliderValue,
                      min: 1,
                      max: 6,
                      divisions: 5,
                      label: _sliderValue.toInt().toString(),
                      onChanged:
                          (value) => setState(() => _sliderValue = value),
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.primary.withAlpha(40),
                    ),
                    CustomStepperSlider(
                      value: _sliderValue,
                      onChanged: (val) {
                        setState(() {
                          _sliderValue = val;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Sangat Tidak Setuju',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        Text(
                          'Sangat Setuju',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                    Center(
                      child: Text(
                        '${tingkatEvaluasiLabels[_sliderValue.toInt() - 1]}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Card Komentar
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: AppColors.brown1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Secara singkat, apa yang kamu dapat dan apa saranmu untuk drama di Opening?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan evaluasi...',
                        hintStyle: const TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                      if (context.mounted)
                        Navigator.pop(context); // kembali ke halaman sebelumnya
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      elevation: 5,
                    ),
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      'Save Progress',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16), // Space between buttons
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                    ),
                    icon:
                        isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                            ),
                    label:
                        isLoading
                            ? const Text('')
                            : const Text(
                              'Review Jawaban',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
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
