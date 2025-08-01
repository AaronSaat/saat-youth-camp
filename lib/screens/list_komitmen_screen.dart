import 'dart:convert'; // Tambahkan jika belum ada
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/form_evaluasi_screen.dart';
import 'package:shimmer/shimmer.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import '../utils/global_variables.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_snackbar.dart';
import 'form_komitmen_screen.dart';
import 'review_evaluasi_screen.dart';
import 'evaluasi_komitmen_view_screen.dart';

class ListKomitmenScreen extends StatefulWidget {
  final String userId;

  const ListKomitmenScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _ListKomitmenScreenState createState() => _ListKomitmenScreenState();
}

class _ListKomitmenScreenState extends State<ListKomitmenScreen> {
  List<dynamic> _komitmenList = [];
  List<dynamic> _komitmenDoneList = [];
  Map<String, String> _dataUser = {};
  bool _isLoading = true;

  // [DEVELOPMENT NOTES] nanti hapus
  // DateTime _today = DateTime.now();
  // DateTime _now = DateTime(2025, 12, 31, 0, 0, 0);
  late DateTime _today;
  late TimeOfDay _timeOfDay;
  late DateTime _now;

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
    setState(() {
      _isLoading = true;
    });

    try {
      await loadUserData();
      await loadKomitmen(forceRefresh: forceRefresh);
      setState(() {
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

  Future<void> loadKomitmen({bool forceRefresh = false}) async {
    setState(() {});
    final prefs = await SharedPreferences.getInstance();
    final komitmenKey = 'list_komitmen_${widget.userId}';
    final komitmenDoneKey = 'list_komitmen_done_${widget.userId}';

    if (!forceRefresh) {
      final cachedKomitmen = prefs.getString(komitmenKey);
      final cachedDone = prefs.getString(komitmenDoneKey);
      if (cachedKomitmen != null && cachedDone != null) {
        final komitmenList = jsonDecode(cachedKomitmen);
        final komitmenDoneList = jsonDecode(cachedDone);
        setState(() {
          _komitmenList = komitmenList ?? [];
          _komitmenDoneList = komitmenDoneList ?? [];
          _isLoading = false;
        });
        print('[PREF_API] Komitmen List (from shared pref): $_komitmenList');
        print(
          '[PREF_API] Komitmen Done List (from shared pref): $_komitmenDoneList',
        );
        return;
      }
    }

    try {
      final komitmenList = await ApiService.getKomitmen(context);
      _komitmenDoneList = List.filled(komitmenList.length ?? 0, false);
      for (int i = 0; i < _komitmenDoneList.length; i++) {
        try {
          final result = await ApiService.getKomitmenByPesertaByDay(
            context,
            widget.userId,
            i + 1,
          );
          if (result != null && result['success'] == true) {
            _komitmenDoneList[i] = true;
          }
        } catch (e) {}
      }
      await prefs.setString(komitmenKey, jsonEncode(komitmenList));
      await prefs.setString(komitmenDoneKey, jsonEncode(_komitmenDoneList));
      setState(() {
        _komitmenList = komitmenList ?? [];
        // _komitmenDoneList sudah di-set di atas
        _isLoading = false;
      });
      print('[PREF_API] Komitmen List (from API): $_komitmenList');
      print('[PREF_API] Komitmen Done List (from API): $_komitmenDoneList');
    } catch (e) {
      print('❌ Gagal memuat list komitmen: $e');
      setState(() {});
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
              onRefresh: () => initAll(forceRefresh: true),
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
                          Image.asset('assets/texts/komitmen.png', height: 96),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? buildShimmerList()
                          : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _komitmenList.length,
                            itemBuilder: (context, index) {
                              final items = _komitmenList;
                              String item;
                              bool? status;
                              final komitmen = items[index];
                              final tanggal = komitmen['tanggal'] ?? '';
                              item = 'Komitmen Hari ${komitmen['hari'] ?? '-'}';
                              status = _komitmenDoneList[index];
                              return CustomCard(
                                text: item,
                                icon:
                                    status == true
                                        ? Icons.check
                                        : Icons.arrow_outward_rounded,
                                onTap: () {
                                  String userId = widget.userId;
                                  int acaraHariId;
                                  acaraHariId = _komitmenList[index]['hari'];
                                  if (status == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                EvaluasiKomitmenViewScreen(
                                                  type: "Komitmen",
                                                  userId: userId,
                                                  acaraHariId: acaraHariId,
                                                ),
                                      ),
                                    );
                                  } else {
                                    if (_dataUser['id'] != widget.userId) {
                                      setState(() {
                                        if (!mounted) return;
                                        showCustomSnackBar(
                                          context,
                                          'Komitmen hanya bisa diisi oleh pemilikinya.',
                                          isSuccess: false,
                                        );
                                      });
                                    } else {
                                      // hDEVELOPMENT NOTES] nanti setting
                                      DateTime tanggalKomitmen = DateTime.parse(
                                        '$tanggal 15:00:00',
                                      );

                                      // Komitmen hanya bisa diisi pada tanggal yang sama atau setelahnya, dan setelah jam 3 sore
                                      if (_now.isBefore(tanggalKomitmen)) {
                                        showCustomSnackBar(
                                          context,
                                          'Komitmen hanya dapat diisi pada tanggal ${tanggal} pukul 15:00.',
                                          isSuccess: false,
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => FormKomitmenScreen(
                                                  userId: userId,
                                                  acaraHariId: acaraHariId,
                                                ),
                                          ),
                                        ).then((result) {
                                          if (result == 'reload') {
                                            initAll(forceRefresh: true);
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
