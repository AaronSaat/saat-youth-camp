import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syc/screens/form_komitmen_screen.dart';
import 'package:syc/services/notification_service.dart'
    show NotificationService;
import 'package:url_launcher/url_launcher.dart'
    show canLaunchUrl, LaunchMode, launchUrl;
import '../services/api_service.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_not_found.dart';
import 'daftar_acara_screen.dart';
import 'package:shimmer/shimmer.dart';

import 'package:syc/utils/app_colors.dart';

import 'detail_acara_screen.dart';
import 'bible_reading_more_screen.dart';
import 'evaluasi_komitmen_view_screen.dart';
import 'pengumuman_detail_screen.dart';
import 'pengumuman_list_screen.dart';

import 'package:html/parser.dart' as html_parser;

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
  List<dynamic> _acaraListAll = [];
  List<dynamic> _komitmenListAll = [];
  List<dynamic> _acaraDateList = [];
  List<Map<String, dynamic>> _pengumumanList = [];
  int day = 1;
  int countAcara = 5;
  bool _isLoading = true;
  List<Map<String, dynamic>> _dataBrm = [];
  Map<String, String> _dataUser = {};
  int countRead = 0; //indikator user ini sudah membaca bacaan hariannya
  bool _komitmenDone = false;

  @override
  void initState() {
    super.initState();
    initAll();
    _acaraController.addListener(() {
      double itemWidth;
      if (countAcara <= 2) {
        itemWidth = 40;
      } else if (countAcara == 3) {
        itemWidth = 110;
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
      await loadDayHariIni(); //untuk ambil tangggal hari ini
      await loadAcaraByDay();
      await loadReportBrmByPesertaByDay();
      await loadPengumumanByUserId();
      await checkKomitmenDone();

      // untuk keperluan notifikasi
      await loadAllAcara();
      await loadAllKomitmen();
      await setupAllNotification();

      //setup notifications
      // await setupDailyNotification();

      // ini adalah notifikasi pasti yaitu:
      // 1. Notifikasi acara 15 menit sebelum acara hari 1 - 4 (untuk semua role)
      // 2. Notifikasi evaluasi 2 jam menit setelah acara dimulai hari 1 - 4 (untuk peserta, pembina)
      // 3. Notifikasi evaluasi keseluruhan 1x hari terakhir jam 12 siang (untuk peserta, pembina)
      // 4. Notifikasi komitmen setiap hari tiap jam 8 malam (untuk peserta)
      await setupAllNotification();
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
      'group_id',
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
      final count = await ApiService.getBrmReportCountByPesertaByDay(
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

  // untuk load acara berdasarkan hari ini
  Future<void> loadDayHariIni() async {
    if (!mounted) return;
    setState(() {});
    try {
      final acaraList = await ApiService.getAcara(context);
      if (!mounted) return;
      setState(() {
        print('Acara Date List: $acaraList');

        // final today = DateTime.now().toIso8601String().substring(0, 10);
        final today =
            "2025-12-31"; // hardcoded untuk testing, [DEVELOPMENT NOTES] nanti hapus

        // Ambil list tanggal dan hari unik
        final List<Map<String, dynamic>> tanggalHariList = [];
        final Set<String> tanggalHariSet = {};

        for (var acara in acaraList) {
          final tanggal = acara['tanggal'];
          final hari = acara['hari'];
          final key = '$tanggal|$hari';
          if (!tanggalHariSet.contains(key)) {
            tanggalHariSet.add(key);
            tanggalHariList.add({'tanggal': tanggal, 'hari': hari});
          }
        }

        _acaraDateList = tanggalHariList;
        print("$_acaraDateList");

        // Cek apakah today ada di tanggalHariList
        final todayEntry = tanggalHariList.firstWhere(
          (item) => item['tanggal'] == today,
          orElse: () => {},
        );
        if (todayEntry.isNotEmpty) {
          day = todayEntry['hari'] ?? 0;
        } else {
          day = 0; //  default
        }
      });
    } catch (e) {
      print('❌ Gagal memuat tanggal acara: $e');
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<void> loadAcaraByDay() async {
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
        print('Acara List: $_acaraList');
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

  // untuk notifikasi
  Future<void> loadAllAcara() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final acaraList = await ApiService.getAcara(context);
      if (!mounted) return;
      setState(() {
        _acaraListAll = acaraList;
        _isLoading = false;
        print('Acara List All: \n$_acaraListAll');
      });
    } catch (e) {
      print('❌ Gagal memuat all acara : $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // untuk notifikasi
  Future<void> loadAllKomitmen() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final komitmenList = await ApiService.getKomitmen(context);
      if (!mounted) return;
      setState(() {
        _komitmenListAll = komitmenList;
        _isLoading = false;
        print('Komitmen List All: \n$_komitmenListAll');
      });
    } catch (e) {
      print('❌ Gagal memuat all komitmen : $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadPengumumanByUserId() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final pengumumanList = await ApiService.getPengumuman(
        context,
        _dataUser['id'],
      );
      if (!mounted) return;
      setState(() {
        final pengumumanList2 = List<Map<String, dynamic>>.from(pengumumanList);
        _pengumumanList = pengumumanList2;
        _isLoading = false;
        if (_pengumumanList.isNotEmpty) {
          print('Pengumuman index 0: ${_pengumumanList[0]}');
        }
      });
    } catch (e) {
      print('❌ Gagal memuat pengumuman: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> checkKomitmenDone() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final komitmenProgress = await ApiService.getKomitmenByPesertaByDay(
        context,
        _dataUser['id'],
        1, //hardcoded
      );
      if (!mounted) return;
      setState(() {
        // Ambil status komitmen dari response
        final dataKomitmen = komitmenProgress['success'] ?? false;
        _komitmenDone = dataKomitmen;
        print('Status komitmen: $_komitmenDone');
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat progress komitmen: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Future<void> setupDailyNotification() async {
  //   try {
  //     final notificationService = NotificationService();
  //     await notificationService.initialize();

  //     // ⬅️ CANCEL SEMUA NOTIFIKASI LAMA TERLEBIH DAHULU
  //     await notificationService.cancelNotification();

  //     // Setup notifikasi baru
  //     await notificationService.scheduledNotification(
  //       title: '📖 Waktu Bacaan Harian!',
  //       body:
  //           'Jangan lupa baca Alkitab hari ini. Tuhan menunggu waktu bersamamu!',
  //       scheduledTime: _getNext9AM(),
  //       payload: 'splash',
  //     );

  //     print(
  //       '✅ Daily BRM notification setup completed (old notifications cancelled)',
  //     );
  //   } catch (e) {
  //     print('❌ Error setting up daily notifications: $e');
  //   }
  // }

  // ini adalah notifikasi pasti yaitu:
  // 1. Notifikasi acara 15 menit sebelum acara hari 1 - 4 (untuk semua role)
  // 2. Notifikasi evaluasi 2 jam setelah acara dimulai hari 1 - 4 (untuk peserta, pembina)
  // 3. Notifikasi evaluasi keseluruhan 1x hari terakhir jam 12 siang (untuk peserta, pembina)
  // 4. Notifikasi komitmen setiap hari tiap jam 8 malam (untuk peserta)
  Future<void> setupAllNotification() async {
    try {
      final notificationService = NotificationService();
      await notificationService.initialize();

      // CANCEL SEMUA NOTIFIKASI LAMA TERLEBIH DAHULU
      await notificationService.cancelNotification();

      // 15 menit sebelum acara
      for (final acara in _acaraListAll) {
        final hari = acara['hari']?.toString();
        if (hari == "99") continue; // skip hari 99
        final tanggal = acara['tanggal'] ?? '';
        final waktu = acara['waktu'] ?? '';
        final namaAcara = acara['acara_nama'] ?? 'Acara';
        DateTime? scheduledTime;
        try {
          scheduledTime = DateTime.parse(
            '$tanggal ${waktu.length == 5 ? waktu : '00:00'}:00',
          );
          scheduledTime = scheduledTime.subtract(const Duration(minutes: 15));
        } catch (e) {
          continue;
        }
        print(
          '🔔 Jadwalkan notif 15 menit sebelum acara "$namaAcara" pada $scheduledTime',
        );
        if (scheduledTime.isAfter(DateTime.now())) {
          await notificationService.scheduledNotification(
            title: '⏰ Acara akan dimulai!',
            body: '${namaAcara} akan dimulai dalam 15 menit!',
            scheduledTime: scheduledTime,
            payload: 'splash',
          );
        }
      }

      final userRole = _dataUser['role']?.toLowerCase() ?? '';
      // Evaluasi
      // Notifikasi evaluasi 2 jam setelah acara dimulai
      // Hanya untuk role peserta atau pembina
      if (userRole == 'peserta' || userRole == 'pembina') {
        for (final acara in _acaraListAll) {
          final hari = acara['hari']?.toString();
          if (hari == "99") continue; // skip hari 99
          final tanggal = acara['tanggal'] ?? '';
          final waktu = acara['waktu'] ?? '';
          final namaAcara = acara['acara_nama'] ?? 'Acara';
          DateTime? scheduledTime;
          try {
            // Gabungkan tanggal dan waktu, misal: '2025-12-31' + '07:30'
            scheduledTime = DateTime.parse(
              '$tanggal ${waktu.length == 5 ? waktu : '00:00'}:00',
            );
            // Tambahkan 2 jam setelah acara dimulai
            scheduledTime = scheduledTime.add(const Duration(hours: 2));
          } catch (e) {
            print(
              '❌ Gagal parsing tanggal/waktu evaluasi: $tanggal $waktu ($e)',
            );
            continue;
          }
          print(
            '🔔 Jadwalkan notif evaluasi 2 jam setelah acara "$namaAcara" pada $scheduledTime',
          );
          if (scheduledTime.isAfter(DateTime.now())) {
            await notificationService.scheduledNotification(
              title: '📝 Reminder Evaluasi!',
              body: 'Jangan lupa mengisi evaluasi acara : ${namaAcara}',
              scheduledTime: scheduledTime,
              payload: 'splash',
            );
          }
        }
      }

      // Evaluasi keseluruhan
      // Evaluasi keseluruhan: cari acara dengan hari == "99"
      // Evaluasi keseluruhan: hanya untuk role peserta atau pembina
      if (userRole == 'peserta' || userRole == 'pembina') {
        final acaraEvaluasi = _acaraListAll.firstWhere(
          (acara) => acara['hari']?.toString() == "99",
          orElse: () => null,
        );

        if (acaraEvaluasi != null) {
          final tanggal = acaraEvaluasi['tanggal'];
          try {
            // Set jam 12:00 siang pada tanggal tersebut
            // Jika tanggal == '2026-01-02', set scheduledTime ke 2 Januari 2026 jam 12:00:00
            final scheduledTime = DateTime.parse('2026-01-02 12:00:00');
            print(
              '🔔 Jadwalkan notif evaluasi keseluruhan pada $scheduledTime',
            );
            if (scheduledTime.isAfter(DateTime.now())) {
              await notificationService.scheduledNotification(
                title: 'Thank you for attending SYC 2025 - Redeemed!',
                body:
                    '📝 Jangan lupa mengisi evaluasi keseluruhan pada profil kamu 😊',
                scheduledTime: scheduledTime,
                payload: 'splash',
              );
            }
          } catch (e) {
            print(
              '❌ Gagal parsing tanggal evaluasi keseluruhan: $tanggal ($e)',
            );
          }
        }
      }

      // Komitmen harian
      // Notifikasi komitmen harian: iterasi semua komitmen, jadwalkan pada tanggal terkait jam 20:00
      // Komitmen harian: hanya untuk role peserta
      if (userRole == 'peserta') {
        for (final komitmen in _komitmenListAll) {
          final tanggal = komitmen['tanggal'];
          final hariKomitmen = komitmen['hari'] ?? '0';
          if (tanggal != null && tanggal is String && tanggal.isNotEmpty) {
            try {
              // Set jam 20:00 (8 malam) pada tanggal tersebut
              final scheduledTime = DateTime.parse('$tanggal 20:00:00');
              if (scheduledTime.isAfter(DateTime.now())) {
                await notificationService.scheduledNotification(
                  title: '🙏 Reminder Komitmen!',
                  body:
                      'Jangan lupa mengisi komitmen hari ke : ${hariKomitmen}',
                  scheduledTime: scheduledTime,
                  payload: 'splash',
                );
              }
            } catch (e) {
              print('❌ Gagal parsing tanggal komitmen: $tanggal ($e)');
            }
          }
        }
      }
      print('Notificaton setup completed');
    } catch (e) {
      print('❌ Error setting up daily notifications: $e');
    }
  }

  DateTime _getNext9AM() {
    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      9,
      03,
    ); // 09:00

    // Jika sudah lewat jam 9 hari ini, jadwalkan untuk besok
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    return scheduledTime;
  }

  @override
  void dispose() {
    _acaraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _dataUser['id'] ?? '-';
    final role = _dataUser['role'] ?? '-';
    final gereja = _dataUser['gereja_nama'] ?? '-';
    final kelompok = _dataUser['nama_kelompok'] ?? '-';

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
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 24),
                      //   child: Column(
                      //     children: [
                      //       Align(
                      //         alignment: Alignment.topRight,
                      //         child: Image.asset(
                      //           'assets/buttons/hamburger_white.png',
                      //           height: 48,
                      //           width: 48,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('assets/texts/hello.png', height: 72),
                          ],
                        ),
                      ),

                      // Pembina Pembimbing Card
                      if (role.toLowerCase().contains('pembina') == true ||
                          role.toLowerCase().contains('pembimbing') == true)
                        const SizedBox(height: 24),

                      if (role.toLowerCase().contains('pembina') == true ||
                          role.toLowerCase().contains('pembimbing') == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/card_dashboard_role.png',
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 16.0,
                                          bottom: 16.0,
                                          left: 48,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              (_dataUser['role']
                                                          ?.toLowerCase()
                                                          .contains(
                                                            'pembimbing',
                                                          ) ==
                                                      true)
                                                  ? 'Pembimbing'
                                                  : (_dataUser['role']
                                                          ?.toLowerCase()
                                                          .contains(
                                                            'pembina',
                                                          ) ==
                                                      true)
                                                  ? 'Pembina'
                                                  : 'role???',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                            Text(
                                              (_dataUser['role']
                                                          ?.toLowerCase()
                                                          .contains(
                                                            'pembimbing',
                                                          ) ==
                                                      true)
                                                  ? '${_dataUser['kelompok_nama'] ?? ''}'
                                                  : (_dataUser['role']
                                                          ?.toLowerCase()
                                                          .contains(
                                                            'pembina',
                                                          ) ==
                                                      true)
                                                  ? '${_dataUser['gereja_nama'] ?? ''}'
                                                  : 'nama???',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.right,
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
                      const SizedBox(height: 24),

                      // Notifikasi
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 24),
                      //   child: Column(
                      //     children: [
                      //       // Test Notification Button
                      //       SizedBox(
                      //         width: double.infinity,
                      //         child: ElevatedButton.icon(
                      //           onPressed: () {
                      //             NotificationService().showNotification(
                      //               title: 'Test Notification',
                      //               body:
                      //                   'This is a text notification from SYC App.',
                      //               payload: 'splash',
                      //             );
                      //           },
                      //           icon: const Icon(Icons.notifications, size: 16),
                      //           label: const Text('Test Notifications'),
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor: AppColors.secondary,
                      //             foregroundColor: Colors.white,
                      //             padding: const EdgeInsets.symmetric(
                      //               vertical: 12,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       const SizedBox(height: 12),
                      //       // Schedule Notification Button (5s)
                      //       SizedBox(
                      //         width: double.infinity,
                      //         child: ElevatedButton.icon(
                      //           onPressed: () {
                      //             NotificationService().scheduledNotification(
                      //               title:
                      //                   'Scheduled Notification: 30 seconds later',
                      //               body:
                      //                   'This notification is scheduled for 30 seconds later.',
                      //               scheduledTime: DateTime.now().add(
                      //                 const Duration(seconds: 30),
                      //               ),
                      //               payload: 'splash',
                      //             );
                      //           },
                      //           icon: const Icon(Icons.schedule, size: 16),
                      //           label: const Text(
                      //             'Schedule Notification: 30s Later',
                      //           ),
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor: AppColors.secondary,
                      //             foregroundColor: Colors.white,
                      //             padding: const EdgeInsets.symmetric(
                      //               vertical: 12,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       const SizedBox(height: 12),
                      //       // Schedule Notification Button (9 July 2025 07:40 WIB)
                      //       SizedBox(
                      //         width: double.infinity,
                      //         child: ElevatedButton.icon(
                      //           onPressed: () {
                      //             // 07:40 WIB = UTC+7
                      //             final scheduledTime = DateTime.utc(
                      //               2025,
                      //               7,
                      //               9,
                      //               0,
                      //               40,
                      //             );
                      //             NotificationService().scheduledNotification(
                      //               title: 'Notifikasi Terjadwal',
                      //               body:
                      //                   'Ini notifikasi untuk 9 Juli 2025 jam 07.40 WIB.',
                      //               scheduledTime: scheduledTime,
                      //               payload: 'splash',
                      //             );
                      //           },
                      //           icon: const Icon(Icons.schedule_send, size: 16),
                      //           label: const Text(
                      //             'Schedule Notif 9 Juli 2025 07:40 WIB',
                      //           ),
                      //           style: ElevatedButton.styleFrom(
                      //             backgroundColor: AppColors.secondary,
                      //             foregroundColor: Colors.white,
                      //             padding: const EdgeInsets.symmetric(
                      //               vertical: 12,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // const SizedBox(height: 16),

                      // Bacaan Hari Ini (BRM)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child:
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
                                    ).then((result) {
                                      if (result == 'reload') {
                                        initAll(); // reload dashboard
                                      }
                                    });
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
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.center,
                                            colors: [
                                              Colors.black.withAlpha(100),
                                              Colors.black.withAlpha(10),
                                            ],
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
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                const url =
                                    'https://drive.google.com/drive/folders/1J7qIoUL7aI2YGy7tR_ZFQxX-7ylzVZrg?usp=sharing';
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(
                                    Uri.parse(url),
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 180,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: AssetImage(
                                          'assets/images/card_dokumentasi.jpg',
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          right: 8.0,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                shape: BoxShape.circle,
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: const Icon(
                                                Icons.arrow_forward_ios,
                                                color: Colors.white,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Dokumentasi Acara',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.right,
                                            ),
                                          ],
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

                      // Komitmen Card untuk Peserta
                      // Tampilkan Komitmen Card hanya jika:
                      // - BUKAN panitia, pembimbing, pembina
                      // - day antara 1 sampai 3 (inklusif)
                      if ((day >= 1 && day <= 3) &&
                          !role.toLowerCase().contains('panitia') &&
                          !role.toLowerCase().contains('pembimbing') &&
                          !role.toLowerCase().contains('pembina'))
                        const SizedBox(height: 24),

                      if ((day >= 1 && day <= 3) &&
                          !role.toLowerCase().contains('panitia') &&
                          !role.toLowerCase().contains('pembimbing') &&
                          !role.toLowerCase().contains('pembina'))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (_komitmenDone) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                EvaluasiKomitmenViewScreen(
                                                  type: 'Komitmen',
                                                  userId: userId,
                                                  acaraHariId:
                                                      day, //dari loadDayHariIni
                                                ),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => FormKomitmenScreen(
                                              userId: userId,
                                              acaraHariId:
                                                  day, //dari loadDayHariIni
                                            ),
                                      ),
                                    ).then((result) {
                                      if (result == 'reload') {
                                        initAll(); // reload dashboard
                                      }
                                    });
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 180,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: const DecorationImage(
                                          image: AssetImage(
                                            'assets/images/card_dashboard_komitmen.png',
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                right: 16.0,
                                                bottom: 16.0,
                                                left: 64,
                                              ),
                                              child: Text(
                                                _komitmenDone
                                                    ? 'Terima kasih telah mengisi komitmen hari ini!'
                                                    : 'Jangan lupa mengisi komitmen harianmu!',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_komitmenDone)
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(16),
                                                  bottomRight: Radius.circular(
                                                    8,
                                                  ),
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
                                                'Selesai',
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
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.circular(8),
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        child: Text(
                                          DateFormatter.ubahTanggal(
                                            DateTime.now()
                                                .toIso8601String()
                                                .substring(0, 10),
                                          ),
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

                      if (day >= 1 && day <= 4) const SizedBox(height: 24),

                      // Acara Hari Ini (batasi sampai hari ke-4, hari 99 gausah)
                      if (day >= 1 && day <= 4)
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
                                                              _acaraList[index]["id"]
                                                                  .toString(),
                                                          userId: userId,
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
                                                      child: Stack(
                                                        children: [
                                                          // Gradient overlay
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              gradient: LinearGradient(
                                                                begin:
                                                                    Alignment
                                                                        .bottomCenter,
                                                                end:
                                                                    Alignment
                                                                        .center,
                                                                colors: [
                                                                  Colors.black
                                                                      .withAlpha(
                                                                        100,
                                                                      ),
                                                                  Colors.black
                                                                      .withAlpha(
                                                                        10,
                                                                      ),
                                                                ],
                                                              ),
                                                              borderRadius: const BorderRadius.only(
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
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.only(
                                                                  left: 8,
                                                                  right: 8,
                                                                  bottom: 8,
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
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w900,
                                                                        color:
                                                                            Colors.white,
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
                                                                            Colors.white,
                                                                        size:
                                                                            12,
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
                                                                                14,
                                                                            color:
                                                                                Colors.white,
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
                                                        ],
                                                      ),
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
                                                                    fontSize:
                                                                        12,
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
                                                    // Positioned(
                                                    //   bottom: -5,
                                                    //   right: -5,
                                                    //   left: -5,
                                                    //   child: Card(
                                                    //     color: Colors.white,
                                                    //     shape: const RoundedRectangleBorder(
                                                    //       borderRadius:
                                                    //           BorderRadius.only(
                                                    //             bottomLeft:
                                                    //                 Radius.circular(
                                                    //                   16,
                                                    //                 ),
                                                    //             bottomRight:
                                                    //                 Radius.circular(
                                                    //                   16,
                                                    //                 ),
                                                    //           ),
                                                    //     ),
                                                    //     elevation: 0,
                                                    //     child: SizedBox(
                                                    //       width: 72,
                                                    //       height: 48,
                                                    //       child: Center(
                                                    //         child: Padding(
                                                    //           padding:
                                                    //               const EdgeInsets.all(
                                                    //                 8.0,
                                                    //               ),
                                                    //           child: Align(
                                                    //             alignment:
                                                    //                 Alignment
                                                    //                     .bottomLeft,
                                                    //             child: Column(
                                                    //               crossAxisAlignment:
                                                    //                   CrossAxisAlignment
                                                    //                       .start,
                                                    //               mainAxisAlignment:
                                                    //                   MainAxisAlignment
                                                    //                       .end,
                                                    //               children: [
                                                    //                 Flexible(
                                                    //                   child: Text(
                                                    //                     _acaraList[index]['acara_nama'] ??
                                                    //                         'Acara ${index + 1}???',
                                                    //                     textAlign:
                                                    //                         TextAlign
                                                    //                             .left,
                                                    //                     style: const TextStyle(
                                                    //                       fontSize:
                                                    //                           12,
                                                    //                       fontWeight:
                                                    //                           FontWeight.w900,
                                                    //                       color:
                                                    //                           AppColors.primary,
                                                    //                       overflow:
                                                    //                           TextOverflow.ellipsis,
                                                    //                     ),
                                                    //                   ),
                                                    //                 ),
                                                    //                 Row(
                                                    //                   children: [
                                                    //                     const Icon(
                                                    //                       Icons
                                                    //                           .location_on,
                                                    //                       color:
                                                    //                           AppColors.primary,
                                                    //                       size:
                                                    //                           10,
                                                    //                     ),
                                                    //                     const SizedBox(
                                                    //                       width:
                                                    //                           4,
                                                    //                     ),
                                                    //                     Flexible(
                                                    //                       child: Text(
                                                    //                         _acaraList[index]['tempat'] ??
                                                    //                             '',
                                                    //                         style: const TextStyle(
                                                    //                           fontSize:
                                                    //                               10,
                                                    //                           color:
                                                    //                               AppColors.primary,
                                                    //                           fontWeight:
                                                    //                               FontWeight.w300,
                                                    //                         ),
                                                    //                         overflow:
                                                    //                             TextOverflow.ellipsis,
                                                    //                       ),
                                                    //                     ),
                                                    //                   ],
                                                    //                 ),
                                                    //               ],
                                                    //             ),
                                                    //           ),
                                                    //         ),
                                                    //       ),
                                                    //     ),
                                                    //   ),
                                                    // ),
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
                                              margin:
                                                  const EdgeInsets.symmetric(
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

                      // Pengumuman
                      _isLoading
                          ? buildPengumumanShimmer()
                          : _pengumumanList.isEmpty
                          ? Center(
                            child: const CustomNotFound(
                              text: "Gagal memuat data pengumuman :(",
                              textColor: AppColors.brown1,
                              imagePath: 'assets/images/data_not_found.png',
                            ),
                          )
                          : SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _pengumumanList.length,
                              itemBuilder: (context, index) {
                                final pengumuman = _pengumumanList[index];
                                return InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PengumumanListScreen(),
                                      ),
                                    );
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 140,
                                        decoration: BoxDecoration(
                                          color: AppColors.secondary,
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 8,
                                            right: 128,
                                            top: 8,
                                            bottom: 8,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      pengumuman["judul"] ??
                                                          'Judul Pengumuman???',
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      pengumuman["detail"]
                                                          .replaceAll(
                                                            RegExp(r'<[^>]*>'),
                                                            '',
                                                          )
                                                          .trim(),
                                                      style: const TextStyle(
                                                        color:
                                                            AppColors.primary,
                                                        fontSize: 14,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: -15,
                                        right: -15,
                                        child: Image.asset(
                                          'assets/images/megaphone.png',
                                          width: 180,
                                          height: 180,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
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

Widget buildPengumumanShimmer() {
  return SizedBox(
    height: 140,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 2,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            period: const Duration(milliseconds: 800),
            child: Stack(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 128,
                      top: 8,
                      bottom: 8,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 180, height: 24, color: Colors.white),
                        const SizedBox(height: 12),
                        Container(width: 120, height: 16, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 100, height: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
