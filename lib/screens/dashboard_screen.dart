import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_not_found.dart';
import 'daftar_acara_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'package:syc/utils/app_colors.dart';

import 'detail_acara_screen.dart';
import 'bible_reading_more_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _email = '';
  bool isPanitia = false;
  ScrollController _acaraController = ScrollController();
  int _currentAcaraPage = 0;
  List<dynamic> _acaraList = [];
  int day = 1;
  int countAcara = 5;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dataBrm = [];
  Map<String, String> _dataUser = {};
  int countRead = 0; //indikator user ini sudah membaca bacaan hariannya

  @override
  void initState() {
    super.initState();
    initAll();
    _acaraController.addListener(() {
      double itemWidth;
      if (countAcara <= 2) {
        itemWidth = 40;
      } else if (countAcara == 3) {
        itemWidth = 120;
      } else {
        itemWidth = 160;
      }
      setState(() {
        _currentAcaraPage = (_acaraController.offset / itemWidth).round();
      });
    });
  }

  Future<void> initAll() async {
    setState(() => _isLoading = true);
    try {
      await loadUserData();
      await loadBrm();
      await loadAcara();
      await loadReportBrmByPesertaByDay();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() => _isLoading = false);
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

  Future<void> loadBrm() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final brm = await ApiService.getBrmToday(context);
      if (!mounted) return;
      setState(() {
        final dataBrm = brm['data_brm'];
        if (dataBrm != null && dataBrm is Map<String, dynamic>) {
          _dataBrm = [dataBrm];
        } else {
          _dataBrm = [];
        }
        // print('Data BRM: $_dataBrm');
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadReportBrmByPesertaByDay() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final count = await ApiService.getBrmReportByPesertaByDay(
        context,
        _dataUser['id'] ?? '',
        DateTime.now().toIso8601String().substring(0, 10),
      );
      if (!mounted) return;
      setState(() {
        countRead = count;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> loadAcara() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final acaraList = await ApiService.getAcaraByDay(context, day);
      if (!mounted) return;
      setState(() {
        _acaraList = acaraList;
        _isLoading = false;
        countAcara = _acaraList.length;
        print('Acara List: \n$_acaraList');
        print('Jumlah Acara: ${_acaraList.length}');
      });
    } catch (e) {
      print('❌ Gagal memuat acara: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _acaraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _dataUser['id'] ?? '-';
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            child: Image.asset(
              'assets/images/background_dashboard.png',
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
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 96.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                'assets/buttons/hamburger_white.png',
                                height: 48,
                                width: 48,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/texts/hello.png', height: 72),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bible Reading Movement
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _isLoading
                                ? buildBrmShimmer()
                                : _dataBrm.isEmpty
                                ? Center(
                                  child: const CustomNotFound(
                                    text: "Gagal memuat data brm hari ini :(",
                                    textColor: AppColors.brown1,
                                    imagePath:
                                        'assets/images/data_not_found.png',
                                  ),
                                )
                                : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => BibleReadingMoreScreen(
                                              userId: userId,
                                            ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 180,
                                        padding: const EdgeInsets.only(
                                          left: 24,
                                          right: 24,
                                          bottom: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withAlpha(
                                            70,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                              'assets/mockups/bible_reading.jpg',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.bottomLeft,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              if (_dataBrm.isNotEmpty) ...[
                                                Text(
                                                  'Bacaan Hari Ini',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  _dataBrm[0]['passage'] ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ] else ...[
                                                const Text(
                                                  "Tidak ada data BRM hari ini",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (countRead > 0)
                                        Positioned(
                                          top: 0,
                                          left: 0,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.green,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      16,
                                                    ),
                                                    bottomRight:
                                                        Radius.circular(8),
                                                  ),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              children: const [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Sudah dibaca',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.secondary,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topRight: Radius.circular(16),
                                                  bottomLeft: Radius.circular(
                                                    8,
                                                  ),
                                                ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            _dataBrm.isNotEmpty
                                                ? DateFormatter.ubahTanggal(
                                                  _dataBrm[0]['tanggal'],
                                                )
                                                : '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Acara Hari Ini
                      _isLoading
                          ? buildAcaraShimmer()
                          : _acaraList.isEmpty
                          ? Center(
                            child: const CustomNotFound(
                              text: "Gagal memuat data acara hari ini :(",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                            ),
                          )
                          : Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: AppColors.grey1, // abu-abu muda
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  bottomLeft: Radius.circular(24),
                                ),
                              ),
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 8.0,
                                        ),
                                        child: Text(
                                          'Acara Hari Ini',
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.brown1,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (context) =>
                                                      const DaftarAcaraScreen(),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.arrow_forward_ios,
                                          color: AppColors.black1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 160,
                                    child: ListView.builder(
                                      controller: _acaraController,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: countAcara,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            right: 8.0,
                                          ),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (
                                                        context,
                                                      ) => DetailAcaraScreen(
                                                        id:
                                                            _acaraList[index]["id"],
                                                      ),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                8.0,
                                              ),
                                              child: Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Container(
                                                    height: 160,
                                                    width: 160,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          const BorderRadius.only(
                                                            bottomRight:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                            topLeft:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                  16,
                                                                ),
                                                          ),
                                                      image: DecorationImage(
                                                        image: () {
                                                          final acara =
                                                              _acaraList[index];
                                                          final nama =
                                                              acara['acara_nama']
                                                                  ?.toString() ??
                                                              '';
                                                          if (nama ==
                                                              'Pendaftaran Ulang dan Kedatangan') {
                                                            return Image.asset(
                                                              'assets/mockups/daftar.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'Opening') {
                                                            return Image.asset(
                                                              'assets/mockups/opening.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'KKR 1') {
                                                            return Image.asset(
                                                              'assets/mockups/kkr1.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'KKR 2') {
                                                            return Image.asset(
                                                              'assets/mockups/kkr2.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'KKR 3') {
                                                            return Image.asset(
                                                              'assets/mockups/kkr3.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'Saat Teduh') {
                                                            return Image.asset(
                                                              'assets/mockups/saat_teduh1.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'Drama Musikal') {
                                                            return Image.asset(
                                                              'assets/mockups/drama_musikal.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'New Year Countdown') {
                                                            return Image.asset(
                                                              'assets/mockups/new_year.jpg',
                                                            ).image;
                                                          } else if (nama ==
                                                              'Closing') {
                                                            return Image.asset(
                                                              'assets/mockups/closing.jpg',
                                                            ).image;
                                                          } else {
                                                            return Image.asset(
                                                              'assets/images/event.jpg',
                                                            ).image;
                                                          }
                                                        }(),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    // child: Padding(
                                                    //   padding:
                                                    //       const EdgeInsets.only(
                                                    //         left: 8,
                                                    //         right: 8,
                                                    //         bottom: 8,
                                                    //       ),
                                                    //   child: Align(
                                                    //     alignment:
                                                    //         Alignment.bottomLeft,
                                                    //     child: Column(
                                                    //       crossAxisAlignment:
                                                    //           CrossAxisAlignment
                                                    //               .start,
                                                    //       mainAxisAlignment:
                                                    //           MainAxisAlignment
                                                    //               .end,
                                                    //       children: [
                                                    //         Flexible(
                                                    //           child: Text(
                                                    //             _acaraList[index]['acara_nama'] ??
                                                    //                 'Acara ${index + 1}???',
                                                    //             textAlign:
                                                    //                 TextAlign
                                                    //                     .left,
                                                    //             style: const TextStyle(
                                                    //               fontSize: 18,
                                                    //               fontWeight:
                                                    //                   FontWeight
                                                    //                       .w900,
                                                    //               color:
                                                    //                   AppColors
                                                    //                       .primary,
                                                    //               overflow:
                                                    //                   TextOverflow
                                                    //                       .ellipsis,
                                                    //             ),
                                                    //           ),
                                                    //         ),
                                                    //         Row(
                                                    //           children: [
                                                    //             const Icon(
                                                    //               Icons
                                                    //                   .location_on,
                                                    //               color:
                                                    //                   AppColors
                                                    //                       .primary,
                                                    //               size: 12,
                                                    //             ),
                                                    //             const SizedBox(
                                                    //               width: 4,
                                                    //             ),
                                                    //             Flexible(
                                                    //               child: Text(
                                                    //                 _acaraList[index]['tempat'] ??
                                                    //                     '',
                                                    //                 style: const TextStyle(
                                                    //                   fontSize:
                                                    //                       14,
                                                    //                   color:
                                                    //                       AppColors
                                                    //                           .primary,
                                                    //                   fontWeight:
                                                    //                       FontWeight
                                                    //                           .w300,
                                                    //                 ),
                                                    //                 overflow:
                                                    //                     TextOverflow
                                                    //                         .ellipsis,
                                                    //               ),
                                                    //             ),
                                                    //           ],
                                                    //         ),
                                                    //       ],
                                                    //     ),
                                                    //   ),
                                                    // ),
                                                  ),
                                                  // text waktu
                                                  Positioned(
                                                    top: -5,
                                                    right: -5,
                                                    child: Card(
                                                      color:
                                                          AppColors.secondary,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: SizedBox(
                                                        width: 72,
                                                        height: 36,
                                                        child: Center(
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .access_time_filled_rounded,
                                                                color:
                                                                    AppColors
                                                                        .primary,
                                                                size: 16,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              Text(
                                                                _acaraList[index]['waktu'] ??
                                                                    '',
                                                                style: const TextStyle(
                                                                  color:
                                                                      AppColors
                                                                          .primary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  // text nama acara dan tempat
                                                  Positioned(
                                                    bottom: -5,
                                                    right: -5,
                                                    left: -5,
                                                    child: Card(
                                                      color: Colors.white,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              bottomLeft:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                              bottomRight:
                                                                  Radius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                      ),
                                                      elevation: 0,
                                                      child: SizedBox(
                                                        width: 72,
                                                        height: 48,
                                                        child: Center(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  8.0,
                                                                ),
                                                            child: Align(
                                                              alignment:
                                                                  Alignment
                                                                      .bottomLeft,
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  Flexible(
                                                                    child: Text(
                                                                      _acaraList[index]['acara_nama'] ??
                                                                          'Acara ${index + 1}???',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .left,
                                                                      style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                        color:
                                                                            AppColors.primary,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      const Icon(
                                                                        Icons
                                                                            .location_on,
                                                                        color:
                                                                            AppColors.primary,
                                                                        size:
                                                                            10,
                                                                      ),
                                                                      const SizedBox(
                                                                        width:
                                                                            4,
                                                                      ),
                                                                      Flexible(
                                                                        child: Text(
                                                                          _acaraList[index]['tempat'] ??
                                                                              '',
                                                                          style: const TextStyle(
                                                                            fontSize:
                                                                                10,
                                                                            color:
                                                                                AppColors.primary,
                                                                            fontWeight:
                                                                                FontWeight.w300,
                                                                          ),
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
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
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  if (countAcara > 1)
                                    Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(countAcara, (
                                          index,
                                        ) {
                                          return AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            width:
                                                _currentAcaraPage == index
                                                    ? 16
                                                    : 8,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color:
                                                  _currentAcaraPage == index
                                                      ? AppColors.primary
                                                      : Colors.grey,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                      const SizedBox(height: 32),

                      // Yellow card / card kuning dengan megaphone di atasnya
                      Stack(
                        children: [
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                            ),
                            padding: const EdgeInsets.only(
                              left: 16,
                              top: 16,
                              bottom: 16,
                            ),
                            child: Row(
                              children: [
                                // Left column with 2 texts
                                Column(
                                  children: [
                                    SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width *
                                          0.4,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            'Pengumuman',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            'Cek info terbaru di sini!',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -15,
                            right: -12,
                            child: Image.asset(
                              'assets/images/megaphone.png',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
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

Widget buildBrmShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    period: const Duration(milliseconds: 800),
    child: Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(width: 120, height: 24, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 16, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 80, height: 16, color: Colors.white),
          ],
        ),
      ),
    ),
  );
}

Widget buildAcaraShimmer() {
  return Padding(
    padding: const EdgeInsets.only(left: 24.0),
    child: Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: const Duration(milliseconds: 800),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.grey1, // abu-abu muda
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  top: 84.0,
                  bottom: 8.0,
                ),
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 80, height: 16, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
