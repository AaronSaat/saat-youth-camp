import 'dart:convert'; // Tambahkan jika belum ada
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/global_variables.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';
import 'evaluasi_komitmen_view_screen.dart';

class ListEvaluasiScreen extends StatefulWidget {
  final String userId;

  const ListEvaluasiScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ListEvaluasiScreenState createState() => _ListEvaluasiScreenState();
}

class _ListEvaluasiScreenState extends State<ListEvaluasiScreen> {
  List<dynamic> _acaraList = [];
  List<dynamic> _evaluasiDoneList = [];
  List<dynamic> _acaraIdList =
      []; // untuk menyimpan acara ID supaya di listnya tau selesai atau belum
  Map<String, String> _dataUser = {};
  bool _isLoading = true;
  int day = 1; // default day
  int _countAcara = 1;
  int _countAcaraAll = 1;

  // [DEVELOPMENT NOTES] nanti hapus
  // DateTime _today = DateTime.now();
  // DateTime _now = DateTime(2025, 12, 31, 0, 0, 0);
  late DateTime _today;
  late TimeOfDay _timeOfDay;
  late DateTime _now;

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
    setState(() {
      _today = GlobalVariables.today;
      _timeOfDay = GlobalVariables.timeOfDay;
      _now = DateTime(
        _today.year,
        _today.month,
        _today.day,
        _timeOfDay.hour,
        _timeOfDay.minute,
      );
    });
    initAll();
  }

  Future<void> initAll({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      await loadUserData();
      await loadCountAcaraCountAll();
      await loadEvaluasiAcara(forceRefresh: forceRefresh);
    } catch (e) {
      print('❌ Gagal memuat data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadEvaluasiAcara({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final acaraKey = 'list_evaluasi_acara_${widget.userId}_$day';
    final evaluasiDoneKey = 'list_evaluasi_done_${widget.userId}_$day';

    if (!forceRefresh) {
      final cachedAcara = prefs.getString(acaraKey);
      final cachedDone = prefs.getString(evaluasiDoneKey);
      if (cachedAcara != null && cachedDone != null) {
        final acaraList = jsonDecode(cachedAcara);
        final evaluasiDoneList = jsonDecode(cachedDone);
        // Pastikan panjang evaluasiDoneList sama dengan acaraList
        List<dynamic> fixedEvaluasiDoneList = List.generate(
          acaraList.length,
          (i) => (i < evaluasiDoneList.length ? evaluasiDoneList[i] : false),
        );
        _acaraIdList = acaraList.map((acara) => acara['id']).toList();
        if (!mounted) return;
        setState(() {
          _acaraList = acaraList ?? [];
          _evaluasiDoneList = fixedEvaluasiDoneList;
          _isLoading = false;
        });
        print('[PREF_API] Acara List (from shared pref): $_acaraList');
        print(
          '[PREF_API] Evaluasi Done List (from shared pref): $_evaluasiDoneList',
        );
        return;
      }
    }

    try {
      final acaraList = await ApiService().getAcaraByDay(context, day);
      _acaraIdList = acaraList.map((acara) => acara['id']).toList();
      _evaluasiDoneList = List.filled(acaraList.length, false);
      for (int i = 0; i < _evaluasiDoneList.length; i++) {
        try {
          final result = await ApiService().getEvaluasiByPesertaByAcara(
            context,
            widget.userId,
            _acaraIdList[i],
          );
          if (result['success'] == true) {
            _evaluasiDoneList[i] = true;
          }
        } catch (e) {}
      }
      await prefs.setString(acaraKey, jsonEncode(acaraList));
      await prefs.setString(evaluasiDoneKey, jsonEncode(_evaluasiDoneList));
      if (!mounted) return;
      setState(() {
        _acaraList = acaraList;
        _isLoading = false;
      });
      print('[PREF_API] Acara List (from API): $_acaraList');
      print('[PREF_API] Evaluasi Done List (from API): $_evaluasiDoneList');
    } catch (e) {
      print('❌ Gagal memuat list acara: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadCountAcaraCountAll({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final countAcaraKey = 'list_evaluasi_count_acara_${widget.userId}';
    final countAcaraAllKey = 'list_evaluasi_count_acara_all_${widget.userId}';

    if (!forceRefresh) {
      final cachedCountAcara = prefs.getInt(countAcaraKey);
      final cachedCountAcaraAll = prefs.getInt(countAcaraAllKey);
      if (cachedCountAcara != null && cachedCountAcaraAll != null) {
        if (!mounted) return;
        setState(() {
          _countAcara = cachedCountAcara;
          _countAcaraAll = cachedCountAcaraAll;
        });
        await loadEvaluasiAcara(forceRefresh: false);
        return;
      }
    }

    try {
      final countAcara = await ApiService().getAcaraCount(context);
      final countAcaraAll = await ApiService().getAcaraCountAll(context);
      await prefs.setInt(countAcaraKey, countAcara);
      await prefs.setInt(countAcaraAllKey, countAcaraAll);
      if (!mounted) return;
      setState(() {
        _countAcara = countAcara;
        _countAcaraAll = countAcaraAll;
      });
      await loadEvaluasiAcara(forceRefresh: forceRefresh);
    } catch (e) {
      print('❌ Gagal memuat acara count dan acara count all: $e');
    }
  }

  Future<void> loadUserData() async {
    final token = await secureStorage.read(key: 'token');
    final email = await secureStorage.read(key: 'email');
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      // 'token',
      // 'email',
      'role',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }
    userData['token'] = token ?? '';
    userData['email'] = email ?? '';
    if (!mounted) return;
    setState(() {
      _dataUser = userData;
    });
  }

  Widget _buildDaySelector() {
    List<int> days = List.generate(_countAcara, (index) => index + 1);
    if (_countAcaraAll > _countAcara) {
      days.add(99);
    }
    final ScrollController _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      int selectedIdx = days.indexOf(day);
      if (selectedIdx != -1 && _scrollController.hasClients) {
        double offset = (selectedIdx * 108.0) - 16.0;
        if (offset < 0) offset = 0;
        _scrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 200),
          curve: Curves.ease,
        );
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 0.0),
      child: SizedBox(
        height: 48,
        child: ListView.separated(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: days.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, idx) {
            final d = days[idx];
            final bool selected = day == d;
            return GestureDetector(
              onTap: () {
                if (day != d) {
                  if (!mounted) return;
                  setState(() {
                    day = d;
                  });
                  loadEvaluasiAcara(forceRefresh: false);
                }
              },
              child: Container(
                width: 120,
                height: 48,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  d == 99 ? 'Keseluruhan' : 'Hari ke-$d',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = _dataUser['role'] ?? '';
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context, 'reload'),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_fade.jpg',
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.fill,
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await initAll(forceRefresh: true);
              },
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 0.0,
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Column(
                    children: [
                      Image.asset('assets/texts/evaluasi.png', height: 96),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDaySelector(),
                  const SizedBox(height: 16),
                  _isLoading
                      ? buildShimmerList()
                      : ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _acaraList.length,
                        itemBuilder: (context, index) {
                          final items = _acaraList;
                          String item;
                          bool status =
                              false; // default false jika evaluasiDoneList belum siap
                          final acara = items[index];
                          if (acara['hari'] == 99) {
                            item = '${acara['acara_nama'] ?? '-'}';
                          } else {
                            item =
                                '${acara['acara_nama'] ?? '-'} (Hari ${acara['hari'] ?? '-'})';
                          }
                          // Cegah RangeError jika _evaluasiDoneList belum siap
                          if (_evaluasiDoneList.length > index) {
                            status = _evaluasiDoneList[index];
                          }
                          print(
                            '[PREF_API] Evaluasi status for $item: $status',
                          );
                          final isEvalVal = acara['is_eval'];
                          final bool isEval =
                              isEvalVal == 1 ||
                              isEvalVal == '1' ||
                              isEvalVal == true;
                          if (!isEval) {
                            return const SizedBox.shrink();
                          }

                          return CustomCard(
                            text: item,
                            icon:
                                status == true
                                    ? Icons.check
                                    : Icons.arrow_outward_rounded,
                            onTap: () {
                              String userId = widget.userId;
                              int acaraHariId;
                              acaraHariId = _acaraList[index]['id'];
                              if (status == true) {
                                if (role.toLowerCase().contains(
                                  'pembimbing kelompok',
                                )) {
                                  setState(() {
                                    if (!mounted) return;
                                    showCustomSnackBar(
                                      context,
                                      'Pembimbing kelompok tidak dapat melihat jawaban evaluasi.',
                                      isSuccess: false,
                                    );
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              EvaluasiKomitmenViewScreen(
                                                type: "Evaluasi",
                                                userId: userId,
                                                acaraHariId: acaraHariId,
                                              ),
                                    ),
                                  );
                                }
                              } else {
                                final acara = _acaraList[index];
                                String? tanggal = acara['tanggal'];
                                String? waktu = acara['waktu'];
                                DateTime? acaraDateTime;
                                bool evaluate = false;
                                String? time =
                                    '${acara['tanggal']} ${acara['waktu']}';
                                if (_dataUser['id'] != widget.userId) {
                                  if (!mounted) return;
                                  setState(() {
                                    showCustomSnackBar(
                                      context,
                                      'Evaluasi hanya bisa diisi oleh pemiliknya.',
                                      isSuccess: false,
                                    );
                                  });
                                } else if (tanggal != null && waktu != null) {
                                  try {
                                    acaraDateTime = DateTime.parse(
                                      '$tanggal $waktu',
                                    );
                                    if (_now.isAfter(
                                      acaraDateTime.add(
                                        const Duration(hours: 1),
                                      ),
                                    )) {
                                      evaluate = true;
                                    }
                                  } catch (e) {
                                    // ignore error, keep evaluate as false
                                  }
                                }

                                if (_dataUser['id'] == widget.userId &&
                                    acara['hari'] == 99) {
                                  setState(() {
                                    if (!mounted) return;
                                    showCustomSnackBar(
                                      context,
                                      'Evaluasi keseluruhan dapat dilakukan setelah $time.',
                                      isSuccess: false,
                                    );
                                  });
                                }

                                if (tanggal != null && waktu != null) {
                                  if (!evaluate) {
                                    setState(() {
                                      if (!mounted) return;
                                      showCustomSnackBar(
                                        context,
                                        'Evaluasi ${acara['acara_nama']} dapat dilakukan pada 1 jam setelah acara.\nWaktu acara: $time WIB',
                                        isSuccess: false,
                                      );
                                    });
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => FormEvaluasiScreen(
                                              userId: userId,
                                              acaraHariId: acaraHariId,
                                            ),
                                      ),
                                    ).then((result) {
                                      if (result == 'reload') {
                                        initAll(forceRefresh: true);
                                        loadEvaluasiAcara(forceRefresh: true);
                                      }
                                    });
                                  }
                                }
                              }
                            },
                            iconBackgroundColor: AppColors.brown1,
                            showCheckIcon: status == true,
                          );
                        },
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget buildShimmerList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(5, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      );
    }),
  );
}
