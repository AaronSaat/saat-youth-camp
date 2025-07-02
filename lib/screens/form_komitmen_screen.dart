import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/review_komitmen_screen.dart';
import 'package:syc/utils/app_colors.dart';
import '../services/api_service.dart';
import '../widgets/custom_checkbox.dart';
import '../widgets/custom_slider.dart';
import '../widgets/custom_text_field.dart';
import 'review_evaluasi_screen.dart';
import '../widgets/custom_not_found.dart';

class FormKomitmenScreen extends StatefulWidget {
  final String userId;
  final int acaraHariId;

  const FormKomitmenScreen({
    super.key,
    required this.userId,
    required this.acaraHariId,
  });

  @override
  State<FormKomitmenScreen> createState() => _FormKomitmenScreenState();
}

class _FormKomitmenScreenState extends State<FormKomitmenScreen> {
  final Map<String, bool> _checkbox_answer = {};
  final Map<String, TextEditingController> _text_answer = {};
  bool isLoading = false;
  Map<String, dynamic> _acara = {};
  List<Map<String, dynamic>> _dataKomitmen = [];
  bool _isLoading = true;
  final Map<String, Timer?> _debounceTimers = {};

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
    final data = _dataKomitmen;
    final typeKey = "Komitmen";
    for (var item in data) {
      final key = '${typeKey}_answer_${item['id']}';
      print('Load key: $key');
      if (item['type'].toString() == '1') {
        // Text
        final controller = TextEditingController(
          text: prefs.getString(key) ?? '',
        );
        _text_answer[item['id'].toString()] = controller;
      } else if (item['type'].toString() == '2') {
        // Checkbox
        _checkbox_answer[item['id'].toString()] = prefs.getBool(key) ?? false;
      }
    }
    setState(() {});
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _dataKomitmen;
    final typeKey = "Komitmen";
    List<String> savedIds = [];
    for (var item in data) {
      final idStr = item['id'].toString();
      final key = '${typeKey}_answer_$idStr';
      savedIds.add(idStr);
      if (item['type'].toString().contains('1')) {
        await prefs.setString(key, _text_answer[idStr]?.text ?? '');
        print('Save Text: $key = ${_text_answer[idStr]?.text}');
      } else if (item['type'].toString() == '2') {
        await prefs.setBool(key, _checkbox_answer[idStr] ?? false);
        print('Save Checkbox: $key = ${_checkbox_answer[idStr] ?? false}');
      }
    }
    // Simpan list id pertanyaan untuk tipe ini
    await prefs.setStringList('${typeKey}_answer_ids', savedIds);

    final allKeys = prefs.getKeys();
    for (var key in allKeys) {
      print('Print SharedPref [$key]: ${prefs.get(key)}');
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
            (_) => ReviewKomitmenScreen(
              userId: widget.userId,
              acaraHariId: widget.acaraHariId,
            ),
      ),
    );
  }

  // kalo mau test print
  // void _onTextChangedDebounced(String id, String value) {
  //   print('[DEBOUNCE] TextField $id changed, value: $value');
  //   _debounceTimers[id]?.cancel();
  //   _debounceTimers[id] = Timer(const Duration(milliseconds: 600), () {
  //     print('[DEBOUNCE] TextField $id save triggered after 600ms');
  //     _saveProgress();
  //   });
  // }

  void _onChangedDebounced(String id) {
    _debounceTimers[id]?.cancel();
    _debounceTimers[id] = Timer(const Duration(milliseconds: 600), () {
      print('[DEBOUNCE] Checkbox $id save triggered after 600ms');
      _saveProgress();
    });
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer?.cancel();
    }
    for (var controller in _text_answer.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleImage = 'assets/texts/komitmen.png';

    final data = _dataKomitmen;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_form.png',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (_dataKomitmen.isEmpty)
                    ? CustomNotFound(
                      text:
                          'Data komitmen tidak ditemukan.\nSilakan kembali dan coba lagi nanti.',
                      textColor: Colors.white,
                      imagePath: 'assets/images/data_not_found.png',
                    )
                    : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
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
                                          'Form Komitmen Hari ke-${widget.acaraHariId}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...data.map<Widget>((item) {
                                      final String question =
                                          item['question'] ?? '';
                                      final String id = item['id'].toString();

                                      if (item['type'].toString() == '1') {
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
                                                  onChanged:
                                                      (value) =>
                                                          _onChangedDebounced(
                                                            id,
                                                          ),
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
                                      } else if (item['type'].toString() ==
                                          '2') {
                                        // Checkbox
                                        return Column(
                                          children: [
                                            CustomCheckbox(
                                              value:
                                                  _checkbox_answer[id] ?? false,
                                              onChanged:
                                                  (val) => setState(() {
                                                    _checkbox_answer[id] = val;
                                                    print(
                                                      'Checkbox $id changed to $val',
                                                    );
                                                    _onChangedDebounced(id);
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
                                            onTap:
                                                isLoading
                                                    ? null
                                                    : _handleSubmit,
                                            child: Container(
                                              width: double.infinity,
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
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
                                                            'Lanjutkan',
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
