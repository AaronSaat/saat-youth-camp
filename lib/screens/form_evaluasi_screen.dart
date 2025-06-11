import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_multiple_choice.dart';
import '../services/api_service.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/custom_single_choice.dart';
import '../widgets/custom_slider.dart';
import '../widgets/custom_text_field.dart';
import 'review_evaluasi_screen.dart';
import '../widgets/custom_not_found.dart';

class FormEvaluasiScreen extends StatefulWidget {
  final String userId;
  final int acaraHariId;

  const FormEvaluasiScreen({
    super.key,
    required this.userId,
    required this.acaraHariId,
  });

  @override
  State<FormEvaluasiScreen> createState() => _FormEvaluasiScreenState();
}

class _FormEvaluasiScreenState extends State<FormEvaluasiScreen> {
  final Map<String, bool> _checkbox_answer = {};
  final Map<String, TextEditingController> _text_answer = {};
  final Map<String, double> _slider_answer = {};
  final Map<String, String> _single_choice_answer = {};
  final Map<String, String> _multiple_choice_answer = {};
  bool isLoading = false;
  Map<String, dynamic> _acara = {};
  List<Map<String, dynamic>> _dataEvaluasi = [];
  bool _isLoading = true;

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
    loadEvaluasi();
  }

  void loadEvaluasi() async {
    setState(() => _isLoading = true);
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
      });
      print('Data Evaluasi: $_dataEvaluasi');
      await _loadSavedProgress();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadSavedProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _dataEvaluasi;
    final typeKey = "Evaluasi";
    for (var item in data) {
      final key = '${typeKey}_answer_${item['id']}';
      if (item['type'] == "1") {
        final controller = TextEditingController(
          text: prefs.getString(key) ?? '',
        );
        _text_answer[item['id'].toString()] = controller;
      } else if (item['type'] == "2") {
        _checkbox_answer[item['id'].toString()] = prefs.getBool(key) ?? false;
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
      ].contains(item['type'])) {
        _slider_answer[item['id'].toString()] = prefs.getDouble(key) ?? 1.0;
      } else if (item['type'] == "18" || item['type'] == "19") {
        _single_choice_answer[item['id'].toString()] =
            prefs.getString(key) ?? '';
      } else if (item['type'] == "16") {
        _multiple_choice_answer[item['id'].toString()] =
            prefs.getString(key) ?? '';
      }
    }
    setState(() {});
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _dataEvaluasi;
    final typeKey = "Evaluasi";
    List<String> savedIds = [];
    for (var item in data) {
      final idStr = item['id'].toString();
      final key = '${typeKey}_answer_$idStr';
      savedIds.add(idStr);
      if (item['type'] == "1") {
        await prefs.setString(key, _text_answer[idStr]?.text ?? '');
      } else if (item['type'] == "2") {
        await prefs.setBool(key, _checkbox_answer[idStr] == true);
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
      ].contains(item['type'])) {
        await prefs.setDouble(key, _slider_answer[idStr] ?? 1.0);
      } else if (item['type'] == "18" || item['type'] == "19") {
        await prefs.setString(key, _single_choice_answer[idStr] ?? '');
      } else if (item['type'] == "16") {
        await prefs.setString(key, _multiple_choice_answer[idStr] ?? '');
      }
    }
    // Simpan list id pertanyaan untuk tipe ini
    await prefs.setStringList('${typeKey}_answer_ids', savedIds);

    // print semua isi shared preferences
    final allKeys = prefs.getKeys();
    for (var key in allKeys) {
      print('SharedPreferences: $key = ${prefs.get(key)}');
    }
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
            (_) => ReviewEvaluasiScreen(
              userId: widget.userId,
              acaraHariId: widget.acaraHariId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String titleImage = 'assets/texts/evaluasi.png';

    final data = _dataEvaluasi;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Positioned(
              child: Image.asset(
                'assets/images/background_form.png',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
              ),
            ),
          ),
          SafeArea(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _dataEvaluasi.isEmpty
                    ? CustomNotFound(
                      text:
                          'Data evaluasi tidak ditemukan.\nSilakan kembali dan coba lagi nanti.',
                      textColor: Colors.white,
                      imagePath: 'assets/images/data_not_found.png',
                    )
                    : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: AppColors.brown1,
                          elevation: 0,
                          pinned: true,
                          leading:
                              Navigator.canPop(context)
                                  ? BackButton(color: Colors.white)
                                  : null,
                          expandedHeight: 100,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 36.0),
                                child: Image.asset(
                                  titleImage,
                                  height: 90,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.73,
                            ),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: const BorderSide(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      color: Colors.transparent,
                                      elevation: 0,
                                      margin: const EdgeInsets.only(
                                        bottom: 16.0,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          'Form Evaluasi Hari ke-${_acara['hari']}\nNama Acara: ${_acara['acara_nama'] ?? 'Nama Acara???'}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...data.map<Widget>((item) {
                                      print(': $item');
                                      final String question =
                                          item['question'] ?? '';
                                      final String id = item['id'].toString();

                                      if (item['type'] == "1") {
                                        // TextField
                                        _text_answer.putIfAbsent(
                                          id,
                                          () => TextEditingController(),
                                        );
                                        return Column(
                                          children: [
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              color: Colors.white,
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  16,
                                                ),
                                                child: CustomTextField(
                                                  controller: _text_answer[id]!,
                                                  label: question,
                                                  hintText: '...',
                                                  maxLines: 5,
                                                  labelColor: Colors.black,
                                                  textColor: Colors.black,
                                                  fillColor: Colors.white,
                                                  suffixIcon: IconButton(
                                                    icon: const Icon(
                                                      Icons.keyboard_hide,
                                                      color: Colors.black,
                                                    ),
                                                    onPressed:
                                                        () =>
                                                            FocusScope.of(
                                                              context,
                                                            ).unfocus(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        );
                                      } else if (item['type'] == "2") {
                                        // Checkbox
                                        return Column(
                                          children: [
                                            CustomCheckbox(
                                              value:
                                                  _checkbox_answer[id] == true,
                                              onChanged:
                                                  (val) => setState(() {
                                                    _checkbox_answer[id] = val;
                                                  }),
                                              label: question,
                                            ),
                                            const Divider(
                                              color: Colors.white,
                                              thickness: 1,
                                            ),
                                            const SizedBox(height: 16),
                                          ],
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
                                      ].contains(item['type'])) {
                                        // Slider with dynamic settings
                                        _slider_answer.putIfAbsent(
                                          id,
                                          () => 1.0,
                                        );
                                        // Get slider settings from questionType
                                        final questionType =
                                            item['questionType'] ?? {};
                                        final int scaleRange =
                                            int.tryParse(
                                              questionType['scale_range']
                                                      ?.toString() ??
                                                  '',
                                            ) ??
                                            6;
                                        final String minValue =
                                            questionType['min_value']
                                                ?.toString()
                                                .trim() ??
                                            'Sangat Tidak ???';
                                        final String maxValue =
                                            questionType['max_value']
                                                ?.toString()
                                                .trim() ??
                                            'Sangat ???';

                                        // Label on change di tengah (ga dipake)
                                        // List<String> labels =
                                        //     tingkatEvaluasiLabels;
                                        // if (scaleRange == 6 &&
                                        //     minValue == 'Sangat Tidak Setuju' &&
                                        //     maxValue == 'Sangat Setuju') {
                                        //   labels = tingkatEvaluasiLabels;
                                        // } else {
                                        //   // Generate labels: only min/max, or custom if needed
                                        //   labels = List.generate(scaleRange, (
                                        //     i,
                                        //   ) {
                                        //     if (i == 0) return minValue;
                                        //     if (i == scaleRange - 1)
                                        //       return maxValue;
                                        //     return '';
                                        //   });
                                        // }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              question,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            CustomSlider(
                                              value: _slider_answer[id]!,
                                              min: 1,
                                              max: scaleRange.toDouble(),
                                              divisions: scaleRange - 1,
                                              onChanged: (val) {
                                                setState(() {
                                                  _slider_answer[id] = val;
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  minValue,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Text(
                                                  maxValue,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            // Center(
                                            //   child: Text(
                                            //     labels[(_slider_answer[id]!
                                            //                 .toInt() -
                                            //             1)
                                            //         .clamp(
                                            //           0,
                                            //           labels.length - 1,
                                            //         )],
                                            //     style: const TextStyle(
                                            //       fontSize: 16,
                                            //       fontWeight: FontWeight.bold,
                                            //       color: Colors.white,
                                            //     ),
                                            //   ),
                                            // ),
                                            const Divider(
                                              color: Colors.white,
                                              thickness: 1,
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        );
                                      } else if (item['type'] == "18" ||
                                          item['type'] == "19") {
                                        final selectedValue =
                                            _single_choice_answer[id] ?? '';
                                        final options =
                                            (item['questionType']?['choices']
                                                    as String?)
                                                ?.split(';')
                                                .map((e) => e.trim())
                                                .where((e) => e.isNotEmpty)
                                                .toList() ??
                                            [];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              question,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            CustomSingleChoice(
                                              options: options,
                                              selectedValue: selectedValue,
                                              onSelected: (val) async {
                                                setState(() {
                                                  _single_choice_answer[id] =
                                                      val.toString();
                                                });
                                                // Simpan langsung ke SharedPreferences
                                                final prefs =
                                                    await SharedPreferences.getInstance();
                                                final key =
                                                    'Evaluasi_answer_$id';
                                                await prefs.setString(
                                                  key,
                                                  val.toString(),
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            const Divider(
                                              color: Colors.white,
                                              thickness: 1,
                                            ),
                                          ],
                                        );
                                      } else if (item['type'] == "16") {
                                        final selectedString =
                                            _multiple_choice_answer[id] ?? '';
                                        final selectedValues =
                                            selectedString.isEmpty
                                                ? <String>[]
                                                : selectedString
                                                    .split(';')
                                                    .map((e) => e.trim())
                                                    .where((e) => e.isNotEmpty)
                                                    .toList();
                                        final options =
                                            (item['questionType']?['choices']
                                                    as String?)
                                                ?.split(';')
                                                .map((e) => e.trim())
                                                .where((e) => e.isNotEmpty)
                                                .toList() ??
                                            [];
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              question,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            CustomMultipleChoice(
                                              options: options,
                                              selectedValues: selectedValues,
                                              onSelected: (vals) async {
                                                final answerString = vals.join(
                                                  ';',
                                                );
                                                setState(() {
                                                  _multiple_choice_answer[id] =
                                                      answerString;
                                                });
                                                final prefs =
                                                    await SharedPreferences.getInstance();
                                                final key =
                                                    'Evaluasi_answer_$id';
                                                await prefs.setString(
                                                  key,
                                                  answerString,
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            const Divider(
                                              color: Colors.white,
                                              thickness: 1,
                                            ),
                                          ],
                                        );
                                      } else {
                                        return const SizedBox.shrink();
                                      }
                                    }).toList(),
                                    const SizedBox(height: 10),
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              await _saveProgress();
                                              if (context.mounted)
                                                Navigator.pop(context);
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: AppColors.brown1,
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: const [
                                                  Icon(
                                                    Icons.save,
                                                    color: Colors.white,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    'Save Progress',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0,
                                          ),
                                          child: GestureDetector(
                                            onTap:
                                                isLoading
                                                    ? null
                                                    : _handleSubmit,
                                            child: Container(
                                              width: double.infinity,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: AppColors.brown1,
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child:
                                                  isLoading
                                                      ? const CircularProgressIndicator(
                                                        color: Colors.white,
                                                      )
                                                      : Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: const [
                                                          Icon(
                                                            Icons.arrow_forward,
                                                            color: Colors.white,
                                                          ),
                                                          SizedBox(width: 8),
                                                          Text(
                                                            'Review Jawaban',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }
}
