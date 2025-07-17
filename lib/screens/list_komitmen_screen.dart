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
  DateTime _now = DateTime(2025, 12, 31, 0, 0, 0);

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
      await loadKomitmen();
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

  Future<void> loadKomitmen() async {
    setState(() {});
    try {
      final komitmenList = await ApiService.getKomitmen(context);
      _komitmenDoneList = List.filled(komitmenList.length ?? 0, false);
      for (int i = 0; i < _komitmenDoneList.length; i++) {
        try {
          final result = await ApiService.getKomitmenByPesertaByDay(context, widget.userId, i + 1);
          if (result != null && result['success'] == true) {
            _komitmenDoneList[i] = true;
          }
        } catch (e) {
          // ignore error, keep as false
        }
      }
      setState(() {
        _komitmenList = komitmenList ?? [];
        _isLoading = false;

        print('AARON: $_komitmenList');
      });
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
              onRefresh: () => initAll(),
              color: AppColors.brown1,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),

                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(children: [Image.asset('assets/texts/komitmen.png', height: 96)]),
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
                                icon: status == true ? Icons.check : Icons.arrow_outward_rounded,
                                onTap: () {
                                  String userId = widget.userId;
                                  int acaraHariId;
                                  acaraHariId = _komitmenList[index]['hari'];
                                  if (status == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => EvaluasiKomitmenViewScreen(
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
                                      DateTime tanggalKomitmen = DateTime.parse('$tanggal 15:00:00');

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
                                                (context) =>
                                                    FormKomitmenScreen(userId: userId, acaraHariId: acaraHariId),
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
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );
    }),
  );
}
