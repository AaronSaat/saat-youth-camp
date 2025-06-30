import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/screens/bible_reading_list_screen.dart';
import 'package:syc/screens/evaluasi_komitmen_list_screen.dart';
import 'package:syc/screens/bible_reading_more_screen.dart';
import 'package:syc/utils/app_colors.dart';
import 'package:syc/widgets/custom_panel_shape.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_snackbar.dart';
import 'detail_acara_screen.dart';

class MateriScreen extends StatefulWidget {
  final String? userId;
  const MateriScreen({super.key, required this.userId});

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  bool _isLoading = true;
  int day = 1;
  Map<String, String> _dataUser = {};

  // progress
  Map<String, List<bool>> _komitmenDoneMap = {};
  Map<String, Map<String, int>> _komitmenSummaryMap = {};
  Map<String, List<bool>> _evaluasiDoneMap = {};
  Map<String, Map<String, int>> _evaluasiSummaryMap = {};

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
      await loadProgresKomitmenAnggota();
      await loadProgresEvaluasiAnggota();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
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
      print('User data HEY: $_dataUser');
    });
  }

  Future<void> loadProgresKomitmenAnggota() async {
    try {
      final komitmenList = await ApiService.getKomitmen(context);
      _komitmenDoneMap = {};
      _komitmenSummaryMap = {};
      final userId = _dataUser['id'] ?? '';
      List<bool> progress = List.filled(komitmenList.length, false);
      for (int i = 0; i < progress.length; i++) {
        try {
          final result = await ApiService.getKomitmenByPesertaByDay(
            context,
            userId,
            i + 1,
          );
          if (result['success'] == true) {
            progress[i] = true;
          }
        } catch (e) {
          // ignore error, keep as false
        }
      }
      _komitmenDoneMap[userId] = progress;
      // Hitung jumlah true/false
      int done = progress.where((e) => e).length;
      int notDone = progress.length - done;
      _komitmenSummaryMap[userId] = {'done': done, 'notDone': notDone};
      print('Progress Komitmen Map: \n$_komitmenDoneMap');
      print('Summary Komitmen Map: \n$_komitmenSummaryMap');
    } catch (e) {
      print('❌ Gagal memuat progress komitmen: $e');
    }
  }

  Future<void> loadProgresEvaluasiAnggota() async {
    if (!mounted) return;
    try {
      final acaraList = await ApiService.getAcara(context);
      _evaluasiDoneMap = {};
      _evaluasiSummaryMap = {};
      final userId = _dataUser['id'] ?? '';
      List<bool> progress = List.filled(acaraList.length, false);
      for (int i = 0; i < progress.length; i++) {
        try {
          final result = await ApiService.getEvaluasiByPesertaByAcara(
            context,
            userId,
            i + 1,
          );
          if (result['success'] == true) {
            progress[i] = true;
          }
        } catch (e) {
          // ignore error, keep as false
        }
      }
      _evaluasiDoneMap[userId] = progress;
      // Hitung jumlah true/false
      int done = progress.where((e) => e).length;
      int notDone = progress.length - done;
      _evaluasiSummaryMap[userId] = {'done': done, 'notDone': notDone};
      print('Progress evaluasi Map: \n$_evaluasiDoneMap');
      print('Summary evaluasi Map: \n$_evaluasiSummaryMap');
    } catch (e) {
      // Use a logging framework or handle error appropriately
      if (!mounted) return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Center(child: Text("TES - ${_dataUser['id']}")),
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
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 24.0,
                    bottom: 84,
                    left: 16,
                    right: 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Image.asset(
                              'assets/texts/materi.png',
                              height: 84,
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(right: 8),
                          //   child: Container(
                          //     height: 48,
                          //     width: 48,
                          //     decoration: BoxDecoration(`
                          //       color: Colors.white,
                          //       borderRadius: BorderRadius.circular(16),
                          //     ),
                          //     child: Icon(
                          //       Icons.search,
                          //       color: AppColors.primary,
                          //       size: 32,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? buildAcaraShimmer(context)
                          //     : _acaraList.isEmpty
                          //     ? Center(
                          //       child: CustomNotFound(
                          //         text: "Gagal memuat daftar materi :(",
                          //         textColor: AppColors.brown1,
                          //         imagePath: 'assets/images/data_not_found.png',
                          //         onBack: initAll,
                          //         backText: 'Reload Materi',
                          //       ),
                          //     )
                          : Builder(
                            builder: (context) {
                              // Ambil userId dari _dataUser
                              final userId = _dataUser['id'] ?? '';
                              // Progress Evaluasi
                              final progressEvaluasi =
                                  _evaluasiDoneMap[userId] ?? [];
                              final evaluasiTotal = progressEvaluasi.length;
                              final evaluasiDone =
                                  progressEvaluasi.where((e) => e).length;
                              final evaluasiProgress =
                                  evaluasiTotal > 0
                                      ? evaluasiDone / evaluasiTotal
                                      : 0.0;

                              // Progress Komitmen
                              final progressKomitmen =
                                  _komitmenDoneMap[userId] ?? [];
                              final komitmenTotal = progressKomitmen.length;
                              final komitmenDone =
                                  progressKomitmen.where((e) => e).length;
                              final komitmenProgress =
                                  komitmenTotal > 0
                                      ? komitmenDone / komitmenTotal
                                      : 0.0;

                              return Column(
                                children: [
                                  MateriMenuCard(
                                    title: 'Tautan',
                                    imagePath: 'assets/mockups/materi_buku.jpg',
                                    onTap: () async {
                                      const url =
                                          'https://library.seabs.ac.id/';
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        showCustomSnackBar(
                                          context,
                                          'Tidak dapat membuka Buku',
                                        );
                                      }
                                    },
                                    withProgress: false,
                                  ),
                                  MateriMenuCard(
                                    title: 'Youtube',
                                    imagePath:
                                        'assets/mockups/materi_youtube.jpg',
                                    onTap: () async {
                                      const url =
                                          'https://seabs.ac.id/resources/youtube-channel/';
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        showCustomSnackBar(
                                          context,
                                          'Tidak dapat membuka Youtube',
                                        );
                                      }
                                    },
                                    withProgress: false,
                                  ),
                                  MateriMenuCard(
                                    title: 'Berita',
                                    imagePath:
                                        'assets/mockups/materi_berita.jpg',
                                    onTap: () async {
                                      const url =
                                          'https://seabs.ac.id/resources/berita/';
                                      if (await canLaunchUrl(Uri.parse(url))) {
                                        await launchUrl(
                                          Uri.parse(url),
                                          mode: LaunchMode.externalApplication,
                                        );
                                      } else {
                                        showCustomSnackBar(
                                          context,
                                          'Tidak dapat membuka Berita',
                                        );
                                      }
                                    },
                                    // Progress belum tersedia untuk Bacaan Harian
                                    withProgress: false,
                                  ),
                                ],
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

  // Shimmer loading untuk daftar acara
  Widget buildAcaraShimmer(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: SizedBox(
            child: Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                Positioned(
                  left: 24,
                  bottom: 20,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 120,
                          height: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 180,
                          height: 10,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: MediaQuery.of(context).size.width * 0.1,
                  bottom: MediaQuery.of(context).size.height * 0.007,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 80,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MateriMenuCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final bool withProgress;
  final double valueProgress;
  final int? valueDone;
  final int? valueTotal;

  const MateriMenuCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.withProgress = false,
    this.valueProgress = 0.0,
    this.valueDone,
    this.valueTotal,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Image.asset(
                imagePath,
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ],
              ),
            ),
            if (withProgress)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: valueProgress,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                    ),
                    if (valueDone != null && valueTotal != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          '$valueDone/$valueTotal',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (withProgress) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
