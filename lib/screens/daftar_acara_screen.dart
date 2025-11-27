import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemNavigator;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syc/utils/app_colors.dart';
import '../services/api_service.dart';
import '../utils/global_variables.dart';
import '../widgets/custom_not_found.dart';
import '../widgets/custom_snackbar.dart';
import 'detail_acara_screen.dart';

class DaftarAcaraScreen extends StatefulWidget {
  const DaftarAcaraScreen({super.key});

  @override
  State<DaftarAcaraScreen> createState() => _DaftarAcaraScreenState();
}

class _DaftarAcaraScreenState extends State<DaftarAcaraScreen> {
  List<dynamic> _acaraList = [];
  List<dynamic> _tanggalList = [];
  int _countAcara = 0;
  bool _isLoading = true;
  int day = 1;
  Map<String, String> _dataUser = {};
  DateTime? _lastBackPressed;

  // DateTime _today = DateTime.now();
  // DateTime _today = DateTime(2026, 01, 01);
  late DateTime _today;
  // [DEVELOPMENT NOTES] nanti hapus

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _lastBackPressed = null;
    //[DEVELOPMENT NOTES] untuk testing, nanti dihapus
    setState(() {
      _today = GlobalVariables.today;
    });
    initAll();
  }

  Future<void> initAll() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await loadUserData();
      await loadCountAcara();
      await matchDateWithToday();
      await loadAcara();
    } catch (e) {
      // handle error jika perlu
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> loadAcara({bool forceRefresh = false}) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    print('[PREF_API] Loading acara for day: $day');
    try {
      final prefs = await SharedPreferences.getInstance();
      final acaraKey = 'daftar_acara_acara_day_$day';
      final acaraString = prefs.getString(acaraKey);

      if (!forceRefresh && acaraString != null && acaraString.isNotEmpty) {
        // Jika sudah ada di shared pref dan bukan refresh, load dari sana
        final List<dynamic> acaraList = jsonDecode(acaraString);
        if (!mounted) return;
        setState(() {
          print('[PREF_API] Acara found in shared preferences for day $day');
          _acaraList = acaraList;
          _isLoading = false;
        });
        return;
      }

      // Jika forceRefresh atau belum ada di shared pref, fetch dari API
      final acaraList = await ApiService().getAcaraByDay(context, day);
      if (!mounted) return;
      setState(() {
        print('[PREF_API] Fetched acara from API for day $day');
        _acaraList = acaraList;
        _isLoading = false;
      });

      // Simpan ke shared pref
      if (acaraList.isNotEmpty) {
        await prefs.setString(acaraKey, jsonEncode(acaraList));
      }
    } catch (e) {
      print('❌ Gagal memuat acara: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Ambil tanggal hari ini dan set day jika ada di tanggalList
  Future<void> matchDateWithToday({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final tanggalListKey = 'daftar_acara_tanggal_list';
    List<dynamic> tanggalList = [];

    if (!forceRefresh) {
      // Coba ambil dari shared pref lebih dulu
      final cachedTanggalList = prefs.getString(tanggalListKey);
      if (cachedTanggalList != null && cachedTanggalList.isNotEmpty) {
        tanggalList = jsonDecode(cachedTanggalList);
        print('[PREF_API] Tanggal List loaded from shared pref');
      }
    }

    if (forceRefresh || tanggalList.isEmpty) {
      // Jika forceRefresh atau belum ada di shared pref, fetch dari API
      final tanggalListResponse = await ApiService().getTanggalAcara(context);
      if (tanggalListResponse.isNotEmpty) {
        if (tanggalListResponse[0] is List) {
          tanggalList = tanggalListResponse[0];
        } else if (tanggalListResponse[0] is Map) {
          final mapTanggal = tanggalListResponse[0] as Map;
          tanggalList =
              mapTanggal.entries.map((e) {
                final val = e.value;
                if (val is Map) {
                  return val;
                } else {
                  return {'tanggal': e.key, 'hari': val};
                }
              }).toList();
        }
        // Simpan ke shared pref
        await prefs.setString(tanggalListKey, jsonEncode(tanggalList));
        print(
          '[PREF_API] Tanggal List fetched from API and saved to shared pref',
        );
      }
    }

    _tanggalList = tanggalList;
    print('Tanggal List: $_tanggalList');
    final match = _tanggalList.firstWhere(
      (item) => item['tanggal'] == _today.toIso8601String().substring(0, 10),
      orElse: () => null,
    );
    if (!mounted) return;
    setState(() {
      print(
        '[PREF_API] Match today: ${_today.toIso8601String().substring(0, 10)}',
      );
      print('[PREF_API] Match: $match');
      if (match != null && match['hari'] != null) {
        day = match['hari'];
      } else {
        day = 1;
      }
    });
  }

  Future<void> loadCountAcara({bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    const countAcaraKey = 'daftar_acara_count_acara';
    int? countAcara;

    if (!forceRefresh) {
      // Coba ambil dari shared pref lebih dulu
      final cachedCount = prefs.getInt(countAcaraKey);
      if (cachedCount != null) {
        countAcara = cachedCount;
        print('[PREF_API] Count acara loaded from shared pref: $countAcara');
      }
    }

    if (forceRefresh || countAcara == null) {
      // Jika forceRefresh atau belum ada di shared pref, fetch dari API
      try {
        final apiCountAcara = await ApiService().getAcaraCount(context);
        if (!mounted) return;
        setState(() {
          _countAcara = apiCountAcara;
        });
        // Simpan ke shared pref
        await prefs.setInt(countAcaraKey, apiCountAcara);
        print(
          '[PREF_API] Count acara fetched from API and saved to shared pref: $apiCountAcara',
        );
      } catch (e) {
        print('❌ Gagal memuat acara count: $e');
      }
    } else {
      if (!mounted) return;
      setState(() {
        _countAcara = countAcara!;
      });
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
    final List<int> days = List.generate(_countAcara, (index) => index + 1);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            days.map((d) {
              final bool selected = day == d;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: GestureDetector(
                    onTap: () {
                      if (day != d) {
                        setState(() {
                          day = d;
                        });
                        loadAcara();
                      }
                    },
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Hari ke-$d',
                        style: TextStyle(
                          color: selected ? Colors.white : AppColors.primary,
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _lastBackPressed = null;
    final userId = _dataUser['id'] ?? '-';
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          final now = DateTime.now();
          if (_lastBackPressed == null ||
              now.difference(_lastBackPressed!) > Duration(seconds: 2)) {
            _lastBackPressed = now;
            showCustomSnackBar(
              context,
              "Tekan sekali lagi untuk keluar aplikasi",
              duration: const Duration(seconds: 5),
              showDismissButton: false,
              showAppIcon: true,
            );
          } else {
            // Keluar aplikasi
            Future.delayed(const Duration(milliseconds: 100), () {
              // ignore: use_build_context_synchronously
              SystemNavigator.pop();
            });
          }
        }
      },
      child: Scaffold(
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
                onRefresh:
                    () => loadAcara(forceRefresh: true)
                        .then((_) => matchDateWithToday(forceRefresh: true))
                        .then((_) => loadCountAcara(forceRefresh: true)),
                color: AppColors.brown1,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.only(top: 32, bottom: 64),
                    child: Column(
                      children: [
                        // Padding(
                        //   padding: const EdgeInsets.only(right: 16),
                        //   child: Column(
                        //     children: [
                        //       Align(
                        //         alignment: Alignment.topRight,
                        //         child: Container(
                        //           height: 48,
                        //           width: 48,
                        //           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        //           child: Icon(Icons.search, color: AppColors.primary, size: 32),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Image.asset(
                                  'assets/texts/daftar_acara.png',
                                  height: 100,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildDaySelector(),
                        _isLoading
                            ? buildAcaraShimmer(context)
                            : _acaraList.isEmpty
                            ? Center(
                              child: CustomNotFound(
                                text: "Gagal memuat daftar acara :(",
                                textColor: AppColors.brown1,
                                imagePath: 'assets/images/data_not_found.png',
                                onBack: initAll,
                                backText: 'Reload Acara',
                              ),
                            )
                            : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _acaraList.length,
                              itemBuilder: (context, index) {
                                final acara = _acaraList[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () {
                                      // Cek jika acara['tanggal'] dan acara['waktu'] adalah 1 jam sebelum sekarang
                                      if (acara['tanggal'] != null &&
                                          acara['waktu'] != null) {
                                        try {
                                          final tanggal =
                                              acara['tanggal'].toString();
                                          final waktu =
                                              acara['waktu'].toString();
                                          final dateTimeString =
                                              '$tanggal $waktu';
                                          final acaraDateTime = DateTime.parse(
                                            dateTimeString,
                                          );
                                          final now = DateTime.now();
                                          // final now = DateTime(
                                          //   2026,
                                          //   12,
                                          //   31,
                                          //   0,
                                          //   0,
                                          //   0,
                                          // ); // hardcode, [DEVELOPMENT NOTES] nanti hapus
                                          final diff =
                                              acaraDateTime
                                                  .difference(now)
                                                  .inMinutes;

                                          print(
                                            'MBEK: ${now} - Tanggal: $tanggal - Waktu: $waktu - Diff: $diff',
                                          );
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (
                                                    context,
                                                  ) => DetailAcaraScreen(
                                                    id: acara["id"].toString(),
                                                    userId: userId,
                                                  ),
                                            ),
                                          );
                                          // if (diff <= 60 && diff <= 0) {
                                          //   //kurang dari itu maksudnya udah lewat jam
                                          //   Navigator.push(
                                          //     context,
                                          //     MaterialPageRoute(
                                          //       builder:
                                          //           (
                                          //             context,
                                          //           ) => DetailAcaraScreen(
                                          //             id: acara["id"].toString(),
                                          //             userId: userId,
                                          //           ),
                                          //     ),
                                          //   );
                                          // } else {
                                          //   showCustomSnackBar(
                                          //     context,
                                          //     'Detail acara hanya bisa dibuka 1 jam sebelum acara dimulai.',
                                          //   );
                                          // }
                                        } catch (e) {
                                          showCustomSnackBar(
                                            context,
                                            'Format tanggal/waktu acara tidak valid.',
                                          );
                                        }
                                      } else {
                                        showCustomSnackBar(
                                          context,
                                          'Tanggal atau waktu acara tidak tersedia.',
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: MediaQuery.of(context).size.width,
                                      height:
                                          MediaQuery.of(context).size.height *
                                          0.2,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        image: DecorationImage(
                                          image: () {
                                            final nama =
                                                acara['acara_nama']
                                                    ?.toString() ??
                                                '';
                                            final id =
                                                acara['id']?.toString() ?? '';
                                            switch (id) {
                                              case '1':
                                                return Image.asset(
                                                  'assets/mockups/registration.jpg',
                                                ).image;
                                              case '2':
                                                return Image.asset(
                                                  'assets/mockups/bonding.jpg',
                                                ).image;
                                              case '3':
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case '4':
                                                return Image.asset(
                                                  'assets/mockups/opening.jpg',
                                                ).image;
                                              case '5':
                                                return Image.asset(
                                                  'assets/mockups/awg.jpg',
                                                ).image;
                                              case '6':
                                                return Image.asset(
                                                  'assets/mockups/rest.jpg',
                                                ).image;
                                              case '7':
                                                return Image.asset(
                                                  'assets/mockups/preparation.jpg',
                                                ).image;
                                              case '8':
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case '9':
                                                return Image.asset(
                                                  'assets/mockups/devotion.jpg',
                                                ).image;
                                              case '10':
                                                return Image.asset(
                                                  'assets/mockups/activity.jpg',
                                                ).image;
                                              case '11':
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case '12':
                                                return Image.asset(
                                                  'assets/mockups/semifinal.jpg',
                                                ).image;
                                              case '13':
                                                return Image.asset(
                                                  'assets/mockups/preparation.jpg',
                                                ).image;
                                              case '14':
                                                return Image.asset(
                                                  'assets/mockups/talks.jpg',
                                                ).image;
                                              case '15':
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case '16':
                                                return Image.asset(
                                                  'assets/mockups/kkr2.jpg',
                                                ).image;
                                              case '40':
                                                return Image.asset(
                                                  'assets/mockups/180degrees.jpg',
                                                ).image;
                                              case "17":
                                                return Image.asset(
                                                  'assets/mockups/special.jpg',
                                                ).image;
                                              case '18':
                                                return Image.asset(
                                                  'assets/mockups/rest.jpg',
                                                ).image;
                                              case '19':
                                                return Image.asset(
                                                  'assets/mockups/preparation.jpg',
                                                ).image;
                                              case '20':
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case '21':
                                                return Image.asset(
                                                  'assets/mockups/devotion.jpg',
                                                ).image;
                                              case '22':
                                                return Image.asset(
                                                  'assets/mockups/activity.jpg',
                                                ).image;
                                              case '23':
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case '24':
                                                return Image.asset(
                                                  'assets/mockups/final.jpg',
                                                ).image;
                                              case "25":
                                                return Image.asset(
                                                  'assets/mockups/preparation.jpg',
                                                ).image;
                                              case "26":
                                                return Image.asset(
                                                  'assets/mockups/talks.jpg',
                                                ).image;
                                              case "27":
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case "28":
                                                return Image.asset(
                                                  'assets/mockups/kkr3.jpg',
                                                ).image;
                                              case "29":
                                                return Image.asset(
                                                  'assets/mockups/amongus.jpg',
                                                ).image;
                                              case "30":
                                                return Image.asset(
                                                  'assets/mockups/rest.jpg',
                                                ).image;
                                              case "31":
                                                return Image.asset(
                                                  'assets/mockups/preparation.jpg',
                                                ).image;
                                              case "32":
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case "33":
                                                return Image.asset(
                                                  'assets/mockups/devotion.jpg',
                                                ).image;
                                              case "34":
                                                return Image.asset(
                                                  'assets/mockups/closing.jpg',
                                                ).image;
                                              case "35":
                                                return Image.asset(
                                                  'assets/mockups/eat.jpg',
                                                ).image;
                                              case "36":
                                                return Image.asset(
                                                  'assets/mockups/seeyou.jpg',
                                                ).image;
                                              default:
                                                return Image.asset(
                                                  'assets/images/event.jpg',
                                                ).image;
                                            }
                                          }(),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                            24,
                                            0,
                                            16,
                                            20,
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                acara['acara_nama']
                                                        ?.toString() ??
                                                    '',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: () {
                                                    final nama =
                                                        acara['acara_nama']
                                                            ?.toString() ??
                                                        '';
                                                    if (nama.length > 40) {
                                                      return 14.0;
                                                    } else if (nama.length >
                                                        20) {
                                                      return 18.0;
                                                    } else {
                                                      return 22.0;
                                                    }
                                                  }(),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                () {
                                                  final desc =
                                                      acara['acara_deskripsi']
                                                          ?.toString() ??
                                                      '';
                                                  if (desc.length > 40) {
                                                    return desc.substring(
                                                          0,
                                                          40,
                                                        ) +
                                                        '...';
                                                  }
                                                  return desc;
                                                }(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${acara['tanggal'] ?? '-'}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(
                                                    Icons.access_time,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    acara['waktu_end'] ==
                                                                null ||
                                                            acara['waktu_end']
                                                                .toString()
                                                                .isEmpty
                                                        ? '${acara['waktu'] ?? '-'}'
                                                        : '${acara['waktu'] ?? '-'} - ${acara['waktu_end']}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Icon(
                                                    Icons.place,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      '${acara['tempat'] ?? '-'}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
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
                                );
                              },
                            ),
                        // custom shape
                        // : ListView.builder(
                        //   shrinkWrap: true,
                        //   physics: const NeverScrollableScrollPhysics(),
                        //   padding: const EdgeInsets.all(16),
                        //   itemCount: _acaraList.length,
                        //   itemBuilder: (context, index) {
                        //     final acara = _acaraList[index];
                        //     print(
                        //       'Acara: ${acara['id']} - ${acara['acara_nama']}',
                        //     );
                        //     return Padding(
                        //       padding: const EdgeInsets.only(bottom: 16),
                        //       child: SizedBox(
                        //         child: Stack(
                        //           children: [
                        //             GestureDetector(
                        //               onTap: () {
                        //                 Navigator.push(
                        //                   context,
                        //                   MaterialPageRoute(
                        //                     builder:
                        //                         (context) =>
                        //                             DetailAcaraScreen(
                        //                               id: acara["id"],
                        //                               hari: acara["hari"],
                        //                               userId: userId,
                        //                             ),
                        //                   ),
                        //                 );
                        //               },
                        //               child: CustomPanelShape(
                        //                 width:
                        //                     MediaQuery.of(context).size.width,
                        //                 height:
                        //                     MediaQuery.of(
                        //                       context,
                        //                     ).size.height *
                        //                     0.2,

                        //                 imageProvider: () {
                        //                   final nama =
                        //                       acara['acara_nama']
                        //                           ?.toString() ??
                        //                       '';
                        //                   if (nama ==
                        //                       'Pendaftaran Ulang dan Kedatangan') {
                        //                     return Image.asset(
                        //                       'assets/mockups/daftar.jpg',
                        //                     ).image;
                        //                   } else if (nama == 'Opening') {
                        //                     return Image.asset(
                        //                       'assets/mockups/opening.jpg',
                        //                     ).image;
                        //                   } else if (nama == 'KKR 1') {
                        //                     return Image.asset(
                        //                       'assets/mockups/kkr1.jpg',
                        //                     ).image;
                        //                   } else if (nama == 'KKR 2') {
                        //                     return Image.asset(
                        //                       'assets/mockups/kkr2.jpg',
                        //                     ).image;
                        //                   } else if (nama == 'KKR 3') {
                        //                     return Image.asset(
                        //                       'assets/mockups/kkr3.jpg',
                        //                     ).image;
                        //                   } else if (nama == 'Saat Teduh') {
                        //                     return Image.asset(
                        //                       'assets/mockups/saat_teduh1.jpg',
                        //                     ).image;
                        //                   } else if (nama ==
                        //                       'Drama Musikal') {
                        //                     return Image.asset(
                        //                       'assets/mockups/drama_musikal.jpg',
                        //                     ).image;
                        //                   } else if (nama ==
                        //                       'New Year Countdown') {
                        //                     return Image.asset(
                        //                       'assets/mockups/new_year.jpg',
                        //                     ).image;
                        //                   } else if (nama == 'Closing') {
                        //                     return Image.asset(
                        //                       'assets/mockups/closing.jpg',
                        //                     ).image;
                        //                   } else {
                        //                     return Image.asset(
                        //                       'assets/images/event.jpg',
                        //                     ).image;
                        //                   }
                        //                 }(),
                        //               ),
                        //             ),
                        //             Positioned(
                        //               left: 24,
                        //               bottom: 20,
                        //               right: 16,
                        //               child: Column(
                        //                 crossAxisAlignment:
                        //                     CrossAxisAlignment.start,
                        //                 children: [
                        //                   Text(
                        //                     acara['acara_nama']?.toString() ??
                        //                         '',
                        //                     style: const TextStyle(
                        //                       color: Colors.white,
                        //                       fontSize: 20,
                        //                       fontWeight: FontWeight.bold,
                        //                     ),
                        //                   ),
                        //                   const SizedBox(height: 4),
                        //                   RichText(
                        //                     text: TextSpan(
                        //                       style: const TextStyle(
                        //                         color: Colors.white,
                        //                         fontSize: 10,
                        //                       ),
                        //                       text: () {
                        //                         final desc =
                        //                             acara['acara_deskripsi']
                        //                                 ?.toString() ??
                        //                             '';
                        //                         if (desc.length > 30) {
                        //                           return desc.substring(
                        //                                 0,
                        //                                 30,
                        //                               ) +
                        //                               '...';
                        //                         }
                        //                         return desc;
                        //                       }(),
                        //                     ),
                        //                     overflow: TextOverflow.ellipsis,
                        //                   ),
                        //                 ],
                        //               ),
                        //             ),
                        //             Positioned(
                        //               right:
                        //                   MediaQuery.of(context).size.width *
                        //                   0.1,
                        //               bottom:
                        //                   MediaQuery.of(context).size.height *
                        //                   0.007,
                        //               child: Text(
                        //                 'Tap for More',
                        //                 style: const TextStyle(
                        //                   color: Color(0xFF606060),
                        //                   fontSize: 14,
                        //                   fontWeight: FontWeight.w400,
                        //                 ),
                        //               ),
                        //             ),
                        //           ],
                        //         ),
                        //       ),
                        //     );
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shimmer loading untuk daftar acara
  Widget buildAcaraShimmer(BuildContext context, {int itemCount = 3}) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
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
                    height: MediaQuery.of(context).size.height * 0.2,
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
