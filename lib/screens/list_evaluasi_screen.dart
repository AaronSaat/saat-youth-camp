import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';
import 'form_komitmen_screen.dart';
import 'review_evaluasi_screen.dart';
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

  @override
  void initState() {
    super.initState();
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await loadUserData();
      // Ambil count acara & count all
      try {
        final countAcara = await ApiService.getAcaraCount(context);
        final countAcaraAll = await ApiService.getAcaraCountAll(context);
        if (!mounted) return;
        setState(() {
          _countAcara = countAcara ?? 0;
          _countAcaraAll = countAcaraAll ?? 0;
        });
      } catch (e) {
        print('❌ Gagal memuat acara count dan acara count all: $e');
      }

      // Ambil list acara
      final acaraList = await ApiService.getAcaraByDay(context, day);
      if (!mounted) return;
      _acaraIdList = acaraList.map((acara) => acara['id']).toList();
      _evaluasiDoneList = List.filled(acaraList.length ?? 0, false);
      for (int i = 0; i < _evaluasiDoneList.length; i++) {
        try {
          final result = await ApiService.getEvaluasiByPesertaByAcara(
            context,
            widget.userId,
            _acaraIdList[i],
          );
          if (!mounted) return;
          if (result != null && result['success'] == true) {
            _evaluasiDoneList[i] = true;
          }
        } catch (e) {
          // ignore error, keep as false
        }
      }
      setState(() {
        _acaraList = acaraList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat data: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void loadEvaluasiAcara() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final acaraList = await ApiService.getAcaraByDay(context, day);
      _acaraIdList = acaraList.map((acara) => acara['id']).toList();
      print('test Acara ID List: $_acaraIdList');
      _evaluasiDoneList = List.filled(acaraList.length ?? 0, false);
      for (int i = 0; i < _evaluasiDoneList.length; i++) {
        try {
          final result = await ApiService.getEvaluasiByPesertaByAcara(
            context,
            widget.userId,
            _acaraIdList[i],
          );
          if (result != null && result['success'] == true) {
            _evaluasiDoneList[i] = true;
          }
        } catch (e) {
          // ignore error, keep as false
        }
      }
      setState(() {
        _acaraList = acaraList ?? [];
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat list acara: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ini untuk acara-count dan acara-count-all (jadi satu)
  void loadCountAcara() async {
    try {
      final countAcara = await ApiService.getAcaraCount(context);
      final countAcaraAll = await ApiService.getAcaraCountAll(context);
      setState(() {
        _countAcara = countAcara ?? 0;
        _countAcaraAll = countAcaraAll ?? 0;
      });
    } catch (e) {
      print('❌ Gagal memuat acara count dan acara count all: $e');
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = [
      'id',
      'username',
      'email',
      'role',
      'token',
      'gereja_id',
      'gereja_nama',
      'kelompok_id',
      'kelompok_nama',
    ];
    final Map<String, String> userData = {};
    for (final key in keys) {
      userData[key] = prefs.getString(key) ?? '';
    }
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
    // Tambahkan ScrollController agar bisa scroll ke tab yang dipilih
    final ScrollController _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Scroll ke posisi tab yang dipilih setelah build
      int selectedIdx = days.indexOf(day);
      if (selectedIdx != -1 && _scrollController.hasClients) {
        double offset = (selectedIdx * 108.0) - 16.0; // 100(width) + 8(spacing)
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
                  setState(() {
                    day = d;
                  });
                  loadEvaluasiAcara();
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
              onRefresh: () => initAll(),
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),

                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    bottom: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _acaraList.length,
                            itemBuilder: (context, index) {
                              final items = _acaraList;
                              String item;
                              bool? status;
                              final acara = items[index];
                              if (acara['hari'] == 99) {
                                item = '${acara['acara_nama'] ?? '-'}';
                              } else {
                                item =
                                    '${acara['acara_nama'] ?? '-'} (Hari ${acara['hari'] ?? '-'})';
                              }
                              status = _evaluasiDoneList[index];
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
                                  } else {
                                    final acara = _acaraList[index];
                                    String? tanggal = acara['tanggal'];
                                    String? waktu = acara['waktu'];
                                    DateTime? acaraDateTime;
                                    bool evaluate = false;
                                    String? time =
                                        '${acara['tanggal']} ${acara['waktu']}';
                                    if (_dataUser['id'] != widget.userId) {
                                      setState(() {
                                        if (!mounted) return;
                                        showCustomSnackBar(
                                          context,
                                          'Evaluasi hanya bisa diisi oleh pemilikinya.',
                                          isSuccess: false,
                                        );
                                      });
                                    } else if (tanggal != null &&
                                        waktu != null) {
                                      try {
                                        acaraDateTime = DateTime.parse(
                                          '$tanggal $waktu',
                                        );
                                        final now = DateTime.now();
                                        // final now = DateTime(
                                        //   2025,
                                        //   12,
                                        //   31,
                                        //   0,
                                        //   0,
                                        //   0,
                                        // ); // hardcode, [DEVELOPMENT NOTES] nanti hapus
                                        if (now.isAfter(
                                          acaraDateTime.add(
                                            const Duration(hours: 1),
                                          ),
                                        )) {
                                          evaluate = true;
                                        }
                                      } catch (e) {
                                        // ignore error, keep evaluate as false
                                      }
                                    } else if (_dataUser['id'] ==
                                            widget.userId &&
                                        acara['hari'] == 99) {
                                      final batasWaktu = DateTime(
                                        2025,
                                        7,
                                        17,
                                        15,
                                        0,
                                        0,
                                      );
                                      final now = DateTime.now();
                                      // final now = DateTime(
                                      //   2025,
                                      //   12,
                                      //   31,
                                      //   0,
                                      //   0,
                                      //   0,
                                      // ); // hardcode, [DEVELOPMENT NOTES] nanti hapus
                                      if (now.isBefore(batasWaktu)) {
                                        setState(() {
                                          if (!mounted) return;
                                          showCustomSnackBar(
                                            context,
                                            'Evaluasi keseluruhan dapat dilakukan pada 17 Juli 2025 pukul 12.00.',
                                            isSuccess: false,
                                          );
                                        });
                                      }
                                    }

                                    if (tanggal != null && waktu != null) {
                                      if (!evaluate) {
                                        setState(() {
                                          if (!mounted) return;
                                          showCustomSnackBar(
                                            context,
                                            'Evaluasi ${acara['acara_nama']} dapat dilakukan pada $time (1 jam setelah acara).',
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
                                            initAll();
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
